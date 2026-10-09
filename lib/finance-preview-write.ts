import 'server-only';
import {assertSameOrigin,readJSON,securityError} from './request-security';
import {localUser} from './local-auth';
import {supabaseAdminRequest} from './supabase-admin';
import {jobFunctionName} from './job-functions';
import {validCPF,formatCPF} from './cpf';
import {schedule} from './rules';
import {cents} from './payroll';
import {saveCalculatedPeriod} from './supabase-calculation-store';
import {CalculationConflict} from './supabase-calculation';
import {reserveAuthAttempt} from './supabase-rate-limit';

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
  if(action==='period'||action==='recalculate'){
   if(!await reserveAuthAttempt('finance-write',user.userId,120,60000))return reply({error:'Limite de requisições atingido. Aguarde antes de tentar novamente.'},429);
   const saved=await saveCalculatedPeriod(body.month,action,user.email);
   if(!saved)return reply({error:'Competência ou dados alterados. Atualize antes de calcular novamente.'},409);
   return reply({ok:true});
  }
  if(action==='loan'){
   const amount=String(body.amount??'');
   if(!/^\d{1,8}(\.\d{1,2})?$/.test(amount))return reply({error:'Valor inválido.'},400);
   const total=cents(amount),count=Number(body.count),employee=body.employee;
   if(typeof employee!=='string'||employee.length<1||employee.length>120)return reply({error:'Selecione um colaborador.'},400);
   let parts:ReturnType<typeof schedule>;
   try{parts=schedule(total,count,body.month);}catch{return reply({error:'Informe valor positivo e de 1 a 120 parcelas.'},400);}
   const end=parts[parts.length-1].month;
   if(body.end!==end)return reply({error:'O mês final deve corresponder à quantidade de parcelas.'},400);
   const id=crypto.randomUUID();
   const saved=await supabaseAdminRequest<boolean>('/rest/v1/rpc/register_finance_loan',{method:'POST',body:{p_id:id,p_employee:employee,p_month:body.month,p_end:end,p_total:total,p_parts:parts,p_actor:user.email}});
   if(!saved)return reply({error:'Colaborador inexistente ou competência fechada. Atualize os dados.'},409);
   return reply({ok:true,id});
  }
  if(action==='employee'){
   if(body.id)return reply({error:'Edição de colaboradores ainda não integrada. Nenhum dado foi alterado.'},503);
   const data=body.data;
   if(!data||typeof data!=='object'||Array.isArray(data))return reply({error:'Cadastro inválido.'},400);
   const d={...(data as Row)};
   if(typeof d.E!=='string'||!validCPF(d.E))return reply({error:'CPF inválido. Confira os dígitos antes de cadastrar.'},400);
   if(typeof d.B!=='string'||!d.B.trim()||typeof d.C!=='string'||!d.C.trim()||typeof d.H!=='string'||!d.H.trim()||typeof d.D!=='string'||!/^20\d{2}-(0[1-9]|1[0-2])-[0-3]\d$/.test(d.D))return reply({error:'Preencha matrícula, nome, data de admissão e filial.'},400);
   if(d.B.length>80||d.C.length>180||d.H.length>120)return reply({error:'Cadastro excede o tamanho permitido.'},400);
   d.E=formatCPF(d.E);d.AG='0.00';d.receivesVA=d.receivesVA!==false;
   const id=crypto.randomUUID();
   const saved=await supabaseAdminRequest<boolean>('/rest/v1/rpc/register_finance_employee',{method:'POST',body:{p_id:id,p_registration:d.B,p_month:body.month,p_effective:d.D.slice(0,7),p_data:d,p_actor:user.email,p_active:body.active===false?0:1}});
   if(!saved)return reply({error:'CPF ou matrícula já cadastrado.'},409);
   return reply({ok:true,id});
  }
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
  if(e instanceof CalculationConflict)return reply({error:e.message},409);
  const security=securityError(e);if(security)return security;
  console.error('Finance preview state transition failed');
  return reply({error:'Não foi possível salvar a alteração. Atualize os dados antes de tentar novamente.'},503);
 }
}
