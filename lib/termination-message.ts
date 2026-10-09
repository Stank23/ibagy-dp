import {cents,money} from './payroll';
import {value} from './rules';
import {membersFromLegacy,copartFromLegacy,healthMonthlyShare} from './benefits';
const ref=(month:string)=>`${month.slice(5)}/${month.slice(0,4)}`;
export function terminationMessage(month:string,d:any,summary:any){
 const variable=(key:string,label:string)=>`${label} ${money(d[key])} (Ref. ${ref(month)} ${money(d[key])})`;
 const members=membersFromLegacy(d),copart=copartFromLegacy(d);
 const health=(plan:string,role:string,co=false)=>money(value(members.filter((m:any)=>m.plan===plan&&m.role===role).reduce((s:number,m:any)=>s+cents(co?copart[m.id]:healthMonthlyShare(m,d._healthEmployerShare===true).net),0)));
 const fine=Math.max(0,cents(d.AM)-Number(d._eventAutoAM||0))+cents(summary.fineRemaining);
 const courses=Math.max(0,cents(d.CK)-Number(d._eventAutoCK||0))+cents(summary.coursesRemaining);
 const pendingLoan=cents(summary.loanRemaining),pendingFine=cents(summary.fineRemaining),pendingCourses=cents(summary.coursesRemaining),pendingTotal=pendingLoan+pendingFine+pendingCourses;
 const loan=summary.loanRemaining!==undefined?value(Math.max(0,cents(d.AI)-Number(d._serefiAuto||0))+pendingLoan):(summary.loan??d.AI);
 const paid=summary.foodAlreadyPaid??Number(summary.foodPaid||0)>0;
 return [
 'Segue lançamentos para rescisão:',`Colaborador: ${d.C||''}${d.B?' · Matrícula '+d.B:''}`,'',
 'Proventos',variable('U','Comissão (90)'),variable('T','DSR (91)'),
 `Ticket (1779) ${money(paid?(summary.foodPaid??summary.foodFull??'1500.00'):(summary.foodDue??d.AP))}`,
 `Auxílio Creche (3614) ${money(summary.childcare??d.AG)}`,'',
 'Descontos',`Empréstimo Serefi (1865) ${money(loan)}`,`Serefi (2373) ${money(summary.serefi??d.AL)}`,
 `VA (1598) ${money(d.AN)}`,`Desconto Ticket (1483) ${money(summary.foodRefund??d.AQ)}`,`Farmácia (806) ${money(d.AE)}`,`Multa (1071) ${money(value(fine))}`,
 ...(courses>0?[`Cursos (2233) ${money(value(courses))}`]:[]),...(pendingTotal>0?['',`Total de parcelamentos pendentes: ${money(value(pendingTotal))} (já incluído nos descontos acima)`]:[]),'',
 `Unimed Mensalidade Titular: ${health('unimed','titular')} (Ref. ${ref(month)})`,
 `Unimed Mensalidade Dependente: ${health('unimed','dependente')}`,
 `Unimed Coparticipação Titular: ${health('unimed','titular',true)}`,
 `Unimed Coparticipação Dependente: ${health('unimed','dependente',true)}`,
 `Uniodonto Mensalidade Titular: ${health('uniodonto','titular')}`,
 `Uniodonto Mensalidade Dependente: ${health('uniodonto','dependente')}`,
 ].join('\n');
}
