import {clientAddress} from '@/lib/rate-limit';
import {readJSON,securityError,assertSameSiteRead} from '@/lib/request-security';
import {accountEmail} from '@/lib/email';
import {validPassword,PASSWORD_RULE} from '@/lib/password-policy';
import {supabaseAdminRequest} from '@/lib/supabase-admin';
import {reserveAuthAttempt} from '@/lib/supabase-rate-limit';
import {localUser,passwordHash,digest,hex,equal,checkOrigin,sessionCookie,requestSession} from '@/lib/local-auth';
export const dynamic='force-dynamic';
const json=(data:any,status=200,extra:Record<string,string>={})=>Response.json(data,{status,headers:{'Cache-Control':'no-store',...extra}});
export async function GET(request:Request){try{assertSameSiteRead(request);const user=await localUser();if(new URL(request.url).searchParams.get('session')==='1')return user?json({authenticated:true,name:user.displayName,role:user.role}):json({authenticated:false,error:'A sessão não foi mantida pelo navegador.'},401);if(!user||user.role!=='admin')return json({error:'Acesso restrito.'},403);const users=await supabaseAdminRequest<any[]>('/rest/v1/app_users?select=id,username,name,email,role,active&order=username.asc');return json({users});}catch(e){return securityError(e)||json({error:'Não foi possível consultar o acesso.'},503);}}
export async function POST(request:Request){try{
checkOrigin(request);
const body:any=await readJSON(request,8192);
if(typeof body.action!=='string'||body.action.length>30)return json({error:'Operação inválida.'},400);
if(body.action==='register'){
 const ip=clientAddress(request);
 if(!await reserveAuthAttempt('auth-request',ip,60,60000)||!await reserveAuthAttempt('register-ip',ip,5,900000))return json({error:'Limite de requisições atingido. Aguarde antes de tentar novamente.'},429);
 const email=accountEmail(body.email),username=String(body.username||'').trim().toLowerCase(),password=String(body.password||''),name=String(body.name||'').trim();
 if(!/^[a-z0-9._-]{3,60}$/.test(username)||!name||name.length>120)return json({error:'Informe nome e usuário de 3 a 60 caracteres, usando letras, números, ponto, hífen ou sublinhado.'},400);
 if(!validPassword(password))return json({error:PASSWORD_RULE},400);
 const salt=hex(crypto.getRandomValues(new Uint8Array(16)));
 await supabaseAdminRequest('/rest/v1/app_users?on_conflict=username',{method:'POST',body:{id:crypto.randomUUID(),username,name,email,role:'viewer',salt,password_hash:await passwordHash(password,salt),active:2},prefer:'resolution=ignore-duplicates,return=minimal'});
 return json({ok:true,pending:true,message:'Solicitação recebida. Se o cadastro for novo, aguarde a aprovação do administrador. Se já possui conta, use seu acesso existente.'});
}
const ip=clientAddress(request);
if(!await reserveAuthAttempt('auth-request',ip,60,60000))return json({error:'Limite de requisições atingido.'},429);
if(body.action==='logout'){
 const token=requestSession(request);
 if(token&&/^[a-f0-9]{64}$/.test(token))await supabaseAdminRequest('/rest/v1/app_sessions?token_hash=eq.'+await digest(token),{method:'DELETE',prefer:'return=minimal'});
 return json({ok:true},200,{'Set-Cookie':sessionCookie('',0)});
}
if(body.action==='login'){
 if(!await reserveAuthAttempt('login-ip',ip,30,900000))return json({error:'Limite de requisições atingido.'},429);
 const username=String(body.username||'').trim().toLowerCase(),password=String(body.password||'');
 if(!/^[a-z0-9._-]{3,60}$/.test(username)||!password||password.length>256)return json({error:'Usuário ou senha incorretos.'},401);
 if(!await reserveAuthAttempt('login-account',username,10,900000))return json({error:'Limite de requisições atingido.'},429);
 const rows=await supabaseAdminRequest<any[]>('/rest/v1/app_users?select=id,username,name,role,salt,password_hash,active&username=eq.'+encodeURIComponent(username)+'&active=eq.1&limit=1');
 const user=rows[0],computed=await passwordHash(password,user?.salt||'invalid-account');
 if(!user||!equal(computed,user.password_hash))return json({error:'Usuário ou senha incorretos.'},401);
 if(!validPassword(password))return json({passwordChangeRequired:true,message:PASSWORD_RULE});
 const token=hex(crypto.getRandomValues(new Uint8Array(32))),tokenHash=await digest(token),now=Date.now();
 const old=requestSession(request);
 const oldHash=old&&/^[a-f0-9]{64}$/.test(old)?await digest(old):null;
 const saved=await supabaseAdminRequest<boolean>('/rest/v1/rpc/create_finance_auth_session',{method:'POST',body:{p_user:user.id,p_expected_hash:computed,p_token:tokenHash,p_expires:now+28800000,p_now:now,p_old_token:oldHash}});
 if(!saved)return json({error:'Usuário ou senha incorretos.'},401);
 return json({ok:true},200,{'Set-Cookie':sessionCookie(token)});
}
const actor=await localUser();if(!actor||actor.role!=='admin')return json({error:'Acesso restrito.'},403);if(!await reserveAuthAttempt('account-admin',actor.userId,30,60000))return json({error:'Limite de requisições atingido.'},429);if(body.id!==undefined&&(typeof body.id!=='string'||body.id.length>120))return json({error:'Usuário inválido.'},400);
const filter=(value:string)=>encodeURIComponent(value);
const find=async(column:'id'|'email'|'username',value:string)=>{const rows=await supabaseAdminRequest<Array<{id:string}>>('/rest/v1/app_users?select=id&'+column+'=eq.'+filter(value)+'&limit=1');return rows[0]??null;};
const change=async(action:string,data:any)=>supabaseAdminRequest<boolean>('/rest/v1/rpc/mutate_finance_account',{method:'POST',body:{p_actor:actor.userId,p_action:action,p_data:data}});
if(body.action==='create'){
 const email=accountEmail(body.email),username=String(body.username||'').trim().toLowerCase(),password=String(body.password||''),name=String(body.name||'').trim();
 if(!/^[a-z0-9._-]{3,60}$/.test(username)||!name||name.length>120||!['admin','viewer'].includes(body.role))return json({error:'Preencha nome, usuário e perfil.'},400);
 if(!validPassword(password))return json({error:PASSWORD_RULE},400);
 if(await find('email',email))return json({error:'Este e-mail já está cadastrado.'},409);
 if(await find('username',username))return json({error:'Este usuário já existe.'},409);
 const salt=hex(crypto.getRandomValues(new Uint8Array(16)));
 if(!await change('create',{id:crypto.randomUUID(),username,name,email,role:body.role,salt,password_hash:await passwordHash(password,salt)}))return json({error:'Cadastro ou permissão alterados. Atualize antes de tentar novamente.'},409);
 return json({ok:true});
}
if(body.action==='email'){
 const email=accountEmail(body.email),id=String(body.id||'');
 if(!await find('id',id))return json({error:'Usuário não encontrado.'},404);
 const other=await find('email',email);if(other&&other.id!==id)return json({error:'Este e-mail já está cadastrado.'},409);
 if(!await change('email',{id,email}))return json({error:'Cadastro ou permissão alterados.'},409);return json({ok:true});
}
if(body.action==='password'){
 const password=String(body.password||''),id=String(body.id||'');if(!validPassword(password))return json({error:PASSWORD_RULE},400);
 if(!await find('id',id))return json({error:'Usuário não encontrado.'},404);
 const salt=hex(crypto.getRandomValues(new Uint8Array(16)));
 if(!await change('password',{id,salt,password_hash:await passwordHash(password,salt)}))return json({error:'Cadastro ou permissão alterados.'},409);
return json({ok:true,relogin:id===actor.userId});
}
if(body.action==='role'){
 if(!['admin','viewer'].includes(body.role))return json({error:'Permissão inválida.'},400);
 const id=String(body.id||'');if(id===actor.userId)return json({error:'Você não pode alterar sua própria permissão.'},400);
 if(!await find('id',id))return json({error:'Usuário não encontrado.'},404);
 if(!await change('role',{id,role:body.role}))return json({error:'Cadastro ou permissão alterados.'},409);
return json({ok:true});
}
if(body.action==='toggle'){
 const id=String(body.id||'');if(id===actor.userId)return json({error:'Você não pode desativar sua própria conta.'},400);
 const rows=await supabaseAdminRequest<Array<{active:number}>>('/rest/v1/app_users?select=active&id=eq.'+filter(id)+'&limit=1');
 if(!rows[0])return json({error:'Usuário não encontrado.'},404);
 if(!await change('toggle',{id}))return json({error:'Cadastro ou permissão alterados.'},409);
return json({ok:true});
}
return json({error:'Operação inválida.'},400);
}catch(error){const limited=securityError(error);if(limited)return limited;if(error instanceof Error&&error.message==='Informe um e-mail válido.')return json({error:error.message},400);console.error('Auth request failed');return json({error:'Não foi possível concluir o acesso.'},503);}}
