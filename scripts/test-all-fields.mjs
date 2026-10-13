import './test-module-hooks.mjs';
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {resolve} from 'node:path';
const {fields,textKeys,normalize}=await import('../lib/payroll.ts');
const {hourKeys}=await import('../lib/hours.ts');
const {calculatedRecords,editedRecord}=await import('../lib/supabase-calculation.ts');
const {commissionTypes}=await import('../lib/benefits.ts');
const {validCPF}=await import('../lib/cpf.ts');

const month='2000-02',employee='test-all-fields-v77';
const raw=Object.fromEntries(fields.map((f,i)=>[f.key,hourKeys.has(f.key)?'01:30':f.key==='faltas1027'?'1':textKeys.has(f.key)?'Teste '+f.key:((i+100)/100).toFixed(2)]));
Object.assign(raw,{A:month,B:'TEST-ALL-FIELDS',C:'Pessoa fictícia dos testes',D:'1995-02-01',E:'000.000.001-91',F:'1980-01-01',G:'Normal',H:'Matriz',J:'Financeiro',K:'3000.00',P:commissionTypes[0],gender:'Feminino',receivesVA:true,chargeSerefi:true,supportGroup:false,receivesPericulosidade:false,extraCaixa:'10.00',extraPericulosidade:'0.00',extraInsalubridade:'20.00',extraTeletrabalho:'30.00',commissionType:commissionTypes[0],commissionNet:'100.00',commissionIR:'10.00',commissionUseful:24,commissionRest:5,paid20:false,paymentDate:'',paymentStatus:'pending'});
assert.ok(validCPF(raw.E),'Artificial fixture CPF must pass its check digits');
raw.healthMembers=['unimed','uniodonto'].flatMap(plan=>[{id:plan+'-titular',plan,role:'titular',name:raw.C,monthly:'0.00'},...Array.from({length:4},(_,i)=>({id:plan+'-dep-'+i,plan,role:'dependente',name:'Dependente fictício '+i,birthDate:'1990-01-01',monthly:'0.00'}))]);
raw.healthCopart=Object.fromEntries(raw.healthMembers.map((m,i)=>[m.id,((i+1)/100).toFixed(2)]));
raw.healthMonthlyAdditions={'unimed-titular':'10.00'};
const snapshot={period:null,employees:[{id:employee,registration:raw.B,active:1}],versions:[{employee,month:'1995-02',data:JSON.stringify(raw)}],records:[],allowances:[{month,amount:90000}],minimum_wages:[{month,amount:162100}],normative_wages:[{month,amount:200000}],unimed_rates:[{month,young:20000,middle:30000,senior:40000}],uniodonto_fixed_rates:[{month,amount:5000}],installments:[],event_plans:[],childcare_children:[{employee,id:'test-all-fields-child',child_name:'Filho fictício',birth_date:'1998-01-01',start:'1998-01',last_credit:'2005-01'}]};
const normalized=normalize(raw);
assert.deepEqual(Object.keys(normalized).filter(k=>fields.some(f=>f.key===k)).sort(),fields.map(f=>f.key).sort());
const calculated=JSON.parse((await calculatedRecords(snapshot,month,'period'))[0].data);
Object.assign(calculated,{healthMonthlyAdditions:raw.healthMonthlyAdditions,paid20:false,paymentDate:'',paymentStatus:'pending'});
snapshot.period={month,status:'open',commission_status:'open'};
snapshot.records=[{month,employee,revision:1,data:JSON.stringify(calculated)}];
const input={...calculated};
const baseline=JSON.parse((await editedRecord(snapshot,month,employee,input,1))[0].data);
// Expectations derive from the original v77 route and its calculated/legacy layouts.
const automatic=new Set(['M','N','O','Q','AE','AG','AI','AL','AN','AP','AT','AU','AV','AX','AY','AZ','BB','BC','BD','BF','BG','BH','BJ','BK','BL','BO','BP','BQ','BS','BT','BU','BW','BX','BY','CA','CB','CC','CE','CF','CG','CI','CJ','CO','CP','CQ','CR','CS','CT','CY','CZ','DA','DB','DC','DD','DE','DF']);
const preserved=new Set(['P','T','U','gender']);
const variants={A:'2000-02',B:'OTHER-REGISTRATION',C:'Outro nome fictício',D:'1996-01-01',E:'000.000.002-72',F:'1981-01-01',G:'Aprendiz',H:'Centro',J:'Administrativo',P:commissionTypes[1],gender:'Masculino',DI:'2000'};
const cases=[],coverage=[];
for(const field of fields){
 const value=Object.hasOwn(variants,field.key)?variants[field.key]:hourKeys.has(field.key)?'02:45':field.key==='faltas1027'?'2':textKeys.has(field.key)?'Alterado '+field.key:'22.22';
 const next={...input,[field.key]:value};
 const behavior=field.key==='B'?'immutable':automatic.has(field.key)?'calculated':preserved.has(field.key)?'preserved':'editable';
 let result;
 if(behavior==='immutable'){
  await assert.rejects(editedRecord(snapshot,month,employee,next,1),/matrícula/);result=baseline;
 }else{
  result=JSON.parse((await editedRecord(snapshot,month,employee,next,1))[0].data);
  assert.ok(Object.hasOwn(result,field.key),'Missing field '+field.key);
  if(behavior==='editable')assert.equal(result[field.key],normalize(next)[field.key],field.key+' must persist');
  else assert.equal(result[field.key],baseline[field.key],field.key+' must follow original v77 source');
 }
 const patch=Object.fromEntries(Object.entries(result).filter(([key,value])=>JSON.stringify(value)!==JSON.stringify(baseline[key])));
 cases.push({key:field.key,inputValue:value,behavior,patch});
 coverage.push({key:field.key,label:field.label,behavior,normalization:'PASS',calculationOrEdit:'PASS',databaseRoundTrip:'PENDING',browser:'BLOCKED_403'});
 const invalid=textKeys.has(field.key)?'x'.repeat(1001):field.key==='faltas1027'?'32':hourKeys.has(field.key)?'01:99':'-1.00';
 assert.throws(()=>normalize({...raw,[field.key]:invalid}),undefined,'Invalid input '+field.key);
}
const extraVariants={extraCaixa:'22.22',extraPericulosidade:'22.22',extraInsalubridade:'22.22',extraTeletrabalho:'22.22',receivesPericulosidade:true,supportGroup:true,receivesVA:false,chargeSerefi:false,commissionType:commissionTypes[1],commissionNet:'50.00',commissionIR:'50.00',commissionUseful:20,commissionRest:9,paid20:true,paymentDate:'2000-02-20',paymentStatus:'paid',healthMembers:raw.healthMembers.map(m=>({...m,name:m.role==='titular'?raw.C:'Novo dependente fictício'})),healthCopart:Object.fromEntries(raw.healthMembers.map(m=>[m.id,'99.00'])),healthMonthlyAdditions:{'unimed-titular':'99.00'}};
const extraPreserved=new Set(['supportGroup','receivesVA','chargeSerefi','commissionType','commissionNet','commissionIR','commissionUseful','commissionRest','healthMembers','healthCopart','healthMonthlyAdditions']);
for(const [key,value] of Object.entries(extraVariants)){
 const result=JSON.parse((await editedRecord(snapshot,month,employee,{...input,[key]:value},1))[0].data);
 if(extraPreserved.has(key))assert.deepEqual(result[key],baseline[key],key+' is preserved in monthly editing');
 else if(key!=='extraPericulosidade')assert.deepEqual(result[key],value,key+' should persist');
 else assert.equal(result[key],'0.00','Periculosidade derives from its flag');
 const behavior=extraPreserved.has(key)?'preserved':key==='extraPericulosidade'?'calculated':'editable';
 cases.push({key,inputValue:value,behavior,patch:Object.fromEntries(Object.entries(result).filter(([k,v])=>JSON.stringify(v)!==JSON.stringify(baseline[k])))});
 coverage.push({key,label:key,behavior,normalization:'PASS',calculationOrEdit:'PASS',databaseRoundTrip:'PENDING',browser:'BLOCKED_403'});
}
// Every legacy health slot must derive from the enrolled people and monthly copart.
for(const [prefix,plan] of [['unimed','unimed'],['uniodonto','uniodonto']]){
 assert.equal(baseline.healthMembers.filter(m=>m.plan===plan).length,5);
 for(let i=0;i<4;i++)assert.equal(baseline.healthMembers.find(m=>m.id===prefix+'-dep-'+i).name,'Dependente fictício '+i);
}
assert.equal(baseline.CQ,((Math.round((Number(baseline.O)+Number(baseline.commissionNet))*100*8/100))/100).toFixed(2));
const path=process.argv[2];
if(path){
 await mkdir(resolve(path),{recursive:true});
 await writeFile(resolve(path,'all-field-fixtures.json'),JSON.stringify({month,employee,raw,baseline,cases,snapshot}));
 await writeFile(resolve(path,'field-coverage.json'),JSON.stringify(coverage,null,2)+'\n');
}
console.log('PASS: '+fields.length+' catalog fields, '+Object.keys(extraVariants).length+' additional fields, '+fields.length+' invalid inputs; expectations cover editable/calculated/preserved/immutable fields. Database and browser require separate verification.');
