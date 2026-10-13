import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {changedSalary} from './salary-adjustments';
import {calculate} from './finance-service';
import {cents} from './payroll';
import {value} from './rules';
import {snapshotContext,CalculationInputError,CalculationConflict} from './supabase-calculation';
export const salaryActions=new Set(['salary_preview','salary_adjust','salary_rows_preview','salary_rows_apply']);
export async function salaryChanges(s:any,body:any){
 const individual=body.action.startsWith('salary_rows'),month=body.month;
 const current=s.employees.filter((e:any)=>individual||e.active===1).sort((a:any,b:any)=>a.registration.localeCompare(b.registration)).flatMap((e:any)=>{const v=s.versions.filter((v:any)=>v.employee===e.id&&v.month<=month).sort((a:any,b:any)=>b.month.localeCompare(a.month))[0];return v?[{id:e.id,...v}]:[];});
 let list:any[]=[];
 try{
  if(individual){
   if(!Array.isArray(body.edits)||!body.edits.length||body.edits.length>1000)throw Error('Informe os salários que deseja alterar.');
   const ids=new Set();list=body.edits.map((edit:any)=>{if(ids.has(edit.employee))throw Error('Colaborador repetido no reajuste.');ids.add(edit.employee);const r=current.find((r:any)=>r.id===edit.employee);if(!r)throw Error('Cadastro vigente não encontrado.');const d=JSON.parse(r.data),old=cents(d.K);return {id:r.id,name:d.C,registration:d.B,old,next:changedSalary(old,edit.mode,edit.value),source:r.data,sourceMonth:r.month};});
  }else{
   const percent=String(body.percent);if(!/^\d{1,3}(\.\d{1,2})?$/.test(percent)||Number(percent)<=0||Number(percent)>100)throw Error('Informe um reajuste entre 0,01% e 100%');
   list=current.map((r:any)=>{const d=JSON.parse(r.data),old=cents(d.K),next=Math.round(old*(10000+Math.round(Number(percent)*100))/10000);return {id:r.id,name:d.C,registration:d.B,old,next,source:r.data,effective:r.month};});
  }
 }catch(e){throw new CalculationInputError((e as Error).message);}
 if(body.applyOpen&&(individual?s.period?.status!=='open':s.period?.status==='closed'))throw new CalculationConflict('Abra ou reabra a competência para atualizar também a folha.');
 const ids=new Set(list.map(r=>r.id)),records=body.applyOpen&&s.period?.status==='open'?s.records.filter((r:any)=>ids.has(r.employee)):[];
 let token;
 if(individual){const input=JSON.stringify({month,applyOpen:!!body.applyOpen,list,records});const digest=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(input));token=Array.from(new Uint8Array(digest)).map(n=>n.toString(16).padStart(2,'0')).join('');}
 else token=JSON.stringify(list.map(r=>[r.id,r.source]));
 const preview=body.action==='salary_preview'||body.action==='salary_rows_preview';
 if(preview)return {preview:true,response:{ok:true,list:individual?list.map(({source,sourceMonth,...r})=>r):list,token}};
 if(body.token!==token)throw new CalculationConflict('Os valores mudaram. Confira uma nova prévia antes de confirmar.');
 const versions=list.map(r=>{const d=JSON.parse(r.source);d.K=value(r.next);return {employee:r.id,data:JSON.stringify(d)};});
 const context=snapshotContext(s),updates=await Promise.all(records.map(async(r:any)=>{const d=JSON.parse(r.data);d.K=value(list.find(x=>x.id===r.employee).next);return {employee:r.employee,revision:r.revision,data:JSON.stringify(await calculate(null,d,r.employee,month,context))};}));
 return {preview:false,versions,records:updates,response:{ok:true,count:list.length}};
}
export async function saveSalary(body:any,actor:string){
 const {snapshot,token}=await supabaseAdminRequest<any>('/rest/v1/rpc/finance_calculation_snapshot',{method:'POST',body:{p_month:body.month}});
 const c=await salaryChanges(snapshot,body);if(c.preview)return c.response;
 if(!await supabaseAdminRequest<boolean>('/rest/v1/rpc/save_finance_salary',{method:'POST',body:{p_month:body.month,p_actor:actor,p_token:token,p_action:body.action,p_apply_open:!!body.applyOpen,p_versions:c.versions,p_records:c.records}}))throw new CalculationConflict('Os cadastros ou a folha mudaram durante o reajuste. Confira uma nova prévia.');
 return c.response;
}
