import 'server-only';
import {assertSameOrigin,readLimitedBody,securityError} from './request-security';
import {localUser} from './local-auth';
import {reserveAuthAttempt} from './supabase-rate-limit';
import {attachFinanceFile} from './supabase-files';
import {CalculationConflict,CalculationInputError} from './supabase-calculation';
export async function financeDocumentUpload(request:Request){
 const json=(body:unknown,status=200)=>Response.json(body,{status,headers:{'Cache-Control':'no-store'}});
 try{
  assertSameOrigin(request);const user=await localUser();if(!user)return json({error:'Acesso restrito.'},401);if(user.role!=='admin')return json({error:'Acesso restrito.'},403);
  if(!await reserveAuthAttempt('document-upload',user.userId,10,60000))return json({error:'Limite de envios atingido.'},429);
  const type=request.headers.get('content-type')||'';if(!type.toLowerCase().startsWith('multipart/form-data;'))return json({error:'Formato de envio inválido.'},415);
  const bytes=await readLimitedBody(request,16*1024*1024),form=await new Response(bytes as BodyInit,{headers:{'Content-Type':type}}).formData(),file=form.get('file'),month=String(form.get('month'));
  if(!(file instanceof File)||!file.size||file.size>15*1024*1024)return json({error:'Selecione um arquivo de até 15 MB.'},400);
  const name=file.name.replace(/[\x00-\x1f\x7f"\\/]/g,'_').slice(0,200);
  if(!/\.(pdf|xls|xlsx|csv|doc|docx|txt|png|jpg|jpeg)$/i.test(name))return json({error:'Formato não permitido.'},400);
  if(!/^20\d{2}-(0[1-9]|1[0-2])$/.test(month))return json({error:'Competência inválida.'},400);
  return json(await attachFinanceFile(month,name,await file.arrayBuffer(),user.email));
 }catch(e){const limited=securityError(e);if(limited)return limited;if(e instanceof CalculationConflict)return json({error:e.message},409);if(e instanceof CalculationInputError)return json({error:e.message},400);console.error('Supabase document upload failed');return json({error:'Não foi possível anexar o documento.'},503);}
}
