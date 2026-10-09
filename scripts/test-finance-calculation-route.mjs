import './test-module-hooks.mjs';
import {registerHooks} from 'node:module';
import assert from 'node:assert/strict';
let user={userId:'synthetic-admin',email:'admin@example.invalid',role:'admin'};
let calls=[],result=true,period=null,limited=false,fail=false;
globalThis.__financeTestUser=()=>user;
globalThis.__financeTestRequest=async(path,options)=>{
 calls.push({path,options});
 if(path.endsWith('/reserve_auth_attempt'))return !limited;
 if(fail)throw Error('Sensitive internal database details');
 if(path.endsWith('/finance_calculation_snapshot'))return {token:'a'.repeat(32),snapshot:{period,employees:[],versions:[],records:[],allowances:[],minimum_wages:[],normative_wages:[],unimed_rates:[],uniodonto_fixed_rates:[],installments:[],event_plans:[],childcare_children:[]}};
 return result;
};
registerHooks({
 resolve(specifier,context,next){if(specifier==='server-only')return {url:'data:text/javascript,export%20default%20null',shortCircuit:true};return next(specifier,context);},
 load(url,context,next){
  if(url.endsWith('/lib/local-auth.ts'))return {format:'module',source:'export async function localUser(){return globalThis.__financeTestUser()}',shortCircuit:true};
  if(url.endsWith('/lib/supabase-admin.ts'))return {format:'module',source:'export const supabaseAdminRequest=(...args)=>globalThis.__financeTestRequest(...args)',shortCircuit:true};
  return next(url,context);
 }
});
const {financePreviewWrite}=await import('../lib/finance-preview-write.ts');
const request=(body,origin='https://test.invalid')=>new Request('https://test.invalid/api/finance',{method:'POST',headers:{origin,'content-type':'application/json'},body:JSON.stringify(body)});
const run=async(body,origin)=>{calls=[];return financePreviewWrite(request(body,origin));};
assert.equal((await run({action:'period',month:'2026-10'},'https://attacker.invalid')).status,403);assert.equal(calls.length,0);
user=null;assert.equal((await run({action:'period',month:'2026-10'})).status,401);assert.equal(calls.length,0);
user={userId:'synthetic-reader',email:'reader@example.invalid',role:'user'};assert.equal((await run({action:'period',month:'2026-10'})).status,403);assert.equal(calls.length,0);
user={userId:'synthetic-admin',email:'admin@example.invalid',role:'admin'};
assert.equal((await run({action:'period',month:'2026-13'})).status,400);assert.equal(calls.length,0);
limited=true;assert.equal((await run({action:'period',month:'2026-10'})).status,429);assert.equal(calls.length,1);limited=false;
const response=await run({action:'period',month:'2026-10'});assert.equal(response.status,200);assert.deepEqual(await response.json(),{ok:true});assert.equal(response.headers.get('cache-control'),'no-store');
assert.equal(calls.length,3);assert.equal(calls[2].options.body.p_actor,'admin@example.invalid');assert.equal(calls[2].options.body.p_action,'period');
result=false;assert.equal((await run({action:'period',month:'2026-10'})).status,409);result=true;
period={status:'open',commission_status:'closed'};assert.equal((await run({action:'period',month:'2026-10'})).status,409);assert.equal(calls.length,2);
assert.equal((await run({action:'recalculate',month:'2026-10'})).status,200);assert.equal(calls[2].options.body.p_action,'recalculate');
period={status:'closed',commission_status:'closed'};assert.equal((await run({action:'recalculate',month:'2026-10'})).status,409);assert.equal(calls.length,2);
fail=true;const failed=await run({action:'recalculate',month:'2026-10'});assert.equal(failed.status,503);assert.ok(!(await failed.text()).includes('Sensitive'));
console.log('PASS: finance route origin, login, admin, month, rate limit, calculated RPC, actor, conflicts, closed period, no-store and sanitized errors (HTTP mocks; not browser E2E)');
