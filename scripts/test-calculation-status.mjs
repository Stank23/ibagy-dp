import './test-module-hooks.mjs';
import assert from 'node:assert/strict';
const {hasAutomaticResults,pendingAutomaticCount}=await import('../lib/calculation-status.ts');
const {automaticCostKeys}=await import('../lib/provisions.ts');
const zero=Object.fromEntries(['salaryCompetencia','M',...automaticCostKeys].map(key=>[key,'0.00']));
assert.equal(hasAutomaticResults(zero),true,'Calculated zero is complete');
for(const key of Object.keys(zero)){
 const missing={...zero};delete missing[key];assert.equal(hasAutomaticResults(missing),false,key);
 for(const value of [null,undefined,'','NaN','Infinity'])assert.equal(hasAutomaticResults({...zero,[key]:value}),false,key);
}
const incomplete={K:'3000.00',C:'Colaborador fictício'};
assert.equal(pendingAutomaticCount([{values:zero},{values:incomplete},{values:{...incomplete,_excluded:true}}]),1);
assert.equal(pendingAutomaticCount([]),0);
console.log('PASS: missing salary/provision fields are detected, calculated zero accepted, excluded records ignored and malformed results rejected');
