import {healthMonthlyShare} from './benefits';

type Column={label:string;read:(row:any)=>any;marker:string};
const plans=[{name:'Unimed',plan:'unimed',offset:3,keys:['AT','AU','AV'],deps:[['AX','AY','AZ'],['BB','BC','BD'],['BF','BG','BH'],['BJ','BK','BL']]},{name:'Uniodonto',plan:'uniodonto',offset:18,keys:['BO','BP','BQ'],deps:[['BS','BT','BU'],['BW','BX','BY'],['CA','CB','CC'],['CE','CF','CG']]}];
const number=(v:any)=>v===''||v==null?'':Number(v);
function dependents(row:any,plan:typeof plans[number]){
 if(Array.isArray(row.healthMembers))return row.healthMembers.filter((m:any)=>m.plan===plan.plan&&m.role==='dependente').map((m:any)=>[m.name,healthMonthlyShare(m,row._healthEmployerShare===true).net,row.healthCopart?.[m.id]??'0.00']);
 const values=plan.deps.map(([name,monthly,copart])=>[row[name]||'',row[monthly],row[copart]]);
 let last=values.length;while(last&&!values[last-1].some(v=>v!==undefined&&v!==''&&v!==null&&v!=='0.00'&&v!==0))last--;
 return values.slice(0,last);
}
export function healthExportRows(month:string,rows:any[],labels:string[]){
 const legacyMarkers=['consideradas layout','','em branco',...Array(17).fill(''),'em branco'];
 const columns:Column[]=[{label:labels[0],read:()=>217,marker:legacyMarkers[0]},{label:labels[1],read:r=>r.B||'',marker:''},{label:labels[2],read:r=>r.C||'',marker:'em branco'}];
 for(const plan of plans){
  plan.keys.forEach((key,i)=>columns.push({label:labels[plan.offset+i],read:r=>number(r[key]),marker:legacyMarkers[plan.offset+i]||''}));
  const count=Math.max(0,...rows.map(r=>dependents(r,plan).length));
  for(let i=0;i<count;i++)for(let j=0;j<3;j++){
   const label=i<4?labels[plan.offset+3+i*3+j]:`${plan.name} ${['Dependente','Mensal','Serviço'][j]} ${i+1}`;
   columns.push({label,read:r=>{const d=dependents(r,plan)[i];return j===0?d?.[j]||'':number(d?.[j]);},marker:i<4?legacyMarkers[plan.offset+3+i*3+j]||'':''});
  }
 }
 columns.push({label:labels[33],read:r=>r.CN||'',marker:''});
 return {Plan3:[],folha:[['IBAGY IMOVEIS LTDA'],[`Planilha Folha de Pagamento ${month.slice(5)}/${month.slice(0,4)} – Ibagy Imoveis LTDA - Layout Importação`],columns.map(c=>c.marker),columns.map(c=>c.label),...rows.map(r=>columns.map(c=>c.read(r)))]};
}
