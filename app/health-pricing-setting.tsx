'use client';
import {useEffect,useState} from 'react';
import {activeHealthRate} from '@/lib/health-pricing';
import {Input} from '@/components/ui/input';
import {Button} from '@/components/ui/button';
export function HealthPricingSetting({month,unimed=[],uniodonto=[],mutate,busy}:any){return <><PlanRateSetting key={'unimed-'+month} plan="unimed" month={month} configured={unimed} mutate={mutate} busy={busy}/><PlanRateSetting key={'uniodonto-'+month} plan="uniodonto" month={month} configured={uniodonto} mutate={mutate} busy={busy}/></>;}
function PlanRateSetting({plan,month,configured,mutate,busy}:any){
 const ageBased=plan==='unimed',keys=ageBased?['young','middle','senior']:['amount'];
 const [effective,setEffective]=useState(month),[values,setValues]=useState<any>({});const current=configured.find((r:any)=>r.month===effective),active=activeHealthRate(configured,effective);
 useEffect(()=>{setValues(Object.fromEntries(keys.map(k=>[k,active?(active[k]/100).toFixed(2):''])));},[effective,active?.month,active?.revision]);
 const inputs=ageBased?[['young','0 a 43 anos'],['middle','44 a 58 anos'],['senior','59 anos ou mais']]:[['amount','Mensalidade por participante']];
 return <section className="panel configuration-panel"><div className="panel-heading"><div><h2>{ageBased?'Unimed · mensalidades por idade':'Uniodonto · mensalidade única'}</h2><p>{ageBased?'Aplicação automática pela data de nascimento, com mudança de faixa no mês do aniversário.':'O mesmo valor para titulares e dependentes, independentemente da idade.'}</p></div></div><div className="configuration-body"><label>Vigência inicial<Input type="month" value={effective} disabled={busy} onChange={e=>{if(e.target.value)setEffective(e.target.value);}}/></label>{inputs.map(([key,label])=><label key={key}>{label} · R$<Input type="number" min="0" step="0.01" value={values[key]??''} disabled={busy} onChange={e=>setValues({...values,[key]:e.target.value})}/></label>)}<Button disabled={busy||keys.some(k=>!/^\d{1,8}(\.\d{1,2})?$/.test(String(values[k]??'')))} onClick={()=>mutate({action:ageBased?'unimed_rates':'uniodonto_fixed_rate',month:effective,...values,revision:current?.revision??0})}>Salvar valores</Button></div><p className="configuration-foot">Os valores valem a partir da vigência informada até a próxima configuração. Folhas fechadas mantêm os valores registrados.</p></section>;
}
