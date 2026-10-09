import {isAdministrator} from '@/lib/admin';
import {database} from '@/lib/store';
import Workspace from '../workspace';
import {requireChatGPTUser} from '../chatgpt-auth';
import {notFound} from 'next/navigation';
export const dynamic='force-dynamic';
export default async function Page({params}:any){const {section}=await params;const views:Record<string,string>={'conferencia-da-folha':'review','auxilio-creche':'childcare',rescisoes:'terminations',lancamentos:'entries',cadastro:'registration',colaboradores:'base',exportacao:'exports',emprestimos:'loans',comissoes:'commissions',configuracoes:'settings',coparticipacao:'copart',reajustes:'adjustments',administracao:'admin',relatorios:'reports'};if(!views[section])notFound();return <Protected section={section} view={views[section]}/>;}

async function Protected({section,view}:{section:string;view:string}){const user=await requireChatGPTUser('/'+section);if(view==='admin'&&!await isAdministrator(database(),user))notFound();return <Workspace initialView={view}/>;}
