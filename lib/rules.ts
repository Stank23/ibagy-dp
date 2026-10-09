import {cents} from './payroll';
export const validMonth=(m:any)=>typeof m==='string'&&/^20\d{2}-(0[1-9]|1[0-2])$/.test(m);
export const value=(n:number)=>(n/100).toFixed(2);
export function nationalMinimum(month:string,configured:Array<{month:string,amount:number}>=[]){const selected=configured.filter(r=>r.month<=month).sort((a,b)=>b.month.localeCompare(a.month))[0];if(selected)return selected.amount;if(month>='2026-01'&&month<='2026-12')return 162100;throw Error('Configure o salário mínimo vigente para o ano desta competência.');}
export function serefiMonthly(minimum:number,admission:string,month:string,lastWorkedDay?:string){return foodAllowance(Math.round(minimum*2/100),admission,month,lastWorkedDay);}
export function addMonths(month:string,count:number){if(!validMonth(month))throw Error('Competência inválida');const [y,m]=month.split('-').map(Number),n=y*12+m-1+count;return `${Math.floor(n/12)}-${String(n%12+1).padStart(2,'0')}`;}
export function quinquennium(salary:any,admission:string,month:string){if(!/^\d{4}-\d{2}-\d{2}$/.test(admission)||!validMonth(month))return 0;const [y,m]=month.split('-').map(Number),[ay,am]=admission.split('-').map(Number);const blocks=Math.max(0,Math.floor(((y-ay)*12+m-am)/60));return Math.round(cents(salary)*blocks*5/100);}
export function workedDays(admission:string,month:string,lastWorkedDay?:string){
 if(!validMonth(month)||!/^\d{4}-\d{2}-\d{2}$/.test(admission))return 30;
 if(admission.slice(0,7)>month||lastWorkedDay&&lastWorkedDay.slice(0,7)<month)return 0;
 const start=admission.slice(0,7)===month?Math.min(30,Number(admission.slice(8))):1;
 let end=30;
 if(lastWorkedDay?.slice(0,7)===month){const day=Number(lastWorkedDay.slice(8)),[year,m]=month.split('-').map(Number);end=day===new Date(Date.UTC(year,m,0)).getUTCDate()?30:Math.min(30,day);}
 return Math.max(0,end-start+1);
}
export function foodAllowance(full:number,admission:string,month:string,lastWorkedDay?:string){return Math.round(full*workedDays(admission,month,lastWorkedDay)/30);}
export function schedule(total:number,count:number,start:string){if(!Number.isSafeInteger(total)||total<=0||!Number.isInteger(count)||count<1||count>120||total<count||!validMonth(start))throw Error('Informe valor positivo e de 1 a 120 parcelas.');const regular=Math.floor(total/count);return Array.from({length:count},(_,i)=>({month:addMonths(start,i),number:i+1,principal:i===count-1?total-regular*(count-1):regular,fee:i===0?280:0,amount:(i===count-1?total-regular*(count-1):regular)+(i===0?280:0)}));}
export function automatic(data:any,month:string,food?:number,loanTotal=0){const d={...data};d.salaryCompetencia=value(foodAllowance(cents(d.K),d.D,month,d.lastWorkedDay));d.M=value(quinquennium(d.K,d.D,month));if(d.receivesVA===false)d.AP='0.00';else if(food!==undefined)d.AP=value(foodAllowance(food,d.D,month,d.lastWorkedDay));d.AI=value(loanTotal);d._serefiAuto=loanTotal;return d;}
