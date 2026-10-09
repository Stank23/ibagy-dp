export const hasAmount=(d:any,key:string)=>d[key]!==undefined&&d[key]!==null&&String(d[key]).trim()!=='';
const n=(d:any,key:string)=>Math.round(Number(d[key]||0)*100);
export function reportValues(d:any){
 const provisionKeys=['CZ','DA','DB','DC','DD'];
 const provisions=hasAmount(d,'DE')?n(d,'DE'):provisionKeys.reduce((s,k)=>s+n(d,k),0);
 const provisionsComplete=hasAmount(d,'DE')||provisionKeys.every(k=>hasAmount(d,k));
 const salary=hasAmount(d,'salaryCompetencia')?n(d,'salaryCompetencia'):n(d,'K');
 const salaryTotal=hasAmount(d,'O')?n(d,'O'):salary+n(d,'M')+n(d,'N');
 const compensation=hasAmount(d,'CS')?n(d,'CS'):salaryTotal+['U','V','T','Z','AA','AG'].reduce((s,k)=>s+n(d,k),0);
 const charges=hasAmount(d,'CT')?n(d,'CT'):n(d,'CQ')+n(d,'CR');
 const benefits=hasAmount(d,'CY')?n(d,'CY'):['CV','CW','CX'].reduce((s,k)=>s+n(d,k),0);
 const cost=hasAmount(d,'DF')?n(d,'DF'):compensation+charges+benefits+n(d,'AP')+provisions;
 const complete=hasAmount(d,'DF')||provisionsComplete&&(hasAmount(d,'CT')||hasAmount(d,'CQ')&&hasAmount(d,'CR'))&&(hasAmount(d,'CY')||['CV','CW','CX'].every(k=>hasAmount(d,k)));
 return {salary,commission:n(d,'U'),provisions,provisionsComplete,cost,complete,charges,benefits,net:n(d,'R'),netKnown:hasAmount(d,'R'),salaryPaid:d.paymentStatus==='paid',commissionPaid:!!d.paid20};
}
export function groupedReports(records:any[],key:string){
 const map=new Map<string,any>();
 for(const r of records){const d=r.values,v=reportValues(d),name=d[key]||'Não informado';const row=map.get(name)||{name,count:0,salary:0,commission:0,provisions:0,cost:0,paidSalary:0,paidCommission:0,missingCost:0,missingNet:0};
 row.count++;row.salary+=v.salary;row.commission+=v.commission;row.provisions+=v.provisions;row.cost+=v.cost;row.paidSalary+=v.salaryPaid?v.net:0;row.paidCommission+=v.commissionPaid?v.commission:0;row.missingCost+=v.complete?0:1;row.missingNet+=v.netKnown?0:1;map.set(name,row);}
 return [...map.values()].sort((a,b)=>a.name.localeCompare(b.name,'pt-BR'));
}

export function supportGroupReports(records:any[]){const rows=groupedReports(records.map(r=>({...r,values:{...r.values,_supportGroupLabel:r.values.supportGroup===true?'Grupo':'Não Grupo'}})),'_supportGroupLabel');return ['Grupo','Não Grupo'].map(name=>rows.find(r=>r.name===name)||{name,count:0,salary:0,commission:0,provisions:0,cost:0,paidSalary:0,paidCommission:0,missingCost:0,missingNet:0});}
