import 'server-only';
import {assertSameOrigin,readJSON,securityError} from './request-security';
import {localUser} from './local-auth';
import {supabaseAdminRequest} from './supabase-admin';

type Row=Record<string,unknown>;
const validMonth=(m:unknown):m is string=>typeof m==='string'&&/^20\d{2}-(0[1-9]|1[0-2])$/.test(m);
const q=encodeURIComponent;
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
  if(!['close','reopen','commission_close','commission_reopen'].includes(action)){
   return reply({error:'Operação ainda não migrada para o Supabase. Nenhum dado foi alterado.'},503);
  }
  const month=body.month;
  const rows=await supabaseAdminRequest<Row[]>('/rest/v1/periods?select=month,status,commission_status&month=eq.'+q(month)+'&limit=1');
  const period=rows[0];
  if(!period)return reply({error:'Abra a competência antes de continuar.'},400);
  const reopening=action==='reopen'||action==='commission_reopen';
  const reason=String(body.reason||'').trim();
  if(reopening&&reason.length<5)return reply({error:'Informe o motivo da reabertura.'},400);
  let patch:Row;
  let filter:string;
  if(action==='close'){
   if(period.status!=='open')return reply({error:'A competência não está aberta.'},409);
   patch={status:'closed',commission_status:'closed'};
   filter='&status=eq.open';
  }else if(action==='reopen'){
   if(period.status!=='closed')return reply({error:'A competência não está fechada.'},409);
   patch={status:'open'};
   filter='&status=eq.closed';
  }else{
   if(period.status!=='open')return reply({error:'Reabra a folha antes de alterar a comissão.'},409);
   const expected=action==='commission_close'?'open':'closed';
   if(period.commission_status!==expected)return reply({error:'Situação da comissão alterada. Atualize a competência.'},409);
   patch={commission_status:action==='commission_close'?'closed':'open'};
   filter='&status=eq.open&commission_status=eq.'+expected;
  }
  // Atomic compare-and-set of the period state; audit is written only after success.
  const updated=await supabaseAdminRequest<Row[]>('/rest/v1/periods?select=month&month=eq.'+q(month)+filter,{
   method:'PATCH',body:patch,prefer:'return=representation'
  });
  if(updated.length!==1)return reply({error:'Situação alterada. Atualize a competência.'},409);
  await supabaseAdminRequest('/rest/v1/audit',{
   method:'POST',
   body:{id:crypto.randomUUID(),month,action:({close:'Competência fechada',reopen:'Competência reaberta',commission_close:'Comissão fechada',commission_reopen:'Comissão reaberta'} as Record<string,string>)[action],actor:user.email,created:new Date().toISOString(),detail:JSON.stringify({reason})}
  });
  return reply({ok:true});
 }catch(e){
  const security=securityError(e);if(security)return security;
  console.error('Finance preview state transition failed');
  return reply({error:'Não foi possível salvar a alteração. Atualize os dados antes de tentar novamente.'},503);
 }
}
