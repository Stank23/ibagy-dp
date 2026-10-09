import './test-module-hooks.mjs';
import {registerHooks} from 'node:module';
import {readFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
registerHooks({resolve(s,c,next){if(s==='server-only')return {url:'data:text/javascript,export%20default%20null',shortCircuit:true};return next(s,c);},load(u,c,next){if(u.endsWith('/lib/supabase-admin.ts'))return {format:'module',source:'export const supabaseAdminRequest=()=>{throw Error("Unexpected REST")}',shortCircuit:true};return next(u,c);}});
const {salaryChanges}=await import('../lib/supabase-salary.ts');const {eventPlanInput}=await import('../lib/supabase-event-plan.ts');const {eventPlan}=await import('../lib/event-installments.ts');const {calculate}=await import('../lib/finance-service.ts');const {snapshotContext}=await import('../lib/supabase-calculation.ts');const {changedSalary}=await import('../lib/salary-adjustments.ts');
const f=JSON.parse(await readFile('work/field-tests/all-field-fixtures.json','utf8'));const s=structuredClone(f.snapshot);s.records=[{employee:f.employee,revision:1,data:JSON.stringify(f.baseline)}];const original=JSON.stringify(s);
for(const individual of [false,true]){
 const body={month:f.month,action:individual?'salary_rows_preview':'salary_preview',percent:'5.25',edits:[{employee:f.employee,mode:'percent',value:'5.25'}],applyOpen:true};
 const preview=await salaryChanges(s,body);assert.equal(preview.response.list[0].next,changedSalary(preview.response.list[0].old,'percent','5.25'));
 const applied=await salaryChanges(s,{...body,action:individual?'salary_rows_apply':'salary_adjust',token:preview.response.token});
 const d=JSON.parse(s.records[0].data);d.K=(preview.response.list[0].next/100).toFixed(2);assert.deepEqual(JSON.parse(applied.records[0].data),await calculate(null,d,f.employee,f.month,snapshotContext(s)));
 await assert.rejects(()=>salaryChanges(s,{...body,action:individual?'salary_rows_apply':'salary_adjust',token:'stale'}),/prévia/);
 await assert.rejects(()=>salaryChanges({...s,period:{status:'closed'}},body),/reabra/);
}
await assert.rejects(()=>salaryChanges(s,{month:f.month,action:'salary_rows_preview',edits:[{employee:f.employee,mode:'amount',value:'3000'},{employee:f.employee,mode:'amount',value:'4000'}]}),/repetido/);
assert.equal(JSON.stringify(s),original);
const b={id:'test-event-plan-input-001',employee:f.employee,month:f.month,event:'CK',amount:'10.00',count:3,start:f.month,end:'2000-04'};assert.deepEqual(eventPlanInput(b),{id:b.id,employee:b.employee,...eventPlan(b)});assert.throws(()=>eventPlanInput({...b,start:'2000-01',end:'2000-03'}),/histórico/);assert.throws(()=>eventPlanInput({...b,count:121}));
console.log('PASS: collective/individual salary previews, original rounding and full recalculation parity, stale preview, duplicates, closed month and immutable inputs; event original schedule validation and history bound');
const {terminationChanges}=await import('../lib/supabase-termination.ts');const {terminationSummary}=await import('../lib/termination.ts');const {remainingEvents}=await import('../lib/event-installments.ts');
const ts={...structuredClone(s),remaining_installments:[{amount:10280}],remaining_event_plans:[{event:'CK',amount:1000,start:'2000-01',end:'2000-03'}],future_records:[]};
const tb={month:f.month,employee:f.employee,revision:1,date:'2000-02-15',foodAlreadyPaid:true,action:'termination_preview'};
const tp=await terminationChanges(ts,tb);const td=tp.response.values;const monthly=await calculate(null,{...f.baseline,lastWorkedDay:undefined},f.employee,f.month,snapshotContext(ts));assert.deepEqual(tp.response.summary,{...terminationSummary(td,f.month,true,monthly),...remainingEvents(ts.remaining_event_plans,f.month),loanRemaining:'102.80',installmentsRemaining:'122.80'});
const saved=await terminationChanges(ts,{...tb,action:'termination_save'});assert.deepEqual(JSON.parse(saved.data),td);assert.equal(JSON.parse(saved.base).G,'Rescisão');
await assert.rejects(()=>terminationChanges({...ts,future_records:[{status:'closed'}]},{...tb,action:'termination_save'}),/posterior fechada/);
await assert.rejects(()=>terminationChanges(ts,{...tb,revision:99}),/alterado/);
await assert.rejects(()=>terminationChanges(ts,{...tb,date:'2000-03-01'}),/demissão/);
console.log('PASS: termination original full engine/summary and remaining balances, save/preview parity, future locked month, date and revision guards');
