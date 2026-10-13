import {test} from 'node:test';
import assert from 'node:assert/strict';
import {targetURL,allowWrite,verifyFixture,previewHost} from './guards.mjs';
const origin='https://'+previewHost,mode={origin,enabled:true,employee:'fixture-id'};
test('production, arbitrary hosts and credential URLs rejected',()=>{
 assert.equal(targetURL(origin+'/configuracoes'),origin);
 for(const u of ['https://ibagy-dp.vercel.app','http://'+previewHost,origin+'?token=secret','https://user:secret@'+previewHost])assert.throws(()=>targetURL(u));
});
test('history, unrelated employees, configuration, export and cross-origin writes blocked',()=>{
 const body={action:'record',month:'2099-12',employee:'fixture-id',revision:1};
 assert.equal(allowWrite(origin+'/api/finance','POST',body,mode),true);
 for(const change of [{month:'2026-09'},{employee:'another-id'},{action:'period'},{action:'export'},{action:'normative_wage'},{revision:0}])assert.equal(allowWrite(origin+'/api/finance','POST',{...body,...change},mode),false);
 assert.equal(allowWrite(origin+'/api/finance','POST',body,{...mode,enabled:false}),false);
 assert.equal(allowWrite('https://other.invalid/api/auth','POST',{action:'login'},mode),false);
 assert.equal(allowWrite(origin+'/api/auth','POST',{action:'create'},mode),false);
 assert.equal(allowWrite(origin+'/api/auth','POST',{action:'login'},mode),true);
});
test('fixture rejected unless uniquely named, synthetic and in open dedicated month',()=>{
 const d={canEdit:true,periods:[{month:'2099-12',status:'open'}],records:[{employee:'fixture-id',month:'2099-12',data:JSON.stringify({B:'TEST-UI-001',C:'TESTE UI FICTICIO'})}]};
 assert.equal(verifyFixture(d,'TEST-UI-001').employee,'fixture-id');
 for(const bad of [{...d,canEdit:false},{...d,periods:[]},{...d,records:[...d.records,...d.records]},{...d,records:[{...d.records[0],data:JSON.stringify({B:'TEST-UI-001',C:'Pessoa real'})}]}])assert.throws(()=>verifyFixture(bad,'TEST-UI-001'));
});
