'use client';
import {createContext,useContext,useState} from 'react';
import {Plus} from 'lucide-react';
import {Button} from '@/components/ui/button';
import {Input} from '@/components/ui/input';
import {Dialog,DialogContent,DialogHeader,DialogTitle,DialogDescription} from '@/components/ui/dialog';
import {Select,SelectContent,SelectItem,SelectTrigger,SelectValue} from '@/components/ui/select';
const Context=createContext<{functions:string[];canEdit:boolean;busy:boolean;create:(name:string)=>Promise<string|undefined>}>({functions:[],canEdit:false,busy:false,create:async()=>undefined});
export const JobFunctionsProvider=Context.Provider;
export function JobFunctionInput({id,value,onChange,disabled}:any){
 const {functions,canEdit,busy,create}=useContext(Context),[open,setOpen]=useState(false),[name,setName]=useState('');
 const options=[...new Set([...functions,...(value?[value]:[])])].sort((a,b)=>a.localeCompare(b,'pt-BR'));
 async function save(){const saved=await create(name);if(saved){onChange(saved);setOpen(false);setName('');}}
 return <><div className="job-function-picker"><Select disabled={disabled||busy} value={value||''} onValueChange={onChange}><SelectTrigger id={id} className="field-select" aria-label="Função"><SelectValue placeholder="Selecione a função"/></SelectTrigger><SelectContent className="job-function-options">{options.map(option=><SelectItem key={option} value={option}>{option}</SelectItem>)}</SelectContent></Select><Button type="button" variant="outline" size="icon" disabled={disabled||busy||!canEdit} aria-label="Adicionar função" title="Adicionar função" onClick={()=>{setName('');setOpen(true);}}><Plus size={18}/></Button></div><Dialog open={open} onOpenChange={setOpen}><DialogContent><DialogHeader><DialogTitle>Adicionar função</DialogTitle><DialogDescription>A nova função ficará disponível no cadastro de todos os colaboradores.</DialogDescription></DialogHeader><div className="new-job-function"><label htmlFor="new-job-function-name">Nome da função</label><Input id="new-job-function-name" autoFocus maxLength={180} value={name} disabled={busy} onChange={e=>setName(e.target.value)} onKeyDown={e=>{if(e.key==='Enter'&&name.trim()&&!busy){e.preventDefault();void save();}}}/></div><Button disabled={busy||!name.trim()} onClick={save}>{busy?'Salvando…':'Salvar função'}</Button></DialogContent></Dialog></>;
}
