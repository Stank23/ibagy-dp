'use client';
import {useEffect,useRef} from 'react';
import {scrollPayrollTable} from '@/lib/payroll-table-keyboard';
import {Table,TableHeader,TableBody,TableRow,TableHead,TableCell} from '@/components/ui/table';
import {Button} from '@/components/ui/button';
import {History} from 'lucide-react';
import {money} from '@/lib/payroll';
import {payrollReviewData} from '@/lib/payroll-review';
import {downloadPayrollReviewPDF} from '@/lib/payroll-review-pdf';
export default function PayrollReview({month,rows,loading,edit,history}:any){
 const tableRegion=useRef<HTMLDivElement>(null);
 useEffect(()=>{const onKeyDown=(event:KeyboardEvent)=>scrollPayrollTable(event,tableRegion.current?.querySelector<HTMLElement>('[data-slot="table-container"]')??null);window.addEventListener('keydown',onKeyDown);return()=>window.removeEventListener('keydown',onKeyDown);},[]);
 const {ordered,headers,values}=payrollReviewData(month,rows);
 const style=(i:number)=>({backgroundColor:i%2===1?'#fce7ef':'transparent',border:'1px solid #d0d7de'});
 return <><div className="launch-tools mb-4"><Button variant="outline" disabled={loading||!rows.length} onClick={()=>downloadPayrollReviewPDF(month,rows)}>Exportar conferência em PDF</Button></div><div ref={tableRegion} role="region" aria-label="Tabela de conferência da folha; use as setas esquerda e direita para rolar" tabIndex={0}><Table className="payroll-review-table"><TableHeader><TableRow>{headers.map((label,i)=><TableHead key={i} style={style(i)}>{label}</TableHead>)}<TableHead style={style(headers.length)}>Ações</TableHead></TableRow></TableHeader><TableBody>{loading?<TableRow><TableCell colSpan={headers.length+1}>Carregando dados…</TableCell></TableRow>:ordered.map((r:any,index:number)=><TableRow key={r.employee}>{values[index].map((value,i)=><TableCell key={i} style={style(i)}>{value}</TableCell>)}<TableCell style={style(headers.length)}><div className="table-actions"><Button variant="ghost" size="sm" onClick={()=>history(r)} aria-label={'Histórico de '+r.values.C}><History size={16}/></Button><Button variant="outline" size="sm" onClick={()=>edit(r)}>Abrir</Button></div></TableCell></TableRow>)}</TableBody></Table></div></>;
}
export function CommissionReview({values}:any){return <div className="field-grid">{[{key:'U',label:'Comissão (90)'},{key:'T',label:'DSR (91)'},{key:'commissionNet',label:'Líquido para depósito'},{key:'commissionIR',label:'IRRF da comissão'}].map(c=><label key={c.key}>{c.label}<input className="benefit-select" value={values[c.key]==null||values[c.key]===''?'—':money(values[c.key])} readOnly/></label>)}</div>;}
