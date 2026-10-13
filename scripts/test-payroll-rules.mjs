// Regression tests for original v77 payroll arithmetic (no database writes).
// Run: node --experimental-strip-types scripts/test-payroll-rules.mjs
import assert from 'node:assert/strict';
import {readFile,writeFile,unlink} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {randomUUID} from 'node:crypto';

const source=await readFile(new URL('../lib/rules.ts',import.meta.url),'utf8');
const expected="import {cents} from './payroll';";
if(!source.includes(expected))throw Error('Payroll dependency changed; update the test harness.');
const isolated=source.replace(expected,"const cents=(v:any)=>{const [a,b='']=String(v||'0').split('.');return Number(a)*100+Number(b.padEnd(2,'0'));};");
const path=join(tmpdir(),'ibagy-rules-'+randomUUID()+'.ts');
try{
 await writeFile(path,isolated);
 const r=await import('file://'+path);
 assert.equal(r.quinquennium('3000.00','2021-10-15','2026-10'),15000);
 assert.equal(r.quinquennium('3000.00','2021-10-15','2026-09'),0);
 assert.equal(r.foodAllowance(90000,'2026-10-16','2026-10'),45000);
 assert.equal(r.foodAllowance(90000,'2026-09-16','2026-10'),90000);
 const installments=r.schedule(10000,3,'2026-10');
 assert.equal(installments.reduce((sum,p)=>sum+p.amount,0),10280);
 assert.equal(installments[0].fee,280);
 assert.equal(installments[1].fee,0);
 assert.equal(r.automatic({K:'3000.00',D:'2021-10-15'},'2026-10',90000).M,'150.00');
 console.log('PASS: 8 payroll arithmetic regression checks');
}finally{await unlink(path).catch(()=>{});}
