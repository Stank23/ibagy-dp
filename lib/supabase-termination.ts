import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {calculate} from './finance-service';
import {terminationDate,terminationSummary} from './termination';
import {terminationMessage} from './termination-message';
import {remainingEvents} from './event-installments';
import {value} from './rules';
import {cents} from './payroll';
import {snapshotContext,CalculationConflict,CalculationInputError} from './supabase-calculation';
export async function terminationChanges(s:any,body:any){
 if(s.period?.status!=='open')throw new CalculationConflict('Abra ou reabra a competência antes de registrar a rescisão.');
 const row=s.records.find((r:any)=>r.employee===body.employee);if(!row||row.revision!==body.revision)throw new CalculationConflict('Registro alterado. Atualize antes de continuar.');
 const original=JSON.parse(row.data);let date;try{date=terminationDate(original.D,body.month,String(body.date||''));}catch(e){throw new CalculationInputError((e as Error).message);}
 if(original._terminationCarry)throw new CalculationConflict('A rescisão já foi registrada em uma competência anterior.');
 const context=snapshotContext(s),monthly=await calculate(null,{...original,lastWorkedDay:undefined},body.employee,body.month,context);
 let d=await calculate(null,{...original,G:'Rescisão',lastWorkedDay:date,_excluded:true,_termination:true},body.employee,body.month,context);
 const eventsRemaining=remainingEvents(s.remaining_event_plans,body.month),balance=s.remaining_installments.reduce((sum:number,r:any)=>sum+Number(r.amount),0);
 d.AI=value(balance);d._serefiAuto=balance;
 try{d._terminationSettlement={...terminationSummary(d,body.month,body.foodAlreadyPaid,monthly),...eventsRemaining,loanRemaining:value(balance),installmentsRemaining:value(cents(eventsRemaining.installmentsRemaining)+balance)};}catch(e){throw new CalculationInputError((e as Error).message);}
 d.AQ=d._terminationSettlement.foodRefund;
 if(body.action==='termination_preview')return {preview:true,response:{ok:true,values:d,summary:d._terminationSettlement,message:terminationMessage(body.month,d,d._terminationSettlement)}};
 if(s.period.commission_status==='closed'&&Number(original.U)>0)throw new CalculationConflict('Reabra a comissão para registrar a rescisão deste colaborador.');
 if(s.future_records.some((r:any)=>r.status==='closed'||r.commission_status==='closed'))throw new CalculationConflict('Há uma competência posterior fechada para este colaborador. Reabra antes de registrar a demissão.');
 const v=s.versions.filter((v:any)=>v.employee===body.employee&&v.month<=body.month).sort((a:any,b:any)=>b.month.localeCompare(a.month))[0];if(!v)throw new CalculationInputError('Cadastro não encontrado.');
 return {preview:false,data:JSON.stringify(d),base:JSON.stringify({...JSON.parse(v.data),G:'Rescisão',terminationDate:date}),date,response:{ok:true}};
}
export async function saveTermination(body:any,actor:string){
 if(typeof body.employee!=='string'||!body.employee||body.employee.length>120||!Number.isSafeInteger(body.revision)||body.revision<1)throw new CalculationInputError('Lançamento ou revisão inválidos.');
 const {snapshot,token}=await supabaseAdminRequest<any>('/rest/v1/rpc/finance_termination_snapshot',{method:'POST',body:{p_month:body.month,p_employee:body.employee}});
 const c=await terminationChanges(snapshot,body);if(c.preview)return c.response;
 if(!await supabaseAdminRequest<boolean>('/rest/v1/rpc/save_finance_termination',{method:'POST',body:{p_month:body.month,p_employee:body.employee,p_actor:actor,p_token:token,p_revision:body.revision,p_data:c.data,p_base:c.base,p_date:c.date}}))throw new CalculationConflict('Registro, cadastro, parcelas ou competência alterados. Atualize antes de salvar.');
 return c.response;
}
