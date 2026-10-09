import {money} from './payroll';
import {monthLabel} from './choices';
type Row={id:string;employee:string;amount:number;count:number;start:string;end:string};
export function loanSummary(loans:Row[],installments:any[],month:string){
 const active=loans.filter(l=>l.end>=month),finished=loans.filter(l=>l.end<month),ids=new Set(active.map(l=>l.id));
 return {active,finished,disbursed:active.filter(l=>l.start===month).reduce((s,l)=>s+Number(l.amount),0),received:installments.filter(i=>ids.has(i.loan)&&i.month===month).reduce((s,i)=>s+Number(i.amount),0)};
}
// PDF with the standard WinAnsi font; no external service or upload is required.
export function exportLoanPDF(rows:Row[],installments:any[],names:Map<any,any>,month:string,finished:boolean,summary:ReturnType<typeof loanSummary>){
 const currency=(v:number)=>money(v/100).replace(/\u00a0/g,' ');
 const literal=(s:string)=>s.replace(/[\\()]/g,'\\$&').replace(/[^\x20-\xff]/g,'?');
 const widths=[240,105,105,90,45,92,93],left=36,totalWidth=770,rowHeight=26,tableTop=503;
 const pages:Row[][]=[];for(let i=0;i<rows.length;i+=14)pages.push(rows.slice(i,i+14));if(!pages.length)pages.push([]);
 const objects:string[]=['', '', '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>'];const kids:string[]=[];
 pages.forEach((page,index)=>{
  const pageId=objects.length+1,contentId=pageId+1;kids.push(`${pageId} 0 R`);const commands:string[]=[];
  const text=(s:string,x:number,y:number,size=10,width?:number)=>{const safe=literal(s),scale=width?Math.min(100,Math.floor((width-12)/(s.length*size*0.65)*100)):100;commands.push(`BT /F1 ${size} Tf ${scale} Tz 1 0 0 1 ${x} ${y} Tm (${safe}) Tj ET`);};
  commands.push('0.65 0.07 0.12 rg');text('IBAGY · Empréstimos SEREFI',left,554,19);commands.push('0.2 0.2 0.2 rg');text(`Competência: ${monthLabel(month)} · ${finished?'Finalizados':'Em andamento'}`,left,532,11);
  const cells=(values:string[],y:number,header=false)=>{if(header)commands.push(`0.92 0.92 0.92 rg ${left} ${y-rowHeight} ${totalWidth} ${rowHeight} re f`);commands.push('0.2 0.2 0.2 rg');let x=left;values.forEach((v,i)=>{text(v,x+6,y-17,header?9:10,widths[i]);x+=widths[i];});};
  cells(['Colaborador','Valor pago','Parcela base','Parcela do mês','Qtd.','Início','Término'],tableTop,true);
  page.forEach((row,i)=>{const parts=installments.filter(p=>p.loan===row.id),regular=parts.find(p=>p.number===1)?.principal??Math.floor(row.amount/row.count),current=parts.find(p=>p.month===month)?.amount??0;cells([String(names.get(row.employee)||row.employee),currency(row.amount),currency(regular),currency(current),String(row.count),monthLabel(row.start),monthLabel(row.end)],tableTop-(i+1)*rowHeight);});
  const bottom=tableTop-(page.length+1)*rowHeight;commands.push('0.65 0.65 0.65 RG 0.5 w');let x=left;for(const width of [...widths,0]){commands.push(`${x} ${tableTop} m ${x} ${bottom} l S`);x+=width;}for(let i=0;i<=page.length+1;i++){const y=tableTop-i*rowHeight;commands.push(`${left} ${y} m ${left+totalWidth} ${y} l S`);}
  if(!page.length)text('Nenhum empréstimo nesta relação.',left+6,bottom-22,10);
  if(index===pages.length-1){const y=bottom-38;commands.push('0.2 0.2 0.2 rg');if(!finished){text(`Total desembolsado na competência: ${currency(summary.disbursed)}`,left,y,11);text(`Total de parcelas na competência (com taxa): ${currency(summary.received)}`,left,y-20,11);}else text('Registros históricos, excluídos dos totais da competência.',left,y,10);text('Recebimentos conforme o cronograma de cobrança. Taxa de R$ 2,80 apenas na primeira parcela.',left,y-42,9);}
  commands.push('0.35 0.35 0.35 rg');text(`Página ${index+1} de ${pages.length}`,left,28,9);
  const stream=commands.join('\n');objects.push(`<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Resources << /Font << /F1 3 0 R >> >> /Contents ${contentId} 0 R >>`,`<< /Length ${stream.length} >>\nstream\n${stream}\nendstream`);
 });
 objects[0]='<< /Type /Catalog /Pages 2 0 R >>';objects[1]=`<< /Type /Pages /Kids [${kids.join(' ')}] /Count ${pages.length} >>`;
 let pdf='%PDF-1.4\n',offsets=[0];objects.forEach((obj,i)=>{offsets.push(pdf.length);pdf+=`${i+1} 0 obj\n${obj}\nendobj\n`;});const xref=pdf.length;pdf+=`xref\n0 ${objects.length+1}\n0000000000 65535 f \n`+offsets.slice(1).map(v=>`${String(v).padStart(10,'0')} 00000 n \n`).join('')+`trailer\n<< /Size ${objects.length+1} /Root 1 0 R >>\nstartxref\n${xref}\n%%EOF`;
 const bytes=Uint8Array.from(pdf,c=>c.charCodeAt(0)),url=URL.createObjectURL(new Blob([bytes],{type:'application/pdf'}));const a=document.createElement('a');a.href=url;a.download=`serefi-${month}-${finished?'finalizados':'andamento'}.pdf`;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
}
