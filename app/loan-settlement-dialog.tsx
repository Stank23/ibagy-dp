'use client';
import {useState} from 'react';
import {Dialog,DialogContent,DialogHeader,DialogTitle,DialogDescription} from '@/components/ui/dialog';
import {Button} from '@/components/ui/button';
import {Input} from '@/components/ui/input';
import {money} from '@/lib/payroll';
import {monthLabel} from '@/lib/choices';

type Preview={token:string;amount:number;months:string[]};
type Props={loan:{id:string};month:string;name:string;busy:boolean;onClose:()=>void;mutate:(body:Record<string,unknown>)=>Promise<Preview|null>};
export default function LoanSettlementDialog({loan,month,name,busy,onClose,mutate}:Props){
 const [paymentDate,setPaymentDate]=useState('');
 const [reference,setReference]=useState('');
 const [preview,setPreview]=useState<Preview|null>(null);
 const body={loan:loan.id,month,paymentDate,reference};
 return <Dialog open onOpenChange={open=>{if(!open&&!busy)onClose();}}><DialogContent><DialogHeader><DialogTitle>Quitação antecipada SEREFI</DialogTitle><DialogDescription>{name} · {monthLabel(month)}. Registre o pagamento realizado fora da folha.</DialogDescription></DialogHeader>
  <label>Data do pagamento<Input type="date" value={paymentDate} min={month+'-01'} disabled={busy} onChange={e=>{setPaymentDate(e.target.value);setPreview(null);}}/></label>
  <label>Referência do pagamento (opcional)<Input value={reference} maxLength={200} disabled={busy} onChange={e=>{setReference(e.target.value);setPreview(null);}} placeholder="Comprovante ou observação"/></label>
  <p>As cobranças desta competência em diante serão retiradas da folha. O contrato e o cronograma original permanecerão no histórico.</p>
  {preview&&<div role="status"><strong>Valor pago fora da folha: {money(preview.amount/100)}</strong><p>{preview.months.length?`Folhas abertas a atualizar: ${preview.months.map(monthLabel).join(', ')}.`:'Nenhuma folha lançada precisa ser atualizada.'} Não será adicionada uma nova taxa.</p></div>}
  <div className="table-actions"><Button variant="outline" disabled={busy} onClick={onClose}>Cancelar</Button><Button variant="outline" disabled={busy||paymentDate.slice(0,7)!==month} onClick={async()=>{const result=await mutate({...body,action:'loan_settlement_preview'});if(result)setPreview(result);}}>Conferir quitação</Button><Button disabled={busy||!preview} onClick={async()=>{if(await mutate({...body,action:'loan_settlement',token:preview?.token}))onClose();}}>Confirmar pagamento e quitar</Button></div>
 </DialogContent></Dialog>;
}
