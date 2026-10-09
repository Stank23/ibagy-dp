import * as XLSX from 'xlsx';
import {exportRows} from './payroll';
import {styleExport} from './export-format';
export function payrollExport(kind:string,month:string,records:any[]){
 if(!['commission','health','payroll'].includes(kind))throw Error('Tipo de exportação inválido.');
 const sheets=exportRows(kind,month,records),wb=XLSX.utils.book_new();
 for(const [name,values] of Object.entries(sheets)){
  const sheet=XLSX.utils.aoa_to_sheet(values as any[],{cellDates:false});
  sheet['!cols']=Array.from({length:34},(_,i)=>({wch:i===2?38:22}));
  if(kind==='payroll'&&name==='Principal'&&sheet.H7)sheet.H7.z='mm/yyyy';
  XLSX.utils.book_append_sheet(wb,sheet,name);
 }
 const ext=kind==='commission'?'xlsx':'xls';
 return {ext,contentType:ext==='xls'?'application/vnd.ms-excel':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',bytes:styleExport(XLSX.write(wb,{type:'array',bookType:ext==='xls'?'biff8':'xlsx'}),ext)};
}
