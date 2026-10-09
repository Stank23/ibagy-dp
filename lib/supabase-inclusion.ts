import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {calculate} from './finance-service';
import {snapshotContext,CalculationConflict,CalculationInputError} from './supabase-calculation';
export async function inclusionRecords(snapshot:any,month:string,employee:string){
 if(snapshot.period?.status!=='open')throw new CalculationConflict('Competência fechada.');
 if(typeof employee!=='string'||!employee||employee.length>120)throw new CalculationInputError('Selecione um colaborador.');
 const version=snapshot.versions.filter((v:any)=>v.employee===employee&&v.month<=month).sort((a:any,b:any)=>b.month.localeCompare(a.month))[0];
 if(!version||String(JSON.parse(version.data).D||'').slice(0,7)>month)throw new CalculationInputError('O colaborador só pode ser incluído a partir da competência de admissão.');
 if(snapshot.records.some((r:any)=>r.employee===employee))return [];
 return [{employee,data:JSON.stringify(await calculate(null,JSON.parse(version.data),employee,month,snapshotContext(snapshot)))}];
}
export async function saveInclusion(body:any,actor:string){
 const {snapshot,token}=await supabaseAdminRequest<any>('/rest/v1/rpc/finance_calculation_snapshot',{method:'POST',body:{p_month:body.month}});
 const records=await inclusionRecords(snapshot,body.month,body.employee);
 if(!await supabaseAdminRequest<boolean>('/rest/v1/rpc/include_finance_employee',{method:'POST',body:{p_month:body.month,p_employee:body.employee,p_actor:actor,p_token:token,p_records:records}}))throw new CalculationConflict('Competência ou cadastro alterados. Atualize antes de incluir.');
 return {ok:true};
}
