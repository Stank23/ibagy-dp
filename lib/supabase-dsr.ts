import {dsrAffectedCity,dsrCities} from './dsr-city';
import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {commissionDays,commissionAmounts} from './commission';
import {CalculationInputError,CalculationConflict} from './supabase-calculation';
export function dsrChanges(snapshot:any,body:any){
 const city=body.city;if(city!==undefined&&!dsrCities.some(c=>c.id===city))throw new CalculationInputError('Cidade inválida.');
 const revision=body.revision??0;
 if(!Number.isSafeInteger(revision)||revision<0)throw new CalculationInputError('Calendário inválido. Atualize a página.');
 if(snapshot.period?.status==='closed'||snapshot.period?.commission_status==='closed')throw new CalculationConflict('Competência ou comissão fechada.');
 const calendar=snapshot.dsr_settings.find((r:any)=>r.month===body.month&&(city?r.city===city:!r.city||r.city==='all'));
 if((calendar?.revision??0)!==revision)throw new CalculationConflict('Calendário alterado. Atualize a página.');
 const total=commissionDays(body.month).total;let days;
 try{days=commissionAmounts('0','',body.useful,body.rest,total);}catch(e){throw new CalculationInputError((e as Error).message);}
 const records=[];
 for(const row of snapshot.records){
  const d=JSON.parse(row.data);if(!dsrAffectedCity(snapshot.dsr_settings,body.month,city,d.H))continue;let amounts;
  try{amounts=commissionAmounts(d.U||'0',d.commissionNet,days.commissionUseful,days.commissionRest,total);}catch(e){throw new CalculationInputError((e as Error).message);}
  if(d.P||d.commissionType||Number(d.U||0)>0){Object.assign(d,{T:amounts.T,commissionIR:amounts.commissionIR,commissionUseful:days.commissionUseful,commissionRest:days.commissionRest});records.push({employee:row.employee,revision:row.revision,data:JSON.stringify(d)});}
 }
 return {city,useful:days.commissionUseful,rest:days.commissionRest,revision,records};
}
export async function saveDsr(body:any,actor:string){
 const {snapshot,token}=await supabaseAdminRequest<any>('/rest/v1/rpc/finance_record_action_snapshot',{method:'POST',body:{p_month:body.month}});
 const c=dsrChanges(snapshot,body);
 if(!await supabaseAdminRequest<boolean>('/rest/v1/rpc/'+(c.city?'save_finance_city_dsr':'save_finance_dsr'),{method:'POST',body:{...(c.city?{p_city:c.city}:{}),p_month:body.month,p_actor:actor,p_token:token,p_useful:c.useful,p_rest:c.rest,p_revision:c.revision,p_records:c.records}}))throw new CalculationConflict('Calendário ou lançamentos alterados. Atualize antes de salvar.');
 return {ok:true};
}
