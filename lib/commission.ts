export function commissionDays(month:string){
 const [year,m]=month.split('-').map(Number),total=new Date(Date.UTC(year,m,0)).getUTCDate();
 const holidays=new Set(['01-01','04-21','05-01','09-07','10-12','11-02','11-15','12-25',...(year>=2024?['11-20']:[])]);
 let rest=0;for(let day=1;day<=total;day++){const date=new Date(Date.UTC(year,m-1,day));if(date.getUTCDay()===0||holidays.has(`${String(m).padStart(2,'0')}-${String(day).padStart(2,'0')}`))rest++;}
 return {useful:total-rest,rest,total};
}
export function commissionAmounts(amount:any,net:any,useful:any,rest:any,total:number){
 const cents=(v:any)=>{const s=String(v??'');if(!/^\d{1,10}(\.\d{1,2})?$/.test(s))throw Error('Informe um valor monetário válido.');return Math.round(Number(s)*100);};
 const u=Number(useful),r=Number(rest);if(!Number.isInteger(u)||!Number.isInteger(r)||u<1||r<0||u+r!==total)throw Error('Dias úteis e descansos devem somar os dias da competência.');
 const commission=cents(amount||'0'),dsr=Math.round(commission*r/u),hasNet=net!==''&&net!==undefined&&net!==null,n=hasNet?cents(net):0;
 if(hasNet&&n>commission+dsr)throw Error('O líquido não pode superar a comissão mais o DSR.');
 return {U:(commission/100).toFixed(2),T:(dsr/100).toFixed(2),commissionNet:hasNet?(n/100).toFixed(2):'',commissionIR:hasNet?((commission+dsr-n)/100).toFixed(2):'',commissionUseful:u,commissionRest:r};
}
export const commissionFinancialKeys=['U','T','commissionNet','commissionIR','commissionUseful','commissionRest'];
