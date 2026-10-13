import './test-module-hooks.mjs';
import {registerHooks} from 'node:module';
import assert from 'node:assert/strict';
const objects=new Map();let snapshot,metadata=[],calls=[],mode='ok',privateBucket=false;
globalThis.__filesUser=()=>({userId:'test-files-admin',email:'test@example.invalid',role:'admin'});
globalThis.__filesAdmin=async(path,o={})=>{
 calls.push(path);
 if(path.endsWith('finance_calculation_snapshot'))return {snapshot,token:'a'.repeat(32)};
 if(path.endsWith('reserve_auth_attempt'))return true;
 if(path.endsWith('save_finance_file')){if(mode==='conflict')return false;metadata.push({id:o.body.p_id,name:o.body.p_name,key:o.body.p_key});return true;}
 if(path.startsWith('/rest/v1/files?'))return metadata.filter(f=>path.includes('eq.'+f.id));
 throw Error('Unexpected REST path');
};
globalThis.__filesStorage=async(path,o={})=>{
 calls.push(path);
 if(path.startsWith('/storage/v1/bucket/'))return privateBucket?Response.json({public:mode==='public'}):Response.json({error:'missing'},{status:404});
 if(path==='/storage/v1/bucket'){privateBucket=true;assert.equal(JSON.parse(o.body).public,false);return Response.json({});}
 if(o.method==='DELETE'){for(const key of JSON.parse(o.body).prefixes)objects.delete(key);return Response.json({});}
 const key=path.split('/ibagy-finance-private/')[1];
 if(o.method==='POST'){if(mode==='uploadFail')return new Response(null,{status:500});assert.equal(o.headers['x-upsert'],'false');objects.set(key,new Uint8Array(o.body));return Response.json({});}
 return objects.has(key)?new Response(objects.get(key)):new Response(null,{status:404});
};
registerHooks({resolve(s,c,next){if(s==='server-only')return {url:'data:text/javascript,export%20default%20null',shortCircuit:true};return next(s,c);},load(u,c,next){
 if(u.endsWith('/lib/supabase-admin.ts'))return {format:'module',source:'export const supabaseAdminRequest=(...a)=>globalThis.__filesAdmin(...a);export const supabaseServerFetch=(...a)=>globalThis.__filesStorage(...a);',shortCircuit:true};
 if(u.endsWith('/lib/local-auth.ts'))return {format:'module',source:'export const localUser=async()=>globalThis.__filesUser();',shortCircuit:true};return next(u,c);
}});
const XLSX=await import('xlsx');const {payrollExport}=await import('../lib/payroll-export.ts');
const {exportRows}=await import('../lib/payroll.ts');const {calculatedRecords}=await import('../lib/supabase-calculation.ts');
const {exportFinanceFile,financeFileDownload,attachFinanceFile}=await import('../lib/supabase-files.ts');
const {financeDocumentUpload}=await import('../lib/supabase-documents.ts');
const base={B:'TEST-EXPORT',C:'Colaborador fictício',D:'2020-01-01',F:'1980-01-01',K:'3000.00',G:'Normal',H:'Loja fictícia',P:'',U:'100.00',T:'10.00',commissionNet:'90.00',commissionIR:'10.00',W:'20.00',Z:'30.00',AA:'40.00',gender:'Masculino',receivesVA:true,chargeSerefi:true};
snapshot={period:null,employees:[{id:'test-export',active:1}],versions:[{employee:'test-export',month:'2020-01',data:JSON.stringify(base)}],records:[],allowances:[{month:'2000-01',amount:90000}],minimum_wages:[],normative_wages:[],unimed_rates:[],uniodonto_fixed_rates:[],installments:[],event_plans:[],childcare_children:[]};
snapshot.records=await calculatedRecords(snapshot,'2026-10','period');snapshot.period={month:'2026-10',status:'open'};
const before=JSON.stringify(snapshot);
for(const kind of ['commission','health','payroll']){
 const file=payrollExport(kind,'2026-10',snapshot.records),wb=XLSX.read(file.bytes,{type:'array',cellDates:false});
 const expected=exportRows(kind,'2026-10',snapshot.records);assert.deepEqual(wb.SheetNames,Object.keys(expected));
 for(const [name,rows] of Object.entries(expected)){
  const original=XLSX.utils.aoa_to_sheet(rows,{cellDates:false}),sheet=wb.Sheets[name];
  for(const [address,cell] of Object.entries(original)){if(address.startsWith('!'))continue;assert.equal(sheet[address]?.v,cell.v,kind+' '+name+' '+address);}
 }
 const generated=await exportFinanceFile('2026-10',kind,'test@example.invalid');assert.equal(generated.ok,true);
 const response=await financeFileDownload(generated.id);assert.equal(response.status,200);assert.equal(response.headers.get('content-type'),file.contentType);assert.match(response.headers.get('content-disposition'),/attachment/);assert.equal(response.headers.get('cache-control'),'private, no-store');
 const stored=await response.arrayBuffer();assert.deepEqual(XLSX.read(stored,{type:'array'}).SheetNames,Object.keys(expected));
}
assert.equal(JSON.stringify(snapshot),before,'Exports must not change records');
await assert.rejects(exportFinanceFile('2026-10','bad','test@example.invalid'),/inválido/);
const missing=snapshot.records;snapshot.records=[{...missing[0],data:JSON.stringify(base)}];await assert.rejects(exportFinanceFile('2026-10','payroll','test@example.invalid'),/sem cálculos/);snapshot.records=missing;
const count=objects.size;mode='conflict';await assert.rejects(exportFinanceFile('2026-10','payroll','test@example.invalid'),/mudaram/);assert.equal(objects.size,count,'Uncommitted upload cleaned up');
mode='public';await assert.rejects(exportFinanceFile('2026-10','payroll','test@example.invalid'),/privado/);mode='uploadFail';await assert.rejects(exportFinanceFile('2026-10','payroll','test@example.invalid'),/armazenar/);mode='ok';
const attachment=await attachFinanceFile('2026-10','teste-ficticio.txt',new TextEncoder().encode('documento fictício').buffer,'test@example.invalid');assert.equal((await financeFileDownload(attachment.id)).status,200);
assert.equal((await financeFileDownload('invalid')).status,400);assert.equal((await financeFileDownload(crypto.randomUUID())).status,404);
const form=new FormData();form.set('month','2026-10');form.set('file',new File(['fictício'],'teste.txt',{type:'text/plain'}));
const request=()=>new Request('https://test.invalid/api/documents',{method:'POST',headers:{origin:'https://test.invalid'},body:form});
assert.equal((await financeDocumentUpload(request())).status,200);
globalThis.__filesUser=()=>({userId:'viewer',email:'viewer@example.invalid',role:'viewer'});assert.equal((await financeDocumentUpload(request())).status,403);
globalThis.__filesUser=()=>null;assert.equal((await financeDocumentUpload(request())).status,401);
console.log('PASS: original XLS/XLSX sheet/cell parity for 3 exports, private Storage transport, downloads, metadata, stale snapshots/cleanup, no payroll mutation, invalid/missing files and upload authorization (HTTP mocks; live Storage/browser pending)');
