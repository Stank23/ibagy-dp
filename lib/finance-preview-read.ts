import {assertSameSiteRead,securityError} from './request-security';
import 'server-only';
import {reserveAuthAttempt} from './supabase-rate-limit';
import {supabaseAdminRequest} from './supabase-admin';
import {localUser} from './local-auth';

const monthOK=(m:string)=>/^20\d{2}-(0[1-9]|1[0-2])$/.test(m);
const q=(value:string)=>encodeURIComponent(value);
const validEmployeeId=(value:string)=>value.length>0&&value.length<=120&&!/[\u0000-\u001f]/.test(value);
type Row=Record<string,any>;
const read=(table:string,params='')=>supabaseAdminRequest<Row[]>('/rest/v1/'+table+'?select=*'+params);
export async function financePreviewRead(request:Request):Promise<Response>{
 const json=(data:unknown,status=200)=>Response.json(data,{status,headers:{'Cache-Control':'no-store'}});
 try{
  assertSameSiteRead(request);
  const user=await localUser();if(!user)return json({error:'Entre com seu usuário e senha para continuar.'},401);
  const url=new URL(request.url),month=url.searchParams.get('month')||'',employee=url.searchParams.get('employee');
  if(month&&!monthOK(month))return json({error:'Competência inválida.'},400);
  if(employee&&!validEmployeeId(employee))return json({error:'Identificador de colaborador inválido.'},400);
  if(url.searchParams.has('file')){if(!await reserveAuthAttempt('download',user.userId,40,60000))return json({error:'Limite de downloads atingido.'},429);const {financeFileDownload}=await import('./supabase-files');return await financeFileDownload(url.searchParams.get('file')||'');}
  if(url.searchParams.has('terminationMessage')){
   const id=url.searchParams.get('terminationMessage')||'';if(!monthOK(month)||!validEmployeeId(id))return json({error:'Informe competência e colaborador válidos.'},400);
   const rows=await read('records','&month=eq.'+q(month)+'&employee=eq.'+q(id));const row=rows[0];if(!row)return json({error:'Rescisão não encontrada.'},404);
   const values=JSON.parse(row.data);if(values._terminationCarry||!(values._termination||values.G==='Rescisão'&&values._excluded))return json({error:'Este registro não é uma rescisão da competência.'},400);
   const summary={...(values._terminationSettlement||{})};
   if(summary.loanRemaining===undefined){const installments=await read('installments','&employee=eq.'+q(id)+'&month=gte.'+q(month));summary.loanRemaining=(installments.reduce((sum,r)=>sum+Number(r.amount),0)/100).toFixed(2);}
   return json({values,summary});
  }
  const isAdmin=user.role==='admin';
  if(employee&&url.searchParams.get('historyOnly')==='1'){
   const history=await read('records','&employee=eq.'+q(employee)+'&order=month.desc');
   const periods=await read('periods');
   return json({history:history.map(r=>({...r,status:periods.find(p=>p.month===r.month)?.status??null}))});
  }
  const tables=['periods','employees','versions','minimum_wages','childcare_children','normative_wages','dsr_settings','dsr_city_settings','unimed_rates','uniodonto_fixed_rates','job_functions','allowances','loans','event_plans'] as const;
  const values=await Promise.all(tables.map(t=>read(t)));
  const data=Object.fromEntries(tables.map((t,i)=>[t,values[i]])) as Record<string,Row[]>;
  const [records,files,audit,installments]=await Promise.all([
   monthOK(month)?read('records','&month=eq.'+q(month)+'&order=employee.asc'):Promise.resolve([] as Row[]),
   monthOK(month)?supabaseAdminRequest<Row[]>('/rest/v1/files?select=id,month,kind,name,created&month=eq.'+q(month)+'&order=created.desc'):Promise.resolve([] as Row[]),
   isAdmin&&monthOK(month)?read('audit','&month=eq.'+q(month)+'&order=created.desc&limit=60'):Promise.resolve([] as Row[]),
   read('installments','&order=month.asc,number.asc')
  ]);
  data.records=records;data.files=files;data.audit=audit;data.installments=installments;
  const latest=(cutoff?:string):Row[]=>data.employees.flatMap((e:Row):Row[]=>{
   const versions=data.versions.filter(v=>v.employee===e.id&&(!cutoff||v.month<=cutoff)).sort((a,b)=>String(b.month).localeCompare(String(a.month)));
   const v=versions[0];if(!v)return [];
   if(cutoff){let d:Row;try{d=JSON.parse(v.data);}catch{return [];}if(String(d.D||'').slice(0,7)>cutoff)return [];}
   return [{...e,effective:v.month,data:v.data}];
  }).sort((a,b)=>String(a.registration).localeCompare(String(b.registration)));
  const periods:Row[]=data.periods.sort((a:Row,b:Row)=>String(b.month).localeCompare(String(a.month)));
  // Monthly records, file metadata and audit entries are already scoped server-side.
  const employeeRecords=employee?await read('records','&employee=eq.'+q(employee)+'&order=month.desc'):[];
  const history:Row[]=employeeRecords.map((r:Row):Row=>({...r,status:periods.find((p:Row)=>p.month===r.month)?.status??null}));
  const installmentRows:Row[]=data.installments.map((i:Row)=>({...i,periodStatus:periods.find(p=>p.month===i.month)?.status??null,included:data.records.find(r=>r.month===i.month&&r.employee===i.employee)?.employee??null}));
  return json({unimedRates:data.unimed_rates,uniodontoRates:data.uniodonto_fixed_rates,jobFunctions:data.job_functions.map(r=>r.name),dsrSettings:[...data.dsr_settings,...data.dsr_city_settings],userName:user.displayName,isAdmin,canEdit:isAdmin,periods,employees:latest(),bases:monthOK(month)?latest(month):[],records,files,audit,history,childcareChildren:data.childcare_children,normativeWages:data.normative_wages,minimumWages:data.minimum_wages,settings:data.allowances,eventPlans:data.event_plans,loans:data.loans,installments:installmentRows});
 }catch(e){const limited=securityError(e);if(limited)return limited;console.error('Supabase finance preview read failed');return json({error:'Não foi possível carregar os dados. Tente novamente.'},503);}
}
