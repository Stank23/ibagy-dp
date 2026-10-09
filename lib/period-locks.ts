export function commissionLocked(period:any){return period?.status==='closed'||period?.commission_status==='closed';}
export function preserveCommission(next:any,previous:any,period:any){
 if(!commissionLocked(period))return next;
 const result={...next};
 for(const key of ['U','T','P','commissionType','paid20','commissionNet','commissionIR','commissionUseful','commissionRest']){
  if(Object.hasOwn(previous,key))result[key]=previous[key];else delete result[key];
 }
 return result;
}
