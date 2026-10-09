'use client';
import {useEffect} from 'react';
import {Building2,Plus,ClipboardList,Users,FileSpreadsheet,Database,Percent,LockKeyhole,X} from 'lucide-react';
import {Sidebar,SidebarHeader,SidebarContent,SidebarFooter,SidebarMenu,SidebarMenuItem,SidebarMenuButton,useSidebar} from '@/components/ui/sidebar';
import {Button} from '@/components/ui/button';
const sections=[
 ['overview','Visão geral',Building2],['registration','Cadastro',Plus],['entries','Lançamentos',ClipboardList],['review','Conferência da Folha',FileSpreadsheet],['terminations','Rescisões',Users],['reports','Relatórios',FileSpreadsheet],['base','Colaboradores',Users],['commissions','Comissões',ClipboardList],['childcare','Auxílio-creche',Users],['copart','Plano de Saúde',Users],['settings','Configurações',Database],['loans','Empréstimos SEREFI',Database],['adjustments','Reajustes',Percent],['admin','Administração',LockKeyhole],
] as const;
export function WorkspaceNavigation({tab,onNavigate,isAdmin,canEdit}:{tab:string;onNavigate:(tab:string)=>void;isAdmin:boolean;canEdit:boolean}){
 const {setOpenMobile,isMobile}=useSidebar();
 useEffect(()=>{setOpenMobile(false);},[tab,setOpenMobile,isMobile]);
 return <Sidebar className="ibagy-sidebar"><SidebarHeader className="ibagy-sidebar-header"><div className="sidebar-brand-row"><img src="/ibagy-logo.png" alt="IBAGY"/><Button className="sidebar-close" variant="ghost" size="icon" aria-label="Fechar menu" onClick={()=>setOpenMobile(false)}><X/></Button></div><p>Departamento Pessoal</p></SidebarHeader><SidebarContent className="ibagy-sidebar-content"><nav aria-label="Navegação principal"><SidebarMenu>{sections.filter(([key])=>key!=='admin'||isAdmin).map(([key,label,Icon])=><SidebarMenuItem key={key}><SidebarMenuButton size="lg" isActive={tab===key} aria-current={tab===key?'page':undefined} onClick={()=>{onNavigate(key);setOpenMobile(false);}}><Icon/><span>{label}</span></SidebarMenuButton></SidebarMenuItem>)}</SidebarMenu></nav></SidebarContent><SidebarFooter className="ibagy-sidebar-footer"><LockKeyhole size={16}/><span>{canEdit?'Administrador':'Consulta'}</span></SidebarFooter></Sidebar>;
}
