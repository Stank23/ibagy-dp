import {financePreviewRead} from '@/lib/finance-preview-read';
import {financePreviewWrite} from '@/lib/finance-preview-write';
import {assertSameOrigin,readJSON,securityError} from '@/lib/request-security';
import {consumeRateLimit} from '@/lib/rate-limit';
import {calculationContext} from '@/lib/calculation-context';
import {refreshMonth} from '@/lib/month-refresh';
import {applyProvisions} from '@/lib/provisions';
import {commissionFinancialKeys} from '@/lib/commission';
import {childcareRefresh} from '@/lib/childcare';
import {validCPF,formatCPF} from '@/lib/cpf';
import {preserveCommission} from '@/lib/period-locks';
import {isAdministrator} from '@/lib/admin';
import {downloadResponse} from '@/lib/download-response';
import {database,bucket} from '@/lib/store';
import {getChatGPTUser} from '@/app/chatgpt-auth';
import {normalize,exportRows} from '@/lib/payroll';
import {styleExport} from '@/lib/export-format';
import * as XLSX from 'xlsx';
import {calculate,extraActions} from '@/lib/finance-service';
export const dynamic='force-dynamic';
const monthOK=(m:any)=>typeof m==='string'&&/^20\d{2}-(0[1-9]|1[0-2])$/.test(m);
const json=(v:any,status=200,timing?:string)=>Response.json(v,{status,headers:{'Cache-Control':'no-store',...(timing?{'Server-Timing':timing}:{})}});
const recurring=['gender','B','C','D','E','F','G','H','I','J','K','L','M','N','P','AG','AH','AI','AJ','AL','AN','AO','AP','AQ','AR','AS','AT','AU','AW','AX','AY','BA','BB','BC','BE','BF','BG','BI','BJ','BK','BM','BN','BO','BP','BR','BS','BT','BV','BW','BX','BZ','CA','CB','CD','CE','CF','CH','CU','CV','CW','CX'];
function base(data:any){return {...Object.fromEntries(recurring.map(k=>[k,data[k]||''])),receivesVA:data.receivesVA!==false,...Object.fromEntries(Object.entries(data).filter(([k])=>k.startsWith("extra")||["supportGroup","commissionType","healthMembers","receivesPericulosidade","chargeSerefi"].includes(k)))};}

