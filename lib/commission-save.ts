import {commissionAmounts} from './commission';

type CommissionRecord = {employee:string;revision:number;values:Record<string,any>};
export function commissionChanges(records:CommissionRecord[], amounts:Record<string,string>, nets:Record<string,string>, month:string, useful:number, rest:number, total:number){
  return records.filter(r=>r.values.P||r.values.commissionType).flatMap(r=>{
    const amount=amounts[r.employee]??r.values.U??'0.00';
    const net=nets[r.employee]??r.values.commissionNet??'';
    if(Number(amount||0)===Number(r.values.U||0)&&String(net)===String(r.values.commissionNet??''))return [];
    commissionAmounts(amount||'0.00',net,useful,rest,total);
    return [{action:'commission_value',month,employee:r.employee,revision:r.revision,amount:amount||'0.00',net}];
  });
}
export async function saveCommissionChanges(changes:ReturnType<typeof commissionChanges>,mutate:(body:any)=>Promise<any>){
  const failed:string[]=[];
  for(const change of changes){try{if(!await mutate(change))failed.push(change.employee);}catch{failed.push(change.employee);}}
  return failed;
}
