import {applyBenefits} from './benefits';
const cent=(v:any)=>Math.round(Number(v||0)*100);
const value=(n:number)=>(n/100).toFixed(2);
export const automaticCostKeys=['Q','CR','CQ','CS','CT','CY','CZ','DA','DB','DC','DD','DE','DF'];
export function applyProvisions(data:any){
 const d=applyBenefits(data),salary=cent(d.O),commission=cent(d.commissionNet),indication=cent(d.W);
 d.Q=value(commission);d._payrollTransfers=true;d.CR=value(Math.round(salary*11/100));d.CQ=value(Math.round((salary+commission)*8/100));d.CS=value(salary+['U','V','T','W','X','Z','AA'].reduce((s,k)=>s+cent(d[k]),0));d.CT=value(cent(d.CQ)+cent(d.CR));d.CY=value(['CV','CW','CX'].reduce((s,k)=>s+cent(d[k]),0));
 const provision=Math.round((salary+commission+indication)/12),third=Math.round(provision/3),base=provision*2+third,fgts=Math.round(base*8/100),inss=Math.round(base*20/100),total=base+fgts+inss;
 Object.assign(d,{CZ:value(provision),DA:value(provision),DB:value(third),DC:value(fgts),DD:value(inss),DE:value(total),DF:value(cent(d.CS)+cent(d.AG)+cent(d.CT)+cent(d.CY)+cent(d.AP)+total),_provisionPending:''});return d;
}
export async function refreshProvisions(db:any,month:string){
 const rows=await db.prepare("SELECT r.* FROM records r JOIN periods p ON p.month=r.month WHERE r.month=? AND p.status='open' AND COALESCE(json_extract(r.data,'$._excluded'),0)!=1").bind(month).all();
 const statements=[];for(const row of rows.results){const old=JSON.parse(row.data),next=applyProvisions(old);if([...automaticCostKeys,'_provisionPending'].some(k=>old[k]!==next[k]))statements.push(db.prepare("UPDATE records SET data=?,revision=revision+1 WHERE month=? AND employee=? AND revision=? AND EXISTS(SELECT 1 FROM periods WHERE month=? AND status='open')").bind(JSON.stringify(next),month,row.employee,row.revision,month));}
 for(let start=0;start<statements.length;start+=80)await db.batch(statements.slice(start,start+80));
}
