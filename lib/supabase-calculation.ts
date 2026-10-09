import {calculate} from './finance-service';
import {validMonth} from './rules';
import {normalize} from './payroll';
import {commissionFinancialKeys} from './commission';
import {applyProvisions} from './provisions';
import {preserveCommission} from './period-locks';

type Row = Record<string, any>;
export class CalculationConflict extends Error {}
export class CalculationInputError extends Error {}
export type CalculationSnapshot = {
  period: Row | null;
  employees: Row[];
  versions: Row[];
  records: Row[];
  allowances: Row[];
  minimum_wages: Row[];
  normative_wages: Row[];
  unimed_rates: Row[];
  uniodonto_fixed_rates: Row[];
  installments: Row[];
  event_plans: Row[];
  childcare_children: Row[];
};

/** Same inputs as calculationContext, from one PostgreSQL statement snapshot. */
export function snapshotContext(snapshot: CalculationSnapshot) {
  const latest = (rows: Row[]) => [...rows].sort((a,b)=>b.month.localeCompare(a.month))[0];
  const group = (rows: Row[]) => {
    const result = new Map<string, Row[]>();
    for (const row of rows) result.set(row.employee, [...(result.get(row.employee)||[]), row]);
    return result;
  };
  const loans = new Map<string, number>();
  for (const row of snapshot.installments) loans.set(row.employee,(loans.get(row.employee)||0)+Number(row.amount));
  const totals = new Map<string, Row>();
  for (const row of snapshot.event_plans) {
    const key = JSON.stringify([row.employee,row.event]);
    const previous = totals.get(key);
    totals.set(key,{employee:row.employee,event:row.event,total:(previous?.total||0)+Number(row.amount)});
  }
  return {
    food:latest(snapshot.allowances), minimum:snapshot.minimum_wages,
    normative:latest(snapshot.normative_wages),
    rate:{unimed:latest(snapshot.unimed_rates),uniodonto:latest(snapshot.uniodonto_fixed_rates)},
    employees:new Map(snapshot.employees.map(e=>[e.id,e.active])), loans,
    events:group([...totals.values()]),children:group(snapshot.childcare_children),
  };
}

/** No arithmetic is reimplemented: the complete original v77 calculate() is used. */
export async function calculatedRecords(snapshot: CalculationSnapshot, month: string, action: 'period'|'recalculate') {
  if (!validMonth(month)) throw Error('Competência inválida.');
  if (action==='period' && snapshot.period) throw new CalculationConflict('Esta competência já existe. Selecione-a no histórico.');
  if (action==='recalculate' && snapshot.period?.status!=='open') throw new CalculationConflict('Abra ou reabra a competência para atualizar os valores.');
  const context = snapshotContext(snapshot);
  const source = action==='recalculate' ? snapshot.records : snapshot.employees.filter(e=>e.active===1).flatMap(e=>{
    const version = snapshot.versions.filter(v=>v.employee===e.id&&v.month<=month).sort((a,b)=>b.month.localeCompare(a.month))[0];
    if (!version || String(JSON.parse(version.data).D||'').slice(0,7)>month) return [];
    return [{employee:e.id,data:version.data,revision:0}];
  });
  return Promise.all(source.map(async row=>({employee:row.employee,revision:row.revision,data:JSON.stringify(await calculate(null,JSON.parse(row.data),row.employee,month,context))})));
}

/** Record-edit rules copied from the v77 finance route, including locked commission. */
export async function editedRecord(snapshot:CalculationSnapshot,month:string,employee:string,input:unknown,revision:number) {
  if (!validMonth(month)||!employee||!Number.isSafeInteger(revision)||revision<1) throw new CalculationInputError('Lançamento ou revisão inválidos.');
  if (snapshot.period?.status!=='open') throw new CalculationConflict('Reabra a competência antes de editar os lançamentos.');
  const previous=snapshot.records.find(r=>r.employee===employee);
  if (!previous||previous.revision!==revision) throw new CalculationConflict('Registro alterado. Atualize antes de salvar.');
  const old=JSON.parse(previous.data);
  if (old._excluded===true) throw new CalculationConflict('Reinclua o colaborador na folha antes de editar os lançamentos.');
  let d;
  try { d=normalize(input); } catch(e) { throw new CalculationInputError(e instanceof Error?e.message:'Dados inválidos.'); }
  if (d.B!==old.B) throw new CalculationInputError('A matrícula não pode ser alterada no lançamento.');
  for (const key of ['P','commissionType','supportGroup','gender','receivesChildcare','lastWorkedDay','healthMembers','healthCopart','healthMonthlyAdditions','_active']) d[key]=old[key];
  d._serefiAuto=old._serefiAuto||0;
  for (const key of ['CK','AM']) {
    d['_eventAuto'+key]=old['_eventAuto'+key]||0;
    if (Number(d[key]||0)*100<d['_eventAuto'+key]) throw new CalculationInputError('O valor não pode ser menor que as parcelas automáticas desta competência.');
  }
  d.receivesVA=old.receivesVA!==false; d.chargeSerefi=old.chargeSerefi!==false;
  d=await calculate(null,d,employee,month,snapshotContext(snapshot));
  const values=input as Record<string,unknown>;
  d.paid20=Boolean(values.paid20); d.paymentDate=String(values.paymentDate||''); d.paymentStatus=values.paymentStatus==='paid'?'paid':'pending';
  for (const key of commissionFinancialKeys) if (Object.hasOwn(old,key)) d[key]=old[key];
  d=applyProvisions(preserveCommission(d,old,snapshot.period));
  return [{employee,revision,data:JSON.stringify(d)}];
}