export async function GET(r:Request){
 if(process.env.VERCEL)return financePreviewRead(r);
 const started=performance.now();
 try{const user=await getChatGPTUser();if(!user)return json({error:'Entre com seu usuário e senha para continuar.'},401);const db=database(),u=new URL(r.url),month=u.searchParams.get('month')||'',employee=u.searchParams.get('employee'),file=u.searchParams.get('file');const isAdmin=await isAdministrator(db,user);
 if(employee&&u.searchParams.get('historyOnly')==='1'){if(!monthOK(month))return json({error:'Competência inválida.'},400);const history=await db.prepare('SELECT r.*,p.status FROM records r JOIN periods p ON p.month=r.month WHERE r.employee=? ORDER BY r.month DESC').bind(employee).all();return json({history:history.results});}
 const messageEmployee=u.searchParams.get('terminationMessage');if(messageEmployee){if(!monthOK(month))return json({error:'Informe uma competência válida.'},400);const row:any=await db.prepare('SELECT data FROM records WHERE month=? AND employee=?').bind(month,messageEmployee).first();if(!row)return json({error:'Rescisão não encontrada.'},404);const values=JSON.parse(row.data);if(values._terminationCarry||!(values._termination||values.G==='Rescisão'&&values._excluded))return json({error:'Este registro não é uma rescisão da competência.'},400);const summary={...(values._terminationSettlement||{})};if(summary.loanRemaining===undefined){const balance=await db.prepare('SELECT COALESCE(SUM(amount),0) AS total FROM installments WHERE employee=? AND month>=?').bind(messageEmployee,month).first();summary.loanRemaining=(Number(balance?.total||0)/100).toFixed(2);}return json({values,summary});}
 if(file){await consumeRateLimit(db,'download',user.userId,40,60000);const f:any=await db.prepare('SELECT * FROM files WHERE id=?').bind(file).first();if(!f)return json({error:'Arquivo não encontrado'},404);const object=await bucket().get(f.key);if(!object)return json({error:'Arquivo indisponível'},404);return downloadResponse(object.body,f.name,object.httpMetadata?.contentType||'application/octet-stream',object.size);}
 const refreshStarted=performance.now();
 if(isAdmin&&monthOK(month)){await extraActions(db,{action:'sync_active',month},user.email);await refreshMonth(db,month);}
 const readStarted=performance.now();
 const [periods,employees,bases,records,files,audit,minimumWages,childcareChildren,normativeWages,dsrSettings,unimedRates,uniodontoRates,jobFunctions,settings,loans,installments,eventPlans,history]=await db.batch([
 db.prepare('SELECT * FROM periods ORDER BY month DESC'),
 db.prepare('SELECT e.*,v.month AS effective,v.data FROM employees e JOIN versions v ON v.employee=e.id WHERE v.month=(SELECT MAX(month) FROM versions WHERE employee=e.id) ORDER BY e.registration'),
 monthOK(month)?db.prepare('SELECT e.*,v.month AS effective,v.data FROM employees e JOIN versions v ON v.employee=e.id WHERE v.month=(SELECT MAX(month) FROM versions WHERE employee=e.id AND month<=?) AND substr(json_extract(v.data,"$.D"),1,7)<=? ORDER BY e.registration').bind(month,month):db.prepare('SELECT 1 WHERE 0'),
 monthOK(month)?db.prepare('SELECT * FROM records WHERE month=? ORDER BY employee').bind(month):db.prepare('SELECT 1 WHERE 0'),
 monthOK(month)?db.prepare('SELECT id,month,kind,name,created FROM files WHERE month=? ORDER BY created DESC').bind(month):db.prepare('SELECT 1 WHERE 0'),
 isAdmin&&monthOK(month)?db.prepare('SELECT * FROM audit WHERE month=? ORDER BY created DESC LIMIT 60').bind(month):db.prepare('SELECT 1 WHERE 0'),
 db.prepare('SELECT * FROM minimum_wages ORDER BY month DESC'),
 db.prepare('SELECT * FROM childcare_children ORDER BY child_name,id'),
 db.prepare('SELECT * FROM normative_wages ORDER BY month DESC'),
 db.prepare('SELECT * FROM dsr_settings ORDER BY month DESC'),
 db.prepare('SELECT * FROM unimed_rates ORDER BY month DESC'),
 db.prepare('SELECT * FROM uniodonto_fixed_rates ORDER BY month DESC'),
 db.prepare('SELECT name FROM job_functions ORDER BY name'),
 db.prepare('SELECT * FROM allowances ORDER BY month DESC'),
 db.prepare('SELECT * FROM loans ORDER BY start DESC,created DESC'),
 db.prepare('SELECT i.*,p.status AS periodStatus,r.employee AS included FROM installments i LEFT JOIN periods p ON p.month=i.month LEFT JOIN records r ON r.month=i.month AND r.employee=i.employee ORDER BY i.month,i.number'),
 db.prepare('SELECT * FROM event_plans ORDER BY start DESC,created DESC'),
 employee?db.prepare('SELECT r.*,p.status FROM records r JOIN periods p ON p.month=r.month WHERE r.employee=? ORDER BY r.month DESC').bind(employee):db.prepare('SELECT 1 WHERE 0')]);
 return json({unimedRates:unimedRates.results,uniodontoRates:uniodontoRates.results,jobFunctions:jobFunctions.results.map((r:any)=>r.name),dsrSettings:dsrSettings.results,userName:user.displayName,isAdmin,canEdit:isAdmin,periods:periods.results,employees:employees.results,bases:bases.results,records:records.results,files:files.results,audit:audit.results,history:history.results,childcareChildren:childcareChildren.results,normativeWages:normativeWages.results,minimumWages:minimumWages.results,settings:settings.results,eventPlans:eventPlans.results,loans:loans.results,installments:installments.results},200,`refresh;dur=${(readStarted-refreshStarted).toFixed(1)}, db;dur=${(performance.now()-readStarted).toFixed(1)}, total;dur=${(performance.now()-started).toFixed(1)}`);
 }catch(e){const limited=securityError(e);if(limited)return limited;console.error('Finance read failed');return json({error:'Não foi possível carregar os dados. Tente novamente.'},503);}
}
export async function POST(r:Request){
 if(process.env.VERCEL)return financePreviewWrite(r);
 try{assertSameOrigin(r);const user=await getChatGPTUser();if(!user)return json({error:'Acesso restrito.'},401);const db=database();if(!await isAdministrator(db,user))return json({error:'Somente o administrador pode alterar os dados.'},403);await consumeRateLimit(db,'finance-write',user.userId,120,60000);const body:any=await readJSON(r);const {action,month}=body;if(action==='export')await consumeRateLimit(db,'export',user.userId,10,60000);if(!monthOK(month))return json({error:'Informe uma competência válida.'},400);
 const audit=(action:string,detail:any)=>db.prepare('INSERT INTO audit(id,month,action,actor,created,detail) VALUES(?,?,?,?,?,?)').bind(crypto.randomUUID(),month,action,user.email,new Date().toISOString(),JSON.stringify(detail));
 const extra=await extraActions(db,body,user.email);if(extra)return json(extra);
 if(action==='employee'){
  let data=normalize(body.data);if(!data.E)return json({error:'O CPF é obrigatório.'},400);if(!validCPF(data.E))return json({error:'CPF inválido. Confira os dígitos antes de cadastrar.'},400);data.E=formatCPF(data.E);data.receivesVA=body.data.receivesVA!==false;if(!data.B||!data.C||!data.H||!/^\d{4}-\d{2}-\d{2}$/.test(data.D))return json({error:'Preencha matrícula, nome, data de admissão e filial.'},400);if(data.receivesVA&&!await db.prepare('SELECT month FROM allowances WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month).first())return json({error:'Configure o valor comum do vale-alimentação para esta vigência antes de cadastrar.'},400);const effective=body.id?month:data.D.slice(0,7);data.AG='0.00';const id=body.id||crypto.randomUUID();const active=body.active===false?0:1;
  if(body.id){const e:any=await db.prepare('SELECT * FROM employees WHERE id=?').bind(id).first();if(!e)return json({error:'Colaborador não encontrado'},404);if(e.registration!==data.B)return json({error:'A matrícula é fixa para preservar o histórico.'},400);}
  await db.batch([db.prepare('INSERT INTO employees(id,registration,active) VALUES(?,?,?) ON CONFLICT(id) DO UPDATE SET active=excluded.active').bind(id,data.B,active),db.prepare('INSERT INTO versions(employee,month,data) VALUES(?,?,?) ON CONFLICT(employee,month) DO UPDATE SET data=excluded.data').bind(id,effective,JSON.stringify(base(data))),audit('Cadastro atualizado',{employee:id,effective})]);if(data.supportGroup!==undefined){await db.prepare(`UPDATE records SET data=json_set(data,'$.supportGroup',json(CASE WHEN (SELECT json_extract(v.data,'$.supportGroup') FROM versions v WHERE v.employee=records.employee AND v.month<=records.month ORDER BY v.month DESC LIMIT 1)=1 THEN 'true' ELSE 'false' END)),revision=revision+1 WHERE employee=? AND month>=? AND month IN(SELECT month FROM periods WHERE status='open')`).bind(id,effective).run();}await db.prepare(`UPDATE records SET data=json_set(data,'$.gender',COALESCE((SELECT json_extract(v.data,'$.gender') FROM versions v WHERE v.employee=records.employee AND v.month<=records.month ORDER BY v.month DESC LIMIT 1),'Não informado')),revision=revision+1 WHERE employee=? AND month>=? AND month IN(SELECT month FROM periods WHERE status='open')`).bind(id,effective).run();await childcareRefresh(db,effective,id).run();return json({ok:true,id});
 }
 if(action==='period'){
  const exists=await db.prepare('SELECT month FROM periods WHERE month=?').bind(month).first();if(exists)return json({error:'Esta competência já existe. Selecione-a no histórico.'},409);
  const eligible=await db.prepare('SELECT e.id,v.data FROM employees e JOIN versions v ON v.employee=e.id WHERE e.active=1 AND v.month=(SELECT MAX(month) FROM versions WHERE employee=e.id AND month<=?) AND substr(json_extract(v.data,"$.D"),1,7)<=?').bind(month,month).all();const shared=await calculationContext(db,month);const inserts=await Promise.all(eligible.results.map(async(row:any)=>db.prepare('INSERT INTO records(month,employee,data) VALUES(?,?,?)').bind(month,row.id,JSON.stringify(await calculate(db,JSON.parse(row.data),row.id,month,shared)))));await db.batch([db.prepare('INSERT INTO periods(month,status) VALUES(?,?)').bind(month,'open'),...inserts,audit('Competência aberta',{})]);return json({ok:true});
 }
 const period:any=await db.prepare('SELECT * FROM periods WHERE month=?').bind(month).first();if(!period)return json({error:'Abra a competência antes de continuar.'},400);
 if(action==='commission_close'||action==='commission_reopen'){
  if(period.status!=='open')return json({error:'Reabra a folha na visão geral antes de alterar o fechamento da comissão.'},409);
  const reopening=action==='commission_reopen';if(reopening&&String(body.reason||'').trim().length<5)return json({error:'Informe o motivo da reabertura da comissão.'},400);
  const result=await db.prepare("UPDATE periods SET commission_status=? WHERE month=? AND status='open' AND commission_status=?").bind(reopening?'open':'closed',month,reopening?'closed':'open').run();
  if(!result.meta.changes)return json({error:'Situação alterada. Atualize a competência.'},409);
  await audit(reopening?'Comissão reaberta':'Comissão fechada',{reason:body.reason||''}).run();return json({ok:true});
 }
 if(action==='close'||action==='reopen'){
  const next=action==='close'?'closed':'open';if(action==='reopen'&&(!body.reason||String(body.reason).trim().length<5))return json({error:'Informe o motivo da reabertura.'},400);
  await db.batch([db.prepare("UPDATE periods SET status=?,commission_status=CASE WHEN ?='closed' THEN 'closed' ELSE commission_status END WHERE month=?").bind(next,next,month),audit(action==='close'?'Competência fechada':'Competência reaberta',{reason:body.reason||''})]);return json({ok:true});
 }
 if(action==='record'){
  const previous:any=await db.prepare('SELECT data FROM records WHERE employee=? AND month=?').bind(body.employee,month).first();if(!previous)return json({error:'Lançamento não encontrado'},404);const old=JSON.parse(previous.data);if(old._excluded===true)return json({error:'Reinclua o colaborador na folha antes de editar os lançamentos.'},409);let d=normalize(body.data);if(d.B!==old.B)return json({error:'A matrícula não pode ser alterada no lançamento.'},400);d.P=old.P;d.commissionType=old.commissionType;d.supportGroup=old.supportGroup;d.gender=old.gender;d.receivesChildcare=old.receivesChildcare;d.lastWorkedDay=old.lastWorkedDay;d.healthMembers=old.healthMembers;d.healthCopart=old.healthCopart;d.healthMonthlyAdditions=old.healthMonthlyAdditions;d._serefiAuto=old._serefiAuto||0;for(const key of ['CK','AM']){d['_eventAuto'+key]=old['_eventAuto'+key]||0;if(Number(d[key]||0)*100<d['_eventAuto'+key])return json({error:'O valor não pode ser menor que as parcelas automáticas desta competência.'},400);}d._active=old._active;d.receivesVA=old.receivesVA!==false;d.chargeSerefi=old.chargeSerefi!==false;d=await calculate(db,d,body.employee,month);d.paid20=Boolean(body.data.paid20);d.paymentDate=String(body.data.paymentDate||'');d.paymentStatus=body.data.paymentStatus==='paid'?'paid':'pending';for(const key of commissionFinancialKeys)if(Object.hasOwn(old,key))d[key]=old[key];d=applyProvisions(preserveCommission(d,old,period));
  const result=await db.prepare(`UPDATE records SET data=?,revision=revision+1 WHERE month=? AND employee=? AND revision=? AND EXISTS(SELECT 1 FROM periods WHERE month=? AND status='open' AND commission_status=?)`).bind(JSON.stringify(d),month,body.employee,body.revision,month,period.commission_status).run();
  if(!result.meta.changes)return json({error:'Mês fechado ou registro alterado. Atualize os dados antes de salvar.'},409);await audit('Lançamento atualizado',{employee:body.employee,revision:body.revision+1}).run();return json({ok:true});
 }
 if(action==='include'){
  if(period.status!=='open')return json({error:'Competência fechada.'},409);const v:any=await db.prepare('SELECT data FROM versions WHERE employee=? AND month<=? ORDER BY month DESC LIMIT 1').bind(body.employee,month).first();if(!v||JSON.parse(v.data).D.slice(0,7)>month)return json({error:'O colaborador só pode ser incluído a partir da competência de admissão.'},400);
  await db.batch([db.prepare(`INSERT INTO records(month,employee,data) SELECT ?,?,? WHERE EXISTS(SELECT 1 FROM periods WHERE month=? AND status='open') ON CONFLICT(month,employee) DO NOTHING`).bind(month,body.employee,JSON.stringify(await calculate(db,JSON.parse(v.data),body.employee,month)),month),audit('Colaborador incluído',{employee:body.employee})]);return json({ok:true});
 }
 if(action==='export'){
  await refreshMonth(db,month);
  const kind=body.kind;const rows=await db.prepare('SELECT * FROM records WHERE month=? ORDER BY employee').bind(month).all();if(!rows.results.length)return json({error:'A competência não tem colaboradores.'},400);
  const sheets=exportRows(kind,month,rows.results);const wb=XLSX.utils.book_new();for(const [name,values] of Object.entries(sheets)){const s=XLSX.utils.aoa_to_sheet(values as any[],{cellDates:false});s['!cols']=Array.from({length:34},(_,i)=>({wch:i===2?38:22}));if(kind==='payroll'&&name==='Principal'&&s.H7)s.H7.z='mm/yyyy';XLSX.utils.book_append_sheet(wb,s,name);}
  const id=crypto.randomUUID(),ext=kind==='commission'?'xlsx':'xls',name=`IBAGY-${kind==='commission'?'Comissao-dia20':kind==='health'?'Unimed-Uniodonto':'Folha-principal'}-${month}-${id.slice(0,6)}.${ext}`,key=`exports/${month}/${id}.${ext}`;
  const bytes=styleExport(XLSX.write(wb,{type:'array',bookType:ext==='xls'?'biff8':'xlsx'}),ext);await bucket().put(key,bytes,{httpMetadata:{contentType:ext==='xls'?'application/vnd.ms-excel':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'}});
  await db.batch([db.prepare('INSERT INTO files(id,month,kind,name,key,created) VALUES(?,?,?,?,?,?)').bind(id,month,kind,name,key,new Date().toISOString()),audit('Arquivo exportado',{file:id,kind,revisions:rows.results.map((r:any)=>({employee:r.employee,revision:r.revision}))})]);return json({ok:true,id,name});
 }
 return json({error:'Operação inválida'},400);
 }catch(e:any){const limited=securityError(e);if(limited)return limited;console.error('Finance write failed');return json({error:e.message?.includes('UNIQUE')?'Matrícula ou competência já cadastrada.':e instanceof Error&&e.name==='Error'&&e.message&&e.message.length<=250&&!/SQL|D1|constraint|syntax|no such|undefined|null|bind|TypeError|Unexpected|stack/i.test(e.message)?e.message:'Não foi possível salvar. Seus dados permanecem na tela.'},400);}
}
