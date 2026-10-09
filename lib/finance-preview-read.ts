import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {localUser} from './local-auth';

const monthOK=(m:string)=>/^20\d{2}-(0[1-9]|1[0-2])$/.test(m);
const q=(value:string)=>encodeURIComponent(value);
type Row=Record<string,any>;
const read=(table:string,params='')=>supabaseAdminRequest<Row[]>('/rest/v1/'+table+'?select=*'+params);
export async function financePreviewRead(request:Request):Promise<Response>{
 const json=(data:unknown,status=200)=>Response.json(data,{status,headers:{'Cache-Control':'no-store'}});
 try{
  const user=await localUser();if(!user)return json({error:'Entre com seu usuário e senha para continuar.'},401);
  const url=new URL(request.url),month=url.searchParams.get('month')||'',employee=url.searchParams.get('employee');
  if(month&&!monthOK(month))return json({error:'Competência inválida.'},400);
  if(url.searchParams.has('file')||url.searchParams.has('terminationMessage'))return json({error:'Esta operação ainda não foi migrada para o ambiente de testes.'},503);
  const isAdmin=user.role==='admin';
  if(employee&&url.searchParams.get('historyOnly')==='1'){
   if(!monthOK(month))return json({error:'Competência inválida.'},400);
   const history=await read('records','&employee=eq.'+q(employee)+'&order=month.desc');
   const periods=await read('periods');
   return json({history:history.map(r=>({...r,status:periods.find(p=>p.month===r.month)?.status??null}))});
  }
  const tables=['periods','employees','versions','records','files','audit','minimum_wages','childcare_children','normative_wages','dsr_settings','unimed_rates','uniodonto_fixed_rates','job_functions','allowances','loans','installments','event_plans'] as const;
  const values=await Promise.all(tables.map(t=>read(t)));
  const data=Object.fromEntries(tables.map((t,i)=>[t,values[i]])) as Record<string,Row[]>;
  const latest=(cutoff?:string):Row[]=>data.employees.flatMap((e:Row):Row[]=>{
   const versions=data.versions.filter(v=>v.employee===e.id&&(!cutoff||v.month<=cutoff)).sort((a,b)=>String(b.month).localeCompare(String(a.month)));
   const v=versions[0];if(!v)return [];
   if(cutoff){let d:Row;try{d=JSON.parse(v.data);}catch{return [];}if(String(d.D||'').slice(0,7)>cutoff)return [];}
   return [{...e,effective:v.month,data:v.data}];
  }).sort((a,b)=>String(a.registration).localeCompare(String(b.registration)));
  const periods:Row[]=data.periods.sort((a:Row,b:Row)=>String(b.month).localeCompare(String(a.month)));
  const records=monthOK(month)?data.records.filter(r=>r.month===month).sort((a,b)=>String(a.employee).localeCompare(String(b.employee))):[];
  const files=monthOK(month)?data.files.filter(f=>f.month===month):[];
  const audit=isAdmin&&monthOK(month)?data.audit.filter(a=>a.month===month).slice(0,60):[];
  const history:Row[]=employee?data.records.filter((r:Row)=>r.employee===employee).map((r:Row):Row=>({...r,status:periods.find((p:Row)=>p.month===r.month)?.status??null})).sort((a:Row,b:Row)=>String(b.month).localeCompare(String(a.month))):[];
  const installmentRows:Row[]=data.installments.map((i:Row)=>({...i,periodStatus:periods.find(p=>p.month===i.month)?.status??null,included:data.records.find(r=>r.month===i.month&&r.employee===i.employee)?.employee??null}));
  return json({unimedRates:data.unimed_rates,uniodontoRates:data.uniodonto_fixed_rates,jobFunctions:data.job_functions.map(r=>r.name),dsrSettings:data.dsr_settings,userName:user.displayName,isAdmin,canEdit:false,periods,employees:latest(),bases:monthOK(month)?latest(month):[],records,files,audit,history,childcareChildren:data.childcare_children,normativeWages:data.normative_wages,minimumWages:data.minimum_wages,settings:data.allowances,eventPlans:data.event_plans,loans:data.loans,installments:installmentRows});
 }catch{console.error('Supabase finance preview read failed');return json({error:'Não foi possível carregar os dados. Tente novamente.'},503);}
}
