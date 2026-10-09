import {isSupabaseConfigured,supabaseAdminRequest} from '@/lib/supabase-admin';
export const dynamic='force-dynamic';
export async function GET():Promise<Response>{
  const checks:{configured:boolean;readable:boolean;status:string}={configured:isSupabaseConfigured(),readable:false,status:'not_configured'};
  if(checks.configured){
    try{
      await supabaseAdminRequest('/rest/v1/app_users?select=id&limit=0');
      checks.readable=true;checks.status='ok';
    }catch{checks.status='connection_failed';}
  }
  return Response.json({application:'ibagy-dp',migration:'preview',runtime:'nextjs',databaseTested:true,supabase:checks},{headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
}
