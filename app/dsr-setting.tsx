'use client';
import {useEffect,useState} from 'react';
import {commissionDays,commissionAmounts} from '@/lib/commission';
import {Input} from '@/components/ui/input';
import {Button} from '@/components/ui/button';
export function DSRSetting({month,configured,periods,mutate,busy}:any){
 const [effective,setEffective]=useState(month),[useful,setUseful]=useState(''),[rest,setRest]=useState('');
 const current=configured.find((c:any)=>c.month===effective),days=commissionDays(effective),period=periods.find((p:any)=>p.month===effective),locked=period?.status==='closed'||period?.commission_status==='closed';
 useEffect(()=>{const d=current||commissionDays(effective);setUseful(String(d.useful));setRest(String(d.rest));},[effective,current?.revision]);
 let error='';try{commissionAmounts('0','',useful,rest,days.total);}catch(e:any){error=e.message;}
 return <section className="panel configuration-panel"><div className="panel-heading"><div><h2>Calendário DSR</h2><p>Total da verba variável ÷ dias úteis do mês × dias de descanso (domingos e feriados).</p></div></div><div className="configuration-body"><label>Competência<Input type="month" value={effective} disabled={busy} onChange={e=>{if(e.target.value)setEffective(e.target.value);}}/></label><label>Dias úteis do mês<Input type="number" min="1" max="31" step="1" value={useful} disabled={busy||locked} onChange={e=>setUseful(e.target.value)}/></label><label>Dias de descanso<Input type="number" min="0" max="30" step="1" value={rest} disabled={busy||locked} onChange={e=>setRest(e.target.value)}/></label><Button disabled={busy||locked||!!error} onClick={()=>mutate({action:'dsr_setting',month:effective,useful:Number(useful),rest:Number(rest),revision:current?.revision??0})}>Salvar calendário</Button></div><p className="configuration-foot">{days.total} dias na competência. Conte domingos e feriados sem duplicar datas. Confira os feriados locais e religiosos; a sugestão automática considera sábados como úteis. Ao salvar, as comissões abertas desta competência serão recalculadas.</p>{locked?<p className="configuration-foot">Competência ou comissão fechada. Reabra antes de alterar o calendário.</p>:error?<p className="configuration-foot" role="alert">{error}</p>:<p className="configuration-foot">{current?'Calendário cadastrado':'Sugestão automática — ainda não cadastrada'}</p>}</section>;
}
