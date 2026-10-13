import {NextResponse,type NextRequest} from 'next/server';
import {assertSameOrigin,assertSameSiteRead,checkRequestLength,securityError} from './lib/request-security';
import {secureResponse} from './lib/security-headers';
import {reserveAuthAttempt} from './lib/supabase-rate-limit';
import {clientAddress} from './lib/rate-limit';
export async function proxy(request:NextRequest){
 try{
  const path=request.nextUrl.pathname;
  if(path.endsWith('.map')||/(?:^|\/)\.(?:env|git)(?:[./]|$)/.test(path))return secureResponse(new Response(null,{status:404}),request);
  if(path==='/_next/image'||!['GET','HEAD'].includes(request.method)&&!path.startsWith('/api/'))return secureResponse(new Response(null,{status:405}),request);
  if(path.startsWith('/api/')){
   if(!['GET','POST'].includes(request.method))return secureResponse(new Response(null,{status:405,headers:{Allow:'GET, POST'}}),request);
   if(request.method==='GET')assertSameSiteRead(request);else assertSameOrigin(request);
   checkRequestLength(request,path==='/api/documents'?16*1024*1024:1024*1024);
   if(!await reserveAuthAttempt('api-ip',clientAddress(request),240,60000))return secureResponse(Response.json({error:'Limite de requisições atingido.'},{status:429,headers:{'Retry-After':'60'}}),request);
  }
  return secureResponse(NextResponse.next(),request);
 }catch(e){return secureResponse(securityError(e)||Response.json({error:'Não foi possível concluir a requisição.'},{status:503}),request);}
}
export const config={matcher:['/((?!_next/static|favicon.ico).*)']};
