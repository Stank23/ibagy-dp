import './test-module-hooks.mjs';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const {exportRows}=await import('../lib/payroll.ts');
const {payrollExport}=await import('../lib/payroll-export.ts');
const XLSX=await import('xlsx');
const labels=JSON.parse(readFileSync('lib/fields.json','utf8')).healthLabels;
const member=(plan,role,i)=>({id:plan+role+i,plan,role,name:role==='titular'?'TESTE':`Dependente ${plan} ${i}`,monthly:(100+i).toFixed(2)});
const fixture=(u,o)=>{const members=['unimed','uniodonto'].flatMap((p,j)=>[member(p,'titular',0),...Array.from({length:j?o:u},(_,i)=>member(p,'dependente',i+1))]);return {data:JSON.stringify({B:'TEST',C:'TESTE',_healthEmployerShare:true,healthMembers:members,healthCopart:Object.fromEntries(members.map(m=>[m.id,'2.50']))})};};
for(const [u,o] of [[0,0],[1,2],[4,4],[6,5],[98,0]]){
 const records=[fixture(u,o),fixture(0,0)],before=JSON.stringify(records);
 const rows=exportRows('health','2026-11',records).folha;
 assert.equal(rows[3].length,10+3*(u+o));assert.equal(rows[4].length,rows[3].length);
 assert.equal(rows[4][rows[3].indexOf('Unimed Empresa')],30);assert.equal(rows[4][rows[3].indexOf('Unimed Mensal Titular')],70);
 for(const [plan,count] of [['Unimed',u],['Uniodonto',o]])for(let i=1;i<=count;i++){
  const idx=rows[3].findIndex(l=>l===`${plan} Mensal ${i}`);assert.notEqual(idx,-1);assert.equal(rows[4][idx],100+i);assert.equal(rows[4][idx+1],2.5);assert.equal(rows[5][idx],'');
 }
 if(u===4&&o===4)assert.deepEqual(rows[3],labels);
 const file=payrollExport('health','2026-11',records);assert.equal(file.ext,u===98?'xlsx':'xls');const wb=XLSX.read(file.bytes,{type:'array'}),sheet=XLSX.utils.sheet_to_json(wb.Sheets.folha,{header:1,defval:''});
 assert.deepEqual(sheet[3],rows[3]);assert.deepEqual(sheet[4],rows[4]);assert.equal(JSON.stringify(records),before);
}
const legacy=exportRows('health','2026-11',[{data:JSON.stringify({B:'LEGACY',C:'TESTE',AX:'Dependente legado',AY:'12.34',AZ:'5.67'})}]).folha;
assert.equal(legacy[3].length,13);assert.deepEqual(legacy[4].slice(6,9),['Dependente legado',12.34,5.67]);
const excluded=JSON.parse(fixture(8,8).data);excluded._excluded=true;
assert.equal(exportRows('health','2026-11',[fixture(1,0),{data:JSON.stringify(excluded)}]).folha[3].length,13);
console.log('PASS: dynamic per-plan columns 0/1/2/4/5/6 dependents, XLS readback, legacy data, excluded records, monthly/copart values, employer share and immutable inputs.');
