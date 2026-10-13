import {automaticCostKeys} from './provisions';

// Presence is distinct from amount: zero is a valid calculated result.
const resultKeys=['salaryCompetencia','M',...automaticCostKeys];
export function hasAutomaticResults(values:Record<string,unknown>):boolean {
 return resultKeys.every(key=>Object.hasOwn(values,key)&&values[key]!==null&&values[key]!==''&&values[key]!==undefined&&Number.isFinite(Number(values[key])));
}
export function pendingAutomaticCount(rows:Array<{values:Record<string,unknown>}>):number {
 return rows.filter(row=>row.values._excluded!==true&&!hasAutomaticResults(row.values)).length;
}
