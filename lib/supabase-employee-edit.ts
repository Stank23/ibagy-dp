import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {normalize} from './payroll';
import {validCPF,formatCPF} from './cpf';
import {applyChildcare} from './childcare';
import {applyProvisions} from './provisions';
import {CalculationConflict,CalculationInputError} from './supabase-calculation';
const recurring=['gender','B','C','D','E','F','G','H','I','J','K','L','M','N','P','AG','AH','AI','AJ','AL','AN','AO','AP','AQ','AR','AS','AT','AU','AW','AX','AY','BA','BB','BC','BE','BF','BG','BI','BJ','BK','BM','BN','BO','BP','BR','BS','BT','BV','BW','BX','BZ','CA','CB','CD','CE','CF','CH','CU','CV','CW','CX'];
export function employeeEditChanges(snapshot:any,body:any){
 let data;try{data=normalize(body.data);}catch(e){throw new CalculationInputError(e instanceof Error?e.message:'Cadastro inválido.');}
 if(!validCPF(data.E))throw new CalculationInputError('CPF inválido. Confira os dígitos antes de cadastrar.');
 data.E=formatCPF(data.E);data.receivesVA=body.data.receivesVA!==false;data.AG='0.00';
 if(!data.B||!data.C||!data.H||!/^\d{4}-\d{2}-\d{2}$/.test(data.D))throw new CalculationInputError('Preencha matrícula, nome, data de admissão e filial.');
 const employee=snapshot.employees.find((e:any)=>e.id===body.id);if(!employee)throw new CalculationInputError('Colaborador não encontrado.');
 if(data.B!==employee.registration)throw new CalculationInputError('A matrícula é fixa para preservar o histórico.');
 const source=snapshot.versions.filter((v:any)=>v.employee===body.id&&v.month<=body.month).sort((a:any,b:any)=>b.month.localeCompare(a.month))[0];
 if(!source||typeof body.expectedData!=='string'||source.data!==body.expectedData||source.month!==body.expectedEffective)throw new CalculationConflict('O cadastro mudou. Atualize os dados antes de editar.');
 if(data.receivesVA&&!snapshot.allowances.some((r:any)=>r.month<=body.month))throw new CalculationInputError('Configure o vale-alimentação para esta vigência.');
 const base={...Object.fromEntries(recurring.map(k=>[k,data[k]||''])),receivesVA:data.receivesVA,...Object.fromEntries(Object.entries(data).filter(([k])=>k.startsWith('extra')||['supportGroup','commissionType','healthMembers','receivesPericulosidade','chargeSerefi'].includes(k)))};
 const versions=[...snapshot.versions.filter((v:any)=>!(v.employee===body.id&&v.month===body.month)),...snapshot.future_versions,{employee:body.id,month:body.month,data:JSON.stringify(base)}];
 const records=snapshot.affected_records.map((row:any)=>{
  const latest=versions.filter((v:any)=>v.employee===body.id&&v.month<=row.month).sort((a:any,b:any)=>b.month.localeCompare(a.month))[0];
  const b=latest?JSON.parse(latest.data):{},old=JSON.parse(row.data),next={...old,gender:b.gender||'Não informado'};
  if(data.supportGroup!==undefined)next.supportGroup=b.supportGroup===true;
  const normative=[...snapshot.normative_wages,...snapshot.future_normative_wages].filter((r:any)=>r.month<=row.month).sort((a:any,b:any)=>b.month.localeCompare(a.month))[0];
  const d=next._excluded===true?next:applyProvisions(applyChildcare(next,normative,snapshot.childcare_children.filter((c:any)=>c.employee===body.id),row.month));
  return {month:row.month,employee:body.id,revision:row.revision,data:JSON.stringify(d)};
 });
 return {data:base,active:body.active===false?0:1,records};
}
export async function saveEmployeeEdit(body:any,actor:string){
 const {snapshot,token}=await supabaseAdminRequest<any>('/rest/v1/rpc/finance_employee_edit_snapshot',{method:'POST',body:{p_month:body.month,p_employee:body.id}});
 const changes=employeeEditChanges(snapshot,body);
 const saved=await supabaseAdminRequest<boolean>('/rest/v1/rpc/save_finance_employee_edit',{method:'POST',body:{p_month:body.month,p_employee:body.id,p_actor:actor,p_token:token,p_data:changes.data,p_active:changes.active,p_records:changes.records}});
 if(!saved)throw new CalculationConflict('O cadastro ou a folha mudou. Atualize antes de salvar.');
 return {ok:true,id:body.id};
}
