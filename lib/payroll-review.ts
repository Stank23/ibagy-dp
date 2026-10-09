import {exportRows,money,payrollKeys,hourKeys} from './payroll';
const extras=[{key:'CO',label:'Unimed total'},{key:'CP',label:'Uniodonto total'},{key:'commissionNet',label:'Líquido da comissão'},{key:'commissionIR',label:'IRRF da comissão'},{key:'AJ',label:'Empréstimo Governo'},{key:'AQ',label:'Desconto Ticket (1483)'},{key:'pensionJudicial',label:'Pensão Judicial'},{key:'faltas1027',label:'Falta (1027) · dias'},{key:'gratificacaoHorasNormais',label:'Gratificação Horas Normais · HH:MM'}];
export function payrollReviewData(month:string,rows:any[]){
 const ordered=[...rows].sort((a,b)=>String(a.values.C||'').localeCompare(String(b.values.C||''),'pt-BR'));
 const sheet=(exportRows('payroll',month,ordered) as unknown as Record<string,any[][]>)['Lançamentos'],labels=sheet[1],codes=sheet[2],indices=labels.map((_:any,i:number)=>i).filter((i:number)=>i!==3);
 const headers=[...indices.map((i:number)=>String(labels[i])+(codes[i]?` (${codes[i]})`:'')),...extras.map(c=>c.label)];
 const values=ordered.map((r,index)=>[...indices.map((i:number)=>{const value=sheet[index+4][i],key=payrollKeys[i-4];return i<3?String(value??''):hourKeys.has(key)?r.values[key]||'00:00':value===''||value==null?'—':money(value);}),...extras.map(c=>hourKeys.has(c.key)?r.values[c.key]||'00:00':c.key==='faltas1027'?String(r.values[c.key]||'0'):r.values[c.key]==null||r.values[c.key]===''?'—':money(r.values[c.key]))]);
 return {ordered,headers,values};
}
