import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {calculatedRecords,editedRecord,type CalculationSnapshot} from './supabase-calculation';

export async function saveCalculatedPeriod(month:string,action:'period'|'recalculate',actor:string):Promise<boolean> {
  const {snapshot,token} = await supabaseAdminRequest<{snapshot:CalculationSnapshot;token:string}>('/rest/v1/rpc/finance_calculation_snapshot',{method:'POST',body:{p_month:month}});
  const records = await calculatedRecords(snapshot,month,action);
  // Reject any change to the source inputs, period status, or record revisions.
  return supabaseAdminRequest<boolean>('/rest/v1/rpc/save_calculated_finance_period',{method:'POST',body:{p_month:month,p_action:action,p_actor:actor,p_token:token,p_records:records}});
}

export async function saveEditedRecord(month:string,employee:string,data:unknown,revision:number,actor:string):Promise<boolean> {
  const {snapshot,token}=await supabaseAdminRequest<{snapshot:CalculationSnapshot;token:string}>('/rest/v1/rpc/finance_calculation_snapshot',{method:'POST',body:{p_month:month}});
  const records=await editedRecord(snapshot,month,employee,data,revision);
  return supabaseAdminRequest<boolean>('/rest/v1/rpc/save_calculated_finance_period',{method:'POST',body:{p_month:month,p_action:'record',p_actor:actor,p_token:token,p_records:records}});
}
