import './test-module-hooks.mjs';
import {registerHooks} from 'node:module';
import assert from 'node:assert/strict';
let user={userId:'synthetic-admin',email:'admin@example.invalid',role:'admin'};
let calls=[],result=true,period=null,limited=false,fail=false,records=[];
globalThis.__financeTestUser=()=>user;
globalThis.__financeTestRequest=async(path,options)=>{
 calls.push({path,options});
 if(path.endsWith('/reserve_auth_attempt'))return !limited;
 if(fail)throw Error('Sensitive internal database details');
 if(path.endsWith('/finance_loan_settlement_snapshot'))return {token:'b'.repeat(32),snapshot:{loan:{id:'synthetic-loan',employee:'synthetic-employee'},installments:[{loan:'synthetic-loan',month:'2026-10',amount:10000}],calculations:[{month:'2026-10',snapshot:{period:{status:'open'},records:[],installments:[],employees:[],versions:[],allowances:[],minimum_wages:[],normative_wages:[],unimed_rates:[],uniodonto_fixed_rates:[],event_plans:[],childcare_children:[]}}]}};
 if(path.endsWith('/finance_calculation_snapshot'))return {token:'a'.repeat(32),snapshot:{period,employees:[],versions:[],records,allowances:[],minimum_wages:[],normative_wages:[],unimed_rates:[],uniodonto_fixed_rates:[],installments:[],event_plans:[],childcare_children:[]}};
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
const values={B:'TEST-RECORD',C:'Pessoa fictícia',D:'2021-01-01',K:'1000.00',receivesVA:false,chargeSerefi:false,P:'',commissionType:''};
records=[{employee:'synthetic-employee',revision:3,data:JSON.stringify(values)}];
assert.equal((await run({action:'record',month:'2026-10',employee:'synthetic-employee',revision:3,data:{...values,AF:'02:30'}})).status,200);
assert.equal(calls[2].options.body.p_action,'record');assert.equal(calls[2].options.body.p_records.length,1);assert.equal(calls[2].options.body.p_records[0].revision,3);
assert.equal((await run({action:'record',month:'2026-10',employee:'synthetic-employee',revision:2,data:values})).status,409);assert.equal(calls.length,2);
assert.equal((await run({action:'record',month:'2026-10',employee:'synthetic-employee',revision:3,data:{...values,B:'changed'}})).status,400);assert.equal(calls.length,2);
assert.equal((await run({action:'record',month:'2026-10',employee:'synthetic-employee',revision:'3',data:values})).status,400);assert.equal(calls.length,1);
period={status:'closed',commission_status:'closed'};assert.equal((await run({action:'recalculate',month:'2026-10'})).status,409);assert.equal(calls.length,2);
fail=true;const failed=await run({action:'recalculate',month:'2026-10'});assert.equal(failed.status,503);assert.ok(!(await failed.text()).includes('Sensitive'));
console.log('PASS: finance route origin, login, admin, month, rate limit, calculated/edit RPC, actor, input/revision validation, conflicts, closed period, no-store and sanitized errors (HTTP mocks; not browser E2E)');

fail=false;
const settlement={month:'2026-10',loan:'synthetic-loan',paymentDate:'2026-10-14',reference:'TESTE'};
for(const action of ['loan_settlement_preview','loan_settlement']){
 const b={...settlement,action,token:'b'.repeat(32)};
 assert.equal((await run(b,'https://attacker.invalid')).status,403);assert.equal(calls.length,0);
 user=null;assert.equal((await run(b)).status,401);assert.equal(calls.length,0);
 user={userId:'synthetic-viewer',email:'viewer@example.invalid',role:'viewer'};assert.equal((await run(b)).status,403);assert.equal(calls.length,0);
 user={userId:'synthetic-admin',email:'admin@example.invalid',role:'admin'};
 limited=true;assert.equal((await run(b)).status,429);assert.equal(calls.length,1);limited=false;
 const res=await run(b);assert.equal(res.status,200);assert.equal(res.headers.get('cache-control'),'no-store');
 if(action==='loan_settlement_preview'){assert.equal((await res.json()).amount,10000);assert.equal(calls.length,2);}else{assert.equal(calls.length,3);assert.equal(calls[2].options.body.p_actor,user.email);assert.equal(calls[2].options.body.p_reference,'TESTE');}
}
assert.equal((await run({...settlement,action:'loan_settlement',token:'stale'})).status,409);
assert.equal((await run({...settlement,action:'loan_settlement_preview',paymentDate:'2026-02-30'})).status,400);
console.log('PASS: SEREFI settlement HTTP preview/save, CSRF, anonymous/viewer denial, server actor, rate limit, no-store, invalid date and stale preview');
