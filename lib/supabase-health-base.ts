import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {validateBenefits,applyBenefits,membersFromLegacy,copartFromLegacy} from './benefits';
import {applyHealthRates} from './health-pricing';
import {CalculationConflict,CalculationInputError} from './supabase-calculation';
export function healthBaseChanges(s:any,body:any){
 const v=s.versions.filter((v:any)=>v.employee===body.employee&&v.month<=body.month).sort((a:any,b:any)=>b.month.localeCompare(a.month))[0];
 if(!v||v.data!==body.source)throw new CalculationConflict('Cadastro alterado. Atualize antes de salvar.');
 const d=JSON.parse(v.data);d.healthMembers=body.members;const latest=(rows:any[])=>[...rows].sort((a,b)=>b.month.localeCompare(a.month))[0];
 try{Object.assign(d,validateBenefits(d));delete d.healthCopart;Object.assign(d,applyHealthRates(d,body.month,{unimed:latest(s.unimed_rates),uniodonto:latest(s.uniodonto_fixed_rates)},true));delete d.healthCopart;}catch(e){throw new CalculationInputError((e as Error).message);}
 const row=s.period?.status==='open'?s.records.find((r:any)=>r.employee===body.employee):null;let records:any[]=[];
 if(row){
  const record=JSON.parse(row.data),oldMembers=membersFromLegacy(record),copart=copartFromLegacy(record);
  if(oldMembers.some((m:any)=>Number(copart[m.id])>0&&!d.healthMembers.some((n:any)=>n.id===m.id)))throw new CalculationInputError('Há coparticipação de participante removido. Zere o lançamento antes de remover o participante.');
  record.healthMembers=d.healthMembers;record._healthEmployerShare=d._healthEmployerShare;record.healthCopart=copart;
  try{Object.assign(record,validateBenefits(record));records=[{employee:row.employee,revision:row.revision,data:JSON.stringify(applyBenefits(record))}];}catch(e){throw new CalculationInputError((e as Error).message);}
 }
 return {data:JSON.stringify(d),records};
}
export async function saveHealthBase(body:any,actor:string){
 const {snapshot,token}=await supabaseAdminRequest<any>('/rest/v1/rpc/finance_calculation_snapshot',{method:'POST',body:{p_month:body.month}});
 const c=healthBaseChanges(snapshot,body);
 if(!await supabaseAdminRequest<boolean>('/rest/v1/rpc/save_finance_health_base',{method:'POST',body:{p_month:body.month,p_employee:body.employee,p_actor:actor,p_token:token,p_data:c.data,p_records:c.records}}))throw new CalculationConflict('Cadastro ou folha alterados. Atualize antes de salvar.');
 return {ok:true};
}
