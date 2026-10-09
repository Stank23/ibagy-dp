import 'server-only';
import {supabaseAdminRequest,supabaseServerFetch} from './supabase-admin';
import {payrollExport} from './payroll-export';
import {hasAutomaticResults} from './calculation-status';
import {CalculationConflict,CalculationInputError,type CalculationSnapshot} from './supabase-calculation';
import {downloadResponse} from './download-response';
const bucket='ibagy-finance-private';
const objectPath=(key:string)=>{
 if(!/^(exports|documents)\/20\d{2}-(0[1-9]|1[0-2])\/[a-f0-9-]{36}(\.(xls|xlsx))?$/.test(key))throw Error('Arquivo inválido.');
 return '/storage/v1/object/'+bucket+'/'+key;
};
async function ensureBucket(){
 const current=await supabaseServerFetch('/storage/v1/bucket/'+bucket);
 if(current.ok){const b=await current.json();if(b.public!==false)throw Error('O armazenamento deve ser privado.');return;}
 if(current.status!==404&&current.status!==400)throw Error('Armazenamento indisponível.');
 const created=await supabaseServerFetch('/storage/v1/bucket',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({id:bucket,name:bucket,public:false,file_size_limit:16*1024*1024})});
 if(!created.ok){const existing=await supabaseServerFetch('/storage/v1/bucket/'+bucket);if(!existing.ok||(await existing.json()).public!==false)throw Error('Armazenamento privado indisponível.');}
}
async function putFile(month:string,kind:string,name:string,key:string,bytes:BodyInit,contentType:string,actor:string,token:string){
 await ensureBucket();
 const upload=await supabaseServerFetch(objectPath(key),{method:'POST',headers:{'Content-Type':contentType,'x-upsert':'false'},body:bytes});
 if(!upload.ok)throw Error('Não foi possível armazenar o arquivo.');
 const id=key.split('/').at(-1)!.replace(/\.(xls|xlsx)$/,'');
 let saved=false;
 try{
  saved=await supabaseAdminRequest<boolean>('/rest/v1/rpc/save_finance_file',{method:'POST',body:{p_month:month,p_kind:kind,p_id:id,p_name:name,p_key:key,p_actor:actor,p_token:token}});
  if(!saved)throw new CalculationConflict('Os dados mudaram durante a geração. Atualize e gere novamente.');
 }catch(error){
  // Ambiguous commit (network failure) must not delete an object whose metadata committed.
  let existing:any[]|undefined;
  try{existing=await supabaseAdminRequest<any[]>('/rest/v1/files?select=id&id=eq.'+id);}catch{}
  if(existing?.length===0){await supabaseServerFetch('/storage/v1/object/'+bucket,{method:'DELETE',headers:{'Content-Type':'application/json'},body:JSON.stringify({prefixes:[key]})}).catch(()=>{});}
  throw error;
 }
 return {ok:true,id,name};
}
export async function exportFinanceFile(month:string,kind:string,actor:string){
 if(!['commission','health','payroll'].includes(kind))throw new CalculationInputError('Tipo de exportação inválido.');
 const {snapshot,token}=await supabaseAdminRequest<{snapshot:CalculationSnapshot;token:string}>('/rest/v1/rpc/finance_calculation_snapshot',{method:'POST',body:{p_month:month}});
 if(!snapshot.period)throw new CalculationInputError('Abra a competência antes de exportar.');
 if(!snapshot.records.length)throw new CalculationInputError('A competência não tem colaboradores.');
 if(snapshot.records.some(r=>{const d=JSON.parse(r.data);return d._excluded!==true&&!hasAutomaticResults(d);}))throw new CalculationConflict('Há lançamentos sem cálculos automáticos. Confira e atualize esta competência antes de exportar.');
 let file;try{file=payrollExport(kind,month,snapshot.records);}catch(e){throw new CalculationInputError(e instanceof Error?e.message:'Não foi possível gerar o arquivo.');}
 const id=crypto.randomUUID(),name=`IBAGY-${kind==='commission'?'Comissao-dia20':kind==='health'?'Unimed-Uniodonto':'Folha-principal'}-${month}-${id.slice(0,6)}.${file.ext}`,key=`exports/${month}/${id}.${file.ext}`;
 return putFile(month,kind,name,key,file.bytes as BodyInit,file.contentType,actor,token);
}
export async function attachFinanceFile(month:string,name:string,bytes:ArrayBuffer,actor:string){
 const {snapshot,token}=await supabaseAdminRequest<{snapshot:CalculationSnapshot;token:string}>('/rest/v1/rpc/finance_calculation_snapshot',{method:'POST',body:{p_month:month}});
 if(!snapshot.period)throw new CalculationInputError('Competência não encontrada.');
 const key=`documents/${month}/${crypto.randomUUID()}`;
 return putFile(month,'document',name,key,bytes,'application/octet-stream',actor,token);
}
export async function financeFileDownload(id:string){
 if(!/^[a-f0-9-]{36}$/.test(id))return Response.json({error:'Arquivo inválido.'},{status:400});
 const rows=await supabaseAdminRequest<any[]>('/rest/v1/files?select=*&id=eq.'+id+'&limit=1');
 if(!rows[0])return Response.json({error:'Arquivo não encontrado.'},{status:404});
 const file=rows[0],object=await supabaseServerFetch(objectPath(file.key));
 if(!object.ok)return Response.json({error:'Arquivo indisponível.'},{status:404});
 const bytes=await object.arrayBuffer();
 return downloadResponse(bytes,file.name,file.key.endsWith('.xlsx')?'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':file.key.endsWith('.xls')?'application/vnd.ms-excel':'application/octet-stream',bytes.byteLength);
}
