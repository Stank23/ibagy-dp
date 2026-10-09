import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {eventPlan} from './event-installments';
import {CalculationConflict,CalculationInputError} from './supabase-calculation';
export function eventPlanInput(body:any){
 if(typeof body.id!=='string'||!/^[-a-zA-Z0-9]{20,80}$/.test(body.id)||typeof body.employee!=='string'||!body.employee||body.employee.length>120)throw new CalculationInputError('Identificador de parcelamento ou colaborador inválido.');
 let plan;try{plan=eventPlan(body);}catch(e){throw new CalculationInputError((e as Error).message);}
 if(plan.start<body.month)throw new CalculationInputError('Escolha a competência selecionada ou posterior para preservar o histórico.');
 return {id:body.id,employee:body.employee,...plan};
}
export async function saveEventPlan(body:any,actor:string){
 const plan=eventPlanInput(body);
 if(!await supabaseAdminRequest<boolean>('/rest/v1/rpc/register_finance_event_plan',{method:'POST',body:{p_month:body.month,p_actor:actor,p_plan:plan}}))throw new CalculationConflict('Parcelamento existente, colaborador alterado ou período com competência fechada. Atualize os dados.');
 return {ok:true,id:plan.id};
}
