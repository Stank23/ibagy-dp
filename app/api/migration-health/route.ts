import {isSupabaseConfigured,supabaseAdminRequest} from '@/lib/supabase-admin';
import {reserveAuthAttempt} from '@/lib/supabase-rate-limit';
export const dynamic='force-dynamic';
export async function GET():Promise<Response>{
 const checks={configured:isSupabaseConfigured(),readable:false,rateLimit:false,status:'not_configured'};
 if(checks.configured){
  try{
   await supabaseAdminRequest('/rest/v1/app_users?select=id&limit=0');
   checks.readable=true;
   try{
    checks.rateLimit=await reserveAuthAttempt('preview-health',crypto.randomUUID(),1,60000);
    checks.status=checks.rateLimit?'ok':'rate_limit_failed';
   }catch{checks.status='rate_limit_failed';}
  }catch{checks.status='connection_failed';}
 }
 return Response.json({application:'ibagy-dp',migration:'preview',runtime:'nextjs',supabase:checks},{headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
}
