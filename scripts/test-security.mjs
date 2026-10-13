import './test-module-hooks.mjs';
import {registerHooks} from 'node:module';
import assert from 'node:assert/strict';
let account,userSession,calls=[],limited=false,fail=false,sessionCAS=true,mutation=true;
globalThis.__securityCookie=()=>userSession?'b'.repeat(64):null;
globalThis.__securityREST=async(path,o={})=>{
 calls.push({path,o});if(fail)throw Error('SECRET_INTERNAL_ERROR');
 if(path.endsWith('reserve_auth_attempt'))return !limited;
 if(path.endsWith('create_finance_auth_session')){assert.equal(o.body.p_expected_hash,account.password_hash);assert.match(o.body.p_token,/^[a-f0-9]{64}$/);assert.equal(o.body.p_expires-o.body.p_now,28800000);return sessionCAS;}
 if(path.endsWith('change_finance_password_and_session')){assert.equal(o.body.p_expected_hash,account.password_hash);assert.match(o.body.p_salt,/^[a-f0-9]{32}$/);assert.match(o.body.p_hash,/^[a-f0-9]{64}$/);if(!sessionCAS)return false;account.salt=o.body.p_salt;account.password_hash=o.body.p_hash;account.must_change_password=false;return true;}
 if(path.endsWith('mutate_finance_account'))return mutation;
 if(path.startsWith('/rest/v1/app_sessions?'))return o.method==='DELETE'?undefined:userSession?[{user_id:account.id}]:[];
 if(path.startsWith('/rest/v1/app_users?')){if(path.includes('must_change_password=eq.false')&&account.must_change_password)return [];if(path.includes('limit=0'))return [];if(path.includes('email=eq.'))return [];return [account];}
 if(path.startsWith('/rest/v1/app_users')&&o.method==='POST')return undefined;
 return [];
};
registerHooks({resolve(s,c,next){if(s==='server-only')return {url:'data:text/javascript,export%20default%20null',shortCircuit:true};if(s==='next/headers')return {url:'data:text/javascript,export const cookies=async()=>({get:()=>({value:globalThis.__securityCookie()})})',shortCircuit:true};if(s==='next/server')return {url:'data:text/javascript,export const NextResponse={next:()=>new Response(null,{headers:{"x-middleware-next":"1"}})}',shortCircuit:true};if(s.startsWith('@/'))return next(new URL('../'+s.slice(2)+'.ts',import.meta.url).href,c);return next(s,c);},load(u,c,next){if(u.endsWith('/lib/supabase-admin.ts'))return {format:'module',source:'export const supabaseAdminRequest=(...args)=>globalThis.__securityREST(...args);export const isSupabaseConfigured=()=>true;',shortCircuit:true};return next(u,c);}});
const {passwordHash,sessionCookie,localUser}=await import('../lib/local-auth.ts');
account={id:'synthetic-security-admin',username:'test-security',name:'TESTE',role:'admin',salt:'a'.repeat(32),active:1,password_hash:await passwordHash('Synthetic!12345','a'.repeat(32))};
const {GET,POST}=await import('../app/api/auth/route.ts');
const {GET:health}=await import('../app/api/migration-health/route.ts');
const {financePreviewRead}=await import('../lib/finance-preview-read.ts');
const {proxy}=await import('../proxy.ts');
const post=(body,origin='https://test.invalid',headers={})=>new Request('https://test.invalid/api/auth',{method:'POST',headers:{origin,'content-type':'application/json',...headers},body:JSON.stringify(body)});
const read=(path='/api/auth',headers={})=>new Request('https://test.invalid'+path,{headers});
for(const body of [{action:'login',username:'test-security',password:'Synthetic!12345'},{action:'create'},{action:'password'}]){calls=[];assert.equal((await POST(post(body,'https://attacker.invalid'))).status,403);assert.equal(calls.length,0);}
userSession=false;calls=[];assert.equal((await POST(post({action:'register',username:'test-new-user',name:'TESTE',email:'test-new@example.invalid',password:'Synthetic!12345',role:'admin',active:1}))).status,200);const registered=calls.find(c=>c.path.startsWith('/rest/v1/app_users')&&c.o.method==='POST');assert.equal(registered.o.body.role,'viewer');assert.equal(registered.o.body.active,2);
assert.equal((await health(read('/api/migration-health'))).status,401);assert.equal((await GET(read('/api/auth?session=1'))).status,401);assert.equal((await financePreviewRead(read('/api/finance?month=2026-11'))).status,401);
assert.equal((await GET(read('/api/auth',{'sec-fetch-site':'cross-site'}))).status,403);
assert.equal((await financePreviewRead(read('/api/finance',{'origin':'https://attacker.invalid'}))).status,403);
assert.equal((await POST(post({action:'login',username:'test-security',password:'wrong'}))).status,401);
let response=await POST(post({action:'login',username:'test-security',password:'Synthetic!12345'}));assert.equal(response.status,200);assert.match(response.headers.get('set-cookie'),/__Host-ibagy_session=.*HttpOnly; Secure; SameSite=None; Partitioned/);
sessionCAS=false;response=await POST(post({action:'login',username:'test-security',password:'Synthetic!12345'}));assert.equal(response.status,401);assert.equal(response.headers.has('set-cookie'),false);sessionCAS=true;
const originalAccount={...account};account.must_change_password=true;userSession=true;
assert.equal((await GET(read('/api/auth?session=1'))).status,401,'Old session blocked while password change is required');
assert.equal((await financePreviewRead(read('/api/finance?month=2026-11'))).status,401);
userSession=false;calls=[];response=await POST(post({action:'login',username:'test-security',password:'Synthetic!12345'}));assert.equal((await response.json()).passwordChangeRequired,true);assert.match(response.headers.get('set-cookie'),/Max-Age=0/);assert.ok(!calls.some(c=>c.path.endsWith('create_finance_auth_session')));
for(const newPassword of ['weak','Synthetic!12345'])assert.equal((await POST(post({action:'login',username:'test-security',password:'Synthetic!12345',newPassword}))).status,400);
sessionCAS=false;response=await POST(post({action:'login',username:'test-security',password:'Synthetic!12345',newPassword:'NewPersonal!12345'}));assert.equal(response.status,401);assert.equal(response.headers.has('set-cookie'),false);assert.equal(account.must_change_password,true);
sessionCAS=true;response=await POST(post({action:'login',username:'test-security',password:'Synthetic!12345',newPassword:'NewPersonal!12345'}));assert.equal(response.status,200);assert.equal(account.must_change_password,false);assert.match(response.headers.get('set-cookie'),/HttpOnly/);
assert.equal((await POST(post({action:'login',username:'test-security',password:'Synthetic!12345'}))).status,401);
assert.equal((await POST(post({action:'login',username:'test-security',password:'NewPersonal!12345'}))).status,200);
account={...originalAccount,must_change_password:false};userSession=false;
limited=true;assert.equal((await POST(post({action:'login'}))).status,429);limited=false;
userSession=true;account.role='viewer';for(const body of [{action:'create'},{action:'password',id:account.id},{action:'role',id:'other',role:'admin'},{action:'toggle',id:'other'}])assert.equal((await POST(post(body))).status,403);
assert.equal((await health(read('/api/migration-health'))).status,403);assert.equal((await GET(read())).status,403);
account.role='admin';assert.equal((await POST(post({action:'role',id:account.id,role:'viewer'}))).status,400);assert.equal((await POST(post({action:'toggle',id:account.id}))).status,400);
response=await POST(post({action:'password',id:account.id,password:'NewSynthetic!123'}));assert.equal(response.status,200);assert.equal((await response.json()).relogin,true);
mutation=false;assert.equal((await POST(post({action:'password',id:account.id,password:'NewSynthetic!123'}))).status,409);mutation=true;
assert.equal((await health(read('/api/migration-health'))).status,200);
const req=read('/api/finance',{'sec-fetch-site':'cross-site'});req.nextUrl=new URL(req.url);calls=[];response=await proxy(req);assert.equal(response.status,403);assert.equal(calls.length,0);assert.match(response.headers.get('content-security-policy'),/frame-ancestors 'none'/);assert.equal(response.headers.get('x-content-type-options'),'nosniff');
const page=read('/login');page.nextUrl=new URL(page.url);response=await proxy(page);assert.equal(response.status,200);assert.equal(response.headers.get('x-middleware-next'),'1');assert.match(response.headers.get('content-security-policy'),/object-src 'none'/);
for(const path of ['/.env','/.git/config','/app.js.map']){const blocked=read(path);blocked.nextUrl=new URL(blocked.url);assert.equal((await proxy(blocked)).status,404);}
const blockedMethod=new Request('https://test.invalid/api/auth',{method:'DELETE'});blockedMethod.nextUrl=new URL(blockedMethod.url);assert.equal((await proxy(blockedMethod)).status,405);
const api=read('/api/auth');api.nextUrl=new URL(api.url);limited=true;response=await proxy(api);assert.equal(response.status,429);assert.equal(response.headers.get('retry-after'),'60');limited=false;
fail=true;response=await GET(read());assert.equal(response.status,503);assert.equal((await response.text()).includes('SECRET_INTERNAL_ERROR'),false);fail=false;
process.env.VERCEL='1';const {clientAddress}=await import('../lib/rate-limit.ts');assert.equal(clientAddress(read('/',{'cf-connecting-ip':'spoofed'})),'unknown');assert.equal(clientAddress(read('/',{'x-vercel-forwarded-for':'198.51.100.1','cf-connecting-ip':'spoofed'})),'198.51.100.1');
console.log('PASS: auth origin/login/CAS/cookie/rate limits; anonymous/viewer restrictions; self-account guards; atomic admin RPC; diagnostic protection; read CSRF; proxy headers/methods/rate limits; sanitized errors; trusted IP source (HTTP mocks).');

const {downloadResponse}=await import('../lib/download-response.ts');
const attachment=downloadResponse('test','x\r\nInjected:bad.html','application/octet-stream');
assert.equal(attachment.headers.has('Injected'),false);assert.match(attachment.headers.get('content-disposition'),/^attachment/);assert.equal(attachment.headers.get('x-content-type-options'),'nosniff');
const {payrollExport}=await import('../lib/payroll-export.ts');const XLSX=await import('xlsx');
const hostile='=HYPERLINK("https://example.invalid","test")';
const file=payrollExport('commission','2026-11',[{data:JSON.stringify({B:'TESTE',C:hostile,U:'1.00',T:'0.00'})}]);const sheet=XLSX.read(file.bytes,{type:'array'}).Sheets.Ibagy;
assert.equal(sheet.B2.v,hostile);assert.equal(sheet.B2.t,'s');assert.equal(sheet.B2.f,undefined);
console.log('PASS: attachment filename header injection rejected and untrusted spreadsheet names remain text, without formula execution.');
