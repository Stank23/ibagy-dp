import {applyBenefits,membersFromLegacy,copartFromLegacy} from './benefits';
import {applyChildcare} from './childcare';
import {applyProvisions} from './provisions';
import {applyHealthRates} from './health-pricing';
// One read batch and one guarded write batch replace per-employee round trips.
export async function refreshMonth(db:any,month:string){
 const [records,rates,fixed,normative,children,loans]=await db.batch([
 db.prepare("SELECT r.*,v.data AS base_data FROM records r JOIN periods p ON p.month=r.month LEFT JOIN versions v ON v.employee=r.employee AND v.month=(SELECT MAX(month) FROM versions WHERE employee=r.employee AND month<=r.month) WHERE r.month=? AND p.status='open' AND COALESCE(json_extract(r.data,'$._excluded'),0)!=1").bind(month),
 db.prepare('SELECT * FROM unimed_rates WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month),
 db.prepare('SELECT * FROM uniodonto_fixed_rates WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month),
 db.prepare('SELECT amount FROM normative_wages WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month),
 db.prepare('SELECT * FROM childcare_children ORDER BY employee,id'),
 db.prepare('SELECT employee,SUM(amount) AS total FROM installments WHERE month=? GROUP BY employee').bind(month)]);
 const byEmployee=new Map<string,any[]>();for(const child of children.results){const list=byEmployee.get(child.employee)||[];list.push(child);byEmployee.set(child.employee,list);}
 const loanTotals=new Map<string,number>(loans.results.map((r:any)=>[r.employee,Number(r.total)]));
 const statements=[];const rate={unimed:rates.results[0],uniodonto:fixed.results[0]};
 for(const row of records.results){const old=JSON.parse(row.data),base=row.base_data?JSON.parse(row.base_data):old;let next={...old,AI:((loanTotals.get(row.employee)||0)/100).toFixed(2),_serefiAuto:loanTotals.get(row.employee)||0};
 next.P=base.P||base.commissionType||'';next.commissionType=next.P;
 if(Array.isArray(base.healthMembers)){
 const copart=copartFromLegacy(old),members=membersFromLegacy(base);if(membersFromLegacy(old).some((m:any)=>Number(copart[m.id])>0&&!members.some((n:any)=>n.id===m.id)))throw Error('Há coparticipação de participante removido. Ajuste o lançamento antes de atualizar o cadastro.');
 next.healthMembers=members;next.healthCopart=copart;
 }
 if(rate.unimed)next.F=base.F;
 next=applyProvisions(applyHealthRates(applyChildcare(applyBenefits(next),normative.results[0],byEmployee.get(row.employee)||[],month),month,rate));
 if(JSON.stringify(old)===JSON.stringify(next))continue;
 const guard=" AND (SELECT month||':'||revision FROM unimed_rates WHERE month<=? ORDER BY month DESC LIMIT 1) IS ? AND (SELECT month||':'||revision FROM uniodonto_fixed_rates WHERE month<=? ORDER BY month DESC LIMIT 1) IS ?";
 const args=[month,rate.unimed?rate.unimed.month+':'+rate.unimed.revision:null,month,rate.uniodonto?rate.uniodonto.month+':'+rate.uniodonto.revision:null];
 statements.push(db.prepare("UPDATE records SET data=?,revision=revision+1 WHERE month=? AND employee=? AND revision=? AND EXISTS(SELECT 1 FROM periods WHERE month=? AND status='open')"+guard).bind(JSON.stringify(next),month,row.employee,row.revision,month,...args));
 }
 for(let i=0;i<statements.length;i+=80)await db.batch(statements.slice(i,i+80));return {changed:statements.length};
}
