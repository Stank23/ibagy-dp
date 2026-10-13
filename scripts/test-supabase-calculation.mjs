import './test-module-hooks.mjs';
import assert from 'node:assert/strict';
const {calculatedRecords,editedRecord}=await import('../lib/supabase-calculation.ts');
const {calculate}=await import('../lib/finance-service.ts');

const base={B:'TEST-001',C:'Colaboradora fictícia',D:'2021-10-15',K:'3000.00',F:'1980-01-15',gender:'Feminino',receivesVA:true,chargeSerefi:true,
 healthMembers:[{id:'titular',role:'titular',plan:'unimed',name:'Teste',monthly:'0.00'},{id:'dependente',role:'dependente',plan:'unimed',name:'Dependente fictício',birthDate:'2020-01-01',monthly:'0.00'},{id:'dental',role:'titular',plan:'uniodonto',name:'Teste',monthly:'0.00'}],healthCopart:{titular:'10.00'},commissionNet:'180.00',U:'200.00',T:'20.00',W:'0.00',CK:'0.00',AM:'0.00'};
const s={period:null,employees:[{id:'test-employee',active:1},{id:'future',active:1},{id:'inactive',active:0}],versions:[{employee:'test-employee',month:'2021-10',data:JSON.stringify(base)},{employee:'future',month:'2026-11',data:JSON.stringify({...base,D:'2026-11-01'})},{employee:'inactive',month:'2021-10',data:JSON.stringify(base)}],records:[],
 allowances:[{month:'2026-01',amount:90000}],minimum_wages:[{month:'2026-01',amount:162100}],normative_wages:[{month:'2026-01',amount:200000}],unimed_rates:[{month:'2026-01',young:20000,middle:30000,senior:40000}],uniodonto_fixed_rates:[{month:'2026-01',amount:5000}],
 installments:[{employee:'test-employee',amount:10280},{employee:'test-employee',amount:5000}],event_plans:[{employee:'test-employee',event:'CK',amount:1000},{employee:'test-employee',event:'CK',amount:500},{employee:'test-employee',event:'AM',amount:200}],childcare_children:[{id:'test-child',employee:'test-employee',child_name:'Filho fictício',birth_date:'2020-01-01',start:'2020-01',last_credit:'2027-01'}]};
const before=JSON.stringify(s);
const rows=await calculatedRecords(s,'2026-10','period');
assert.equal(rows.length,1);assert.equal(rows[0].revision,0);
const d=JSON.parse(rows[0].data);
for(const [key,expected] of Object.entries({M:'150.00',salaryCompetencia:'3000.00',AP:'900.00',AI:'152.80',AL:'32.42',AN:'1.00',AG:'400.00',CK:'15.00',AM:'2.00',O:'3150.00',Q:'180.00',CQ:'266.40'}))assert.equal(d[key],expected,key);
assert.equal(d.healthMembers[0].monthly,'300.00');assert.equal(d.healthMembers[1].monthly,'200.00');assert.equal(d.healthMembers[2].monthly,'50.00');
// Exercise original D1 calculationContext independently from snapshotContext.
const results=[s.allowances,s.minimum_wages,s.normative_wages,s.unimed_rates,s.uniodonto_fixed_rates,s.employees,[{employee:'test-employee',total:15280}],[{employee:'test-employee',event:'CK',total:1500},{employee:'test-employee',event:'AM',total:200}],s.childcare_children];
const db={prepare(){return {bind(){return this;}}},async batch(){return results.map(results=>({results}));}};
assert.deepEqual(d,await calculate(db,base,'test-employee','2026-10'));
assert.equal(JSON.stringify(s),before,'Source snapshot is immutable');
await assert.rejects(calculatedRecords({...s,period:{status:'closed'}},'2026-10','recalculate'));
await assert.rejects(calculatedRecords({...s,period:{status:'open'}},'2026-10','period'));
await assert.rejects(calculatedRecords(s,'2026-13','period'));
const recalc={...s,period:{status:'open',commission_status:'closed'},records:[{employee:'test-employee',revision:7,data:rows[0].data}]};
const twice=await calculatedRecords(recalc,'2026-10','recalculate');
assert.equal(twice[0].revision,7);assert.deepEqual(JSON.parse(twice[0].data),d,'No doubling of automatic events');
const partial=await calculatedRecords({...s,versions:[{employee:'test-employee',month:'2026-10',data:JSON.stringify({...base,D:'2026-10-16',receivesVA:false,chargeSerefi:false})}]},'2026-10','period');
const p=JSON.parse(partial[0].data);assert.equal(p.salaryCompetencia,'1500.00');assert.equal(p.AP,'0.00');assert.equal(p.AL,'0.00');assert.equal(p.M,'0.00');
const editing={...recalc,records:[{employee:'test-employee',revision:7,data:JSON.stringify({...d,paid20:true,commissionType:'',P:''})}]};
const edited=await editedRecord(editing,'2026-10','test-employee',{...d,P:'',commissionType:'',AF:'02:30',U:'999.00',paid20:false},7);
const ed=JSON.parse(edited[0].data);assert.equal(ed.AF,'02:30');assert.equal(ed.U,'200.00');assert.equal(ed.commissionNet,'180.00');assert.equal(ed.paid20,true);assert.equal(ed.CK,'15.00');assert.equal(edited[0].revision,7);
await assert.rejects(editedRecord(editing,'2026-10','test-employee',{...d,B:'changed'},7),/matrícula/);
await assert.rejects(editedRecord(editing,'2026-10','test-employee',d,6),/alterado/);
await assert.rejects(editedRecord(editing,'2026-10','test-employee',{...d,CK:'0.00'},7),/parcelas automáticas/);
await assert.rejects(editedRecord({...editing,period:{status:'closed'}},'2026-10','test-employee',d,7));
await assert.rejects(editedRecord({...editing,records:[{employee:'test-employee',revision:7,data:JSON.stringify({...d,_excluded:true})}]},'2026-10','test-employee',d,7),/Reinclua/);
assert.equal(JSON.parse(editing.records[0].data).AF,undefined,'Original record is not mutated');
console.log('PASS: full v77 engine parity, financial/health outputs, eligibility, immutable inputs, closed/invalid periods, idempotent events, revisions, admission/exemptions and record editing with locked commission, hours, fixed registration and excluded records');
