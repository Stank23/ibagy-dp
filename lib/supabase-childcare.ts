import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';
import {lastChildcareMonth} from './childcare';
import {CalculationInputError,CalculationConflict} from './supabase-calculation';
export function childcareInput(body:any){
 if(body.action==='childcare_sync')return null;
 const id=String(body.id||''),employee=String(body.employee||''),name=String(body.name||'').trim(),birthDate=String(body.birthDate||'');
 if(!/^[-a-zA-Z0-9]{20,80}$/.test(id)||!employee||employee.length>120||!name||name.length>200)throw new CalculationInputError('Preencha colaboradora, nome do filho(a) e data de nascimento.');
 try{lastChildcareMonth(birthDate);}catch(e){throw new CalculationInputError((e as Error).message);}
 if(body.revision!==undefined&&(!Number.isSafeInteger(body.revision)||body.revision<1))throw new CalculationInputError('Revisão inválida.');
 return {id,employee,name,birthDate,...(body.revision===undefined?{}:{revision:body.revision})};
}
export async function saveChildcare(body:any,actor:string){
 const child=childcareInput(body);
 const result=await supabaseAdminRequest<{ok:boolean;id?:string;changed?:number}>('/rest/v1/rpc/save_finance_childcare',{method:'POST',body:{p_month:body.month,p_actor:actor,p_action:body.action,p_child:child}});
 if(!result.ok)throw new CalculationConflict('Cadastro alterado, filho(a) duplicado ou colaboradora sem configuração válida. Atualize os dados.');
 return result;
}
