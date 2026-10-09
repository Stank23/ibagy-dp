// Load shared monthly inputs once, including grouped employee values.
export async function calculationContext(db:any,month:string,employee?:string){
 const [food,minimum,normative,rate,fixed,employees,loans,events,children]=await db.batch([
 db.prepare('SELECT amount FROM allowances WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month),
 db.prepare('SELECT * FROM minimum_wages WHERE month<=? ORDER BY month DESC').bind(month),
 db.prepare('SELECT amount FROM normative_wages WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month),
 db.prepare('SELECT * FROM unimed_rates WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month),
 db.prepare('SELECT * FROM uniodonto_fixed_rates WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month),
 employee?db.prepare('SELECT id,active FROM employees WHERE id=?').bind(employee):db.prepare('SELECT id,active FROM employees'),
 employee?db.prepare('SELECT employee,SUM(amount) AS total FROM installments WHERE month=? AND employee=? GROUP BY employee').bind(month,employee):db.prepare('SELECT employee,SUM(amount) AS total FROM installments WHERE month=? GROUP BY employee').bind(month),
 employee?db.prepare('SELECT employee,event,SUM(amount) AS total FROM event_plans WHERE employee=? AND start<=? AND end>=? GROUP BY employee,event').bind(employee,month,month):db.prepare('SELECT employee,event,SUM(amount) AS total FROM event_plans WHERE start<=? AND end>=? GROUP BY employee,event').bind(month,month),
 employee?db.prepare('SELECT * FROM childcare_children WHERE employee=? ORDER BY employee,id').bind(employee):db.prepare('SELECT * FROM childcare_children ORDER BY employee,id')]);
 const group=(rows:any[])=>{const map=new Map<string,any[]>();for(const row of rows){const list=map.get(row.employee)||[];list.push(row);map.set(row.employee,list);}return map;};
 return {food:food.results[0],minimum:minimum.results,normative:normative.results[0],rate:{unimed:rate.results[0],uniodonto:fixed.results[0]},employees:new Map(employees.results.map((r:any)=>[r.id,r.active])),loans:new Map(loans.results.map((r:any)=>[r.employee,r.total])),events:group(events.results),children:group(children.results)};
}
