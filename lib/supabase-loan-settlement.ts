import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {calculate} from './finance-service';
import {applyProvisions} from './provisions';
import {preserveCommission} from './period-locks';
import {snapshotContext,CalculationConflict,CalculationInputError,type CalculationSnapshot} from './supabase-calculation';
import {validMonth} from './rules';

type Row=Record<string,any>;
export type LoanSettlementSnapshot={loan:Row|null;installments:Row[];calculations:{month:string;snapshot:CalculationSnapshot}[]};
export function settlementInput(body:Row){
 if(typeof body.loan!=='string'||!body.loan||body.loan.length>120||!validMonth(body.month))throw new CalculationInputError('Empréstimo ou competência inválidos.');
 if(typeof body.paymentDate!=='string'||!/^20\d{2}-\d{2}-\d{2}$/.test(body.paymentDate)||body.paymentDate.slice(0,7)!==body.month||(!Number.isFinite(Date.parse(body.paymentDate+'T12:00:00Z'))||new Date(body.paymentDate+'T12:00:00Z').toISOString().slice(0,10)!==body.paymentDate))throw new CalculationInputError('Informe uma data válida de pagamento na competência selecionada.');
 if(typeof body.reference!=='string'||body.reference.trim().length>200)throw new CalculationInputError('Referência do pagamento inválida.');
 return {loan:body.loan,month:body.month,paymentDate:body.paymentDate,reference:body.reference.trim()};
}
export async function settlementChanges(s:LoanSettlementSnapshot,body:Row){
 const input=settlementInput(body),loan=s.loan;
 if(!loan||loan.id!==input.loan||loan.settled_month)throw new CalculationConflict('Empréstimo inexistente ou já quitado. Atualize os dados.');
 const current=s.calculations.find(c=>c.month===input.month);
 if(current?.snapshot.period?.status!=='open')throw new CalculationConflict('Abra ou reabra a competência do pagamento antes de quitar.');
 const remaining=s.installments.filter(i=>i.month>=input.month),amount=remaining.reduce((sum,i)=>sum+Number(i.amount),0);
 if(!Number.isSafeInteger(amount)||amount<=0)throw new CalculationConflict('Não há parcelas a quitar nesta competência.');
 if(s.calculations.some(c=>c.snapshot.period?.status==='closed'&&remaining.some(i=>i.month===c.month&&Number(i.amount)>0)))throw new CalculationConflict('Há parcela em competência fechada. Reabra essa competência antes de quitar.');
 if(s.calculations.some(c=>c.snapshot.records.some(r=>r.employee===loan.employee&&JSON.parse(r.data)._termination)))throw new CalculationConflict('Há rescisão neste período. Confira a quitação com o fechamento da rescisão antes de continuar.');
 const records=await Promise.all(s.calculations.flatMap(c=>{
  if(c.snapshot.period?.status!=='open')return [];
  const snapshot={...c.snapshot,installments:c.snapshot.installments.map(i=>i.loan===loan.id?{...i,amount:0}:i)};
  const context=snapshotContext(snapshot);
  return snapshot.records.filter(r=>r.employee===loan.employee&&!JSON.parse(r.data)._excluded).map(async r=>{
   const old=JSON.parse(r.data),next=await calculate(null,old,r.employee,c.month,context);
   return {month:c.month,employee:r.employee,revision:r.revision,data:JSON.stringify(applyProvisions(preserveCommission(next,old,snapshot.period)))};
  });
 }));
 return {amount,records,input};
}
export async function saveLoanSettlement(body:Row,actor:string){
 const input=settlementInput(body);
 const {snapshot,token}=await supabaseAdminRequest<{snapshot:LoanSettlementSnapshot;token:string}>('/rest/v1/rpc/finance_loan_settlement_snapshot',{method:'POST',body:{p_loan:input.loan,p_month:input.month}});
 const result=await settlementChanges(snapshot,body);
 if(body.action==='loan_settlement_preview')return {ok:true,token,amount:result.amount,months:result.records.map(r=>r.month)};
 if(typeof body.token!=='string'||body.token!==token)throw new CalculationConflict('Os dados mudaram. Confira uma nova prévia da quitação.');
 if(!await supabaseAdminRequest<boolean>('/rest/v1/rpc/settle_finance_loan',{method:'POST',body:{p_loan:input.loan,p_month:input.month,p_date:input.paymentDate,p_reference:input.reference,p_actor:actor,p_token:token,p_records:result.records}}))throw new CalculationConflict('A folha ou o empréstimo mudou. Confira uma nova prévia.');
 return {ok:true,amount:result.amount};
}
