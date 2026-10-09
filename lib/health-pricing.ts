import {membersFromLegacy,copartFromLegacy,applyBenefits} from './benefits';
export function healthToday(){const parts=new Intl.DateTimeFormat('en',{timeZone:'America/Sao_Paulo',year:'numeric',month:'2-digit',day:'2-digit'}).formatToParts(new Date());const get=(type:string)=>parts.find(p=>p.type===type)?.value;return `${get('year')}-${get('month')}-${get('day')}`;}
export function validHealthBirthDate(birth:any,today=healthToday()){
 if(typeof birth!=='string'||!/^\d{4}-\d{2}-\d{2}$/.test(birth)||birth>today)return false;
 const date=new Date(birth+'T00:00:00Z');return Number.isFinite(date.getTime())&&date.toISOString().slice(0,10)===birth;
}
export function ageInMonth(birth:any,month:string){
 if(typeof birth!=='string'||!/^\d{4}-\d{2}-\d{2}$/.test(birth)||!/^20\d{2}-(0[1-9]|1[0-2])$/.test(month))return null;
 const date=new Date(birth+'T00:00:00Z');if(!Number.isFinite(date.getTime())||date.toISOString().slice(0,10)!==birth)return null;
 const end=new Date(Date.UTC(Number(month.slice(0,4)),Number(month.slice(5,7)),0)).toISOString().slice(0,10);if(birth>end)return null;
 return Number(month.slice(0,4))-Number(birth.slice(0,4))-(month.slice(5,7)<birth.slice(5,7)?1:0);
}
export function activeHealthRate(rates:any[],month:string){return rates.filter(r=>r.month<=month).sort((a,b)=>b.month.localeCompare(a.month))[0];}
export function applyHealthRates(data:any,month:string,rates:any,strict=false){
 const members=membersFromLegacy(data);if(!members.length)return Array.isArray(data.healthMembers)?applyBenefits({...data,_healthEmployerShare:true}):data;
 const next=members.map((m:any)=>{const rate=rates?.[m.plan];
 if(m.plan==='uniodonto'){if(strict&&!rate)throw Error('Configure a mensalidade única da Uniodonto para esta competência.');return rate?{...m,monthly:(Number(rate.amount)/100).toFixed(2)}:m;}
 if(m.plan!=='unimed')return m;const birthDate=m.role==='titular'?data.F:m.birthDate,age=ageInMonth(birthDate,month);
 if(strict&&!validHealthBirthDate(birthDate))throw Error('Informe uma data de nascimento válida para '+(m.role==='titular'?'o titular no cadastro do colaborador':m.name||'o dependente')+'.');
 if(strict&&!rate)throw Error('Configure os valores da Unimed para esta competência.');
 if(!rate||!validHealthBirthDate(birthDate))return m;
 if(birthDate.slice(0,7)>month)return {...m,birthDate,monthly:'0.00'};
 if(age===null)return m;return {...m,birthDate,monthly:(Number(age<=43?rate.young:age<=58?rate.middle:rate.senior)/100).toFixed(2)};});
 return applyBenefits({...data,_healthEmployerShare:true,healthMembers:next.map((m:any)=>Object.hasOwn(data.healthMonthlyAdditions||{},m.id)?{...m,monthly:((Math.round(Number(m.monthly||0)*100)+Math.round(Number(data.healthMonthlyAdditions[m.id]||0)*100))/100).toFixed(2)}:m),healthCopart:copartFromLegacy(data)});
}
