import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {commissionDays,commissionAmounts} from './commission';
import {applyProvisions} from './provisions';
import {membersFromLegacy,copartFromLegacy,validateBenefits} from './benefits';
import {applyHealthRates,validHealthBirthDate} from './health-pricing';
import {CalculationConflict,CalculationInputError,type CalculationSnapshot} from './supabase-calculation';
export const recordActions=new Set(['commission_value','health_sync','health_copart','health_copart_bulk','health_monthly_bulk']);
type Snapshot=CalculationSnapshot&{dsr_settings:any[]};
export function recordActionUpdates(s:Snapshot,body:any){
 const month=body.month,action=body.action;
 if(s.period?.status!=='open')throw new CalculationConflict('Abra ou reabra a competência antes de salvar.');
 if(action==='commission_value'&&s.period.commission_status!=='open')throw new CalculationConflict('Reabra a comissão antes de salvar.');
 const find=(employee:string,revision:number)=>{const r=s.records.find(r=>r.employee===employee);if(!r||r.revision!==revision)throw new CalculationConflict('Registro alterado. Atualize antes de salvar.');return r;};
 const latest=(rows:any[])=>[...rows].sort((a,b)=>b.month.localeCompare(a.month))[0];
 const rates={unimed:latest(s.unimed_rates),uniodonto:latest(s.uniodonto_fixed_rates)};
 const base=(employee:string)=>latest(s.versions.filter(v=>v.employee===employee));
 const packed=(r:any,d:any)=>({employee:r.employee,revision:r.revision,data:JSON.stringify(d)});
 if(action==='commission_value'){
  const row=find(body.employee,body.revision),d=JSON.parse(row.data),v=base(body.employee),b=v?JSON.parse(v.data):{},type=b.P||b.commissionType||d.P||d.commissionType;
  if(!type)throw new CalculationInputError('Marque uma opção de comissão no cadastro.');
  const days=commissionDays(month),calendar=s.dsr_settings.find(r=>r.month===month);
  Object.assign(d,commissionAmounts(body.amount,body.net,calendar?.useful??days.useful,calendar?.rest??days.rest,days.total));d.P=type;
  return [packed(row,applyProvisions(d))];
 }
 if(action==='health_copart_bulk'||action==='health_monthly_bulk'){
  if(!['unimed','uniodonto'].includes(body.plan)||!Array.isArray(body.rows)||!body.rows.length||body.rows.length>1000)throw new CalculationInputError('Lançamentos inválidos.');
  if(new Set(body.rows.map((r:any)=>r.employee)).size!==body.rows.length)throw new CalculationInputError('Colaboradores duplicados.');
  if(action==='health_monthly_bulk'&&!rates[body.plan as 'unimed'|'uniodonto'])throw new CalculationInputError('Configure a mensalidade do plano antes de lançar valores adicionais.');
  return body.rows.map((item:any)=>{
   const row=find(item.employee,item.revision),d=JSON.parse(row.data);if(d._excluded)throw new CalculationInputError('Colaborador não incluído na folha.');
   d.healthMembers=membersFromLegacy(d);d.healthCopart={...copartFromLegacy(d)};
   if(!item.amounts||typeof item.amounts!=='object'||Array.isArray(item.amounts))throw new CalculationInputError('Coparticipação inválida.');
   if(action==='health_monthly_bulk')d.healthMonthlyAdditions={...(d.healthMonthlyAdditions||{})};
   const valid=new Set(d.healthMembers.filter((m:any)=>m.plan===body.plan).map((m:any)=>m.id));
   for(const [id,value] of Object.entries(item.amounts)){
    if(!valid.has(id))throw new CalculationInputError('Participante alterado. Atualize antes de salvar.');
    if(action==='health_monthly_bulk'){
     const member=d.healthMembers.find((m:any)=>m.id===id);
     if(member.plan==='unimed'&&!validHealthBirthDate(member.role==='titular'?d.F:member.birthDate))throw new CalculationInputError('Informe uma data de nascimento válida no cadastro do participante.');
     if(!/^\d{1,8}(\.\d{1,2})?$/.test(String(value)))throw new CalculationInputError('Mensalidade inválida. Informe um valor em reais com até duas casas decimais.');
     d.healthMonthlyAdditions[id]=(Math.round(Number(value)*100)/100).toFixed(2);
    }else d.healthCopart[id]=value;
   }
   Object.assign(d,validateBenefits(d));return packed(row,applyProvisions(applyHealthRates(d,month,rates)));
  });
 }
 if(action==='health_sync'||action==='health_copart'){
  const row=find(body.employee,body.revision),d=JSON.parse(row.data);d.healthMembers=membersFromLegacy(d);d.healthCopart=copartFromLegacy(d);
  if(action==='health_sync'){
   const v=base(body.employee);if(!v)throw new CalculationInputError('Cadastro vigente não encontrado.');
   const next=membersFromLegacy(JSON.parse(v.data));
   if(d.healthMembers.some((m:any)=>Number(d.healthCopart[m.id])>0&&!next.some((n:any)=>n.id===m.id)))throw new CalculationInputError('Há coparticipação de participante removido. Ajuste o lançamento antes de atualizar o cadastro.');
   d.healthMembers=next;
  }else d.healthCopart=body.amounts;
  Object.assign(d,validateBenefits(d));return [packed(row,applyHealthRates(d,month,rates))];
 }
 throw new CalculationInputError('Operação inválida.');
}
export async function saveRecordAction(body:any,actor:string){
 const {snapshot,token}=await supabaseAdminRequest<{snapshot:Snapshot;token:string}>('/rest/v1/rpc/finance_record_action_snapshot',{method:'POST',body:{p_month:body.month}});
 let records;try{records=recordActionUpdates(snapshot,body);}catch(e){if(e instanceof CalculationConflict||e instanceof CalculationInputError)throw e;throw new CalculationInputError(e instanceof Error?e.message:'Dados inválidos.');}
 const saved=await supabaseAdminRequest<boolean>('/rest/v1/rpc/save_finance_record_action',{method:'POST',body:{p_month:body.month,p_action:body.action,p_actor:actor,p_token:token,p_records:records}});
 if(!saved)throw new CalculationConflict('A competência, o calendário ou os registros mudaram. Atualize antes de salvar.');
 return {ok:true};
}
