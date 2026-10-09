export const inPayroll=(data:any)=>data._excluded!==true;
export const eligibleForMonth=(employee:any,month:string)=>employee.active===1&&/^\d{4}-\d{2}-\d{2}$/.test(employee.values.D||'')&&employee.values.D.slice(0,7)<=month;
