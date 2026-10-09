import 'server-only';
import {assertSameOrigin,readJSON,securityError} from './request-security';
import {localUser} from './local-auth';
import {supabaseAdminRequest} from './supabase-admin';
import {jobFunctionName} from './job-functions';

type Row=Record<string,unknown>;
const validMonth=(m:unknown):m is string=>typeof m==='string'&&/^20\d{2}-(0[1-9]|1[0-2])$/.test(m);
const reply=(data:unknown,status=200)=>Response.json(data,{status,headers:{'Cache-Control':'no-store'}});
/** Only state transitions whose original rules are preserved and enforceable in Postgres.
 * All other payroll mutations remain disabled until the calculation engine is migrated.
 */
export async function financePreviewWrite(request:Request):Promise<Response>{
 try{
  assertSameOrigin(request);
  const user=await localUser();
  if(!user)return reply({error:'Acesso restrito.'},401);
  if(user.role!=='admin')return reply({error:'Somente o administrador pode alterar os dados.'},403);
  const body=await readJSON(request) as Row;
  if(!validMonth(body.month))return reply({error:'Informe uma competência válida.'},400);
  const action=String(body.action||'');
  if(action==='job_function'){
   let functionName:{name:string;key:string};
   try{functionName=jobFunctionName(body.name);}catch{return reply({error:'Informe uma função válida com até 180 caracteres.'},400);}
   const name=await supabaseAdminRequest<string>('/rest/v1/rpc/save_job_function',{method:'POST',body:{p_name:functionName.name,p_key:functionName.key,p_actor:user.email,p_month:body.month}});
   return reply({ok:true,name});
  }
  if(['minimum_wage','allowance','unimed_rates','uniodonto_fixed_rate'].includes(action)){
   const revision=Number(body.revision??0);
   if(!Number.isSafeInteger(revision)||revision<0)return reply({error:'Revisão inválida.'},400);
   const keys=action==='unimed_rates'?['young','middle','senior']:['amount'];
   const values=Object.fromEntries(keys.map(key=>[key,body[key]]));
   if(keys.some(key=>typeof values[key]!=='string'&&typeof values[key]!=='number'))return reply({error:'Preencha os valores da configuração.'},400);
   const changed=await supabaseAdminRequest<boolean>('/rest/v1/rpc/save_finance_configuration',{
    method:'POST',body:{p_month:body.month,p_action:action,p_values:values,p_actor:user.email,p_revision:revision}
   });
   if(!changed)return reply({error:'Configuração alterada. Atualize antes de salvar.'},409);
   return reply({ok:true});
  }
  if(!['close','reopen','commission_close','commission_reopen'].includes(action)){
   return reply({error:'Operação ainda não migrada para o Supabase. Nenhum dado foi alterado.'},503);
  }
  const month=body.month;
  const reason=String(body.reason||'').trim();
  if((action==='reopen'||action==='commission_reopen')&&reason.length<5)
   return reply({error:'Informe o motivo da reabertura.'},400);
  // RPC executes status transition and audit in one PostgreSQL transaction.
  // Until the SQL migration is applied, Supabase rejects the call without changing data.
  const changed=await supabaseAdminRequest<boolean>('/rest/v1/rpc/transition_finance_period',{
   method:'POST',
   body:{p_month:month,p_action:action,p_actor:user.email,p_reason:reason}
  });
  if(changed!==true)return reply({error:'Competência não encontrada ou situação alterada. Atualize os dados.'},409);
  return reply({ok:true});
 }catch(e){
  const security=securityError(e);if(security)return security;
  console.error('Finance preview state transition failed');
  return reply({error:'Não foi possível salvar a alteração. Atualize os dados antes de tentar novamente.'},503);
 }
}
