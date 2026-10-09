import {genders} from './childcare';
import {commissionTypes} from './benefits';
export const situations=['Aprendiz','Diretoria','Estagiário','Licença maternidade','Normal','Perícia','Rescisão'];
export const stores=['Matriz','Biguaçu','Campeche','Centro','Ingleses','Kobrasol','Palhoça','Trindade'];
export const departments=['Manutenção','Administrativo','Administrativo Condomínio','Administrativo IPTU','Administrativo Água/Luz','Agente de Visitas','Arquivo','Comercial','Comercial Captador','Comercial Leads','Comercial Sub','Condomínio Ibagy','Contratos Adm','Contratos Comercial','CPD','Desocupação','Desocupação Adm','Diretora','Financeiro','Financeiro Serviço Externo','Guardador veículos','Jurídico','Limpeza','Locação','Manutenção Externa','Manutenção terceiros','Qualidade','Recepção','Relacionamento','Renovações','RH','Seguro','Vistoria Adm','Vistoria Desocupação','Vistoria Ocupação'];
export const choices:Record<string,string[]>={gender:genders,G:situations,H:stores,J:departments,P:commissionTypes};
export const removedRegistration=new Set(['AG','P','AH','AO','AQ','AR','I','L','M','AP','AI','AL','AN','AJ','CV','CW','CX','N']);
export const commissionKeys=['P','T','U','V','W','X','Y','Z','AA','DJ'];
export function monthLabel(m:string){return /^\d{4}-\d{2}$/.test(m)?`${m.slice(5)}/${m.slice(0,4)}`:m;}
