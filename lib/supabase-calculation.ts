import {calculate} from './finance-service';
import {validMonth} from './rules';

type Row = Record<string, any>;
export class CalculationConflict extends Error {}
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
