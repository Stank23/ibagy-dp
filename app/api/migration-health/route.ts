import {localUser} from '@/lib/local-auth';
import {assertSameSiteRead,securityError} from '@/lib/request-security';
import {isSupabaseConfigured,supabaseAdminRequest} from '@/lib/supabase-admin';
import {reserveAuthAttempt} from '@/lib/supabase-rate-limit';
export const dynamic='force-dynamic';
export async function GET(request:Request):Promise<Response>{
 try{assertSameSiteRead(request);const user=await localUser();if(!user)return Response.json({error:'Acesso restrito.'},{status:401});if(user.role!=='admin')return Response.json({error:'Acesso restrito.'},{status:403});if(!await reserveAuthAttempt('preview-health',user.userId,10,60000))return Response.json({error:'Limite de requisições atingido.'},{status:429});}catch(e){return securityError(e)||Response.json({error:'Não foi possível consultar o diagnóstico.'},{status:503});}

 const checks={configured:isSupabaseConfigured(),readable:false,rateLimit:false,status:'not_configured'};
 if(checks.configured){
  try{
   await supabaseAdminRequest('/rest/v1/app_users?select=id&limit=0');
   checks.readable=true;
   try{
    checks.rateLimit=true;
    checks.status=checks.rateLimit?'ok':'rate_limit_failed';
   }catch{checks.status='rate_limit_failed';}
  }catch{checks.status='connection_failed';}
 }
 return Response.json({application:'ibagy-dp',migration:'preview',runtime:'nextjs',supabase:checks},{headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
}
