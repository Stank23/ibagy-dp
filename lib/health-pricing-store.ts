export async function healthRates(db:any,month:string){const [unimed,uniodonto]=await db.batch([
 db.prepare('SELECT * FROM unimed_rates WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month),
 db.prepare('SELECT * FROM uniodonto_fixed_rates WHERE month<=? ORDER BY month DESC LIMIT 1').bind(month)]);return {unimed:unimed.results[0],uniodonto:uniodonto.results[0]};}
export async function saveHealthRates(db:any,body:any,actor:string){
 const unimed=body.action==='unimed_rates',table=unimed?'unimed_rates':'uniodonto_fixed_rates',keys=unimed?['young','middle','senior']:['amount'];
 const values=keys.map(k=>{const s=String(body[k]??'');if(!/^\d{1,8}(\.\d{1,2})?$/.test(s))throw Error(unimed?'Preencha os três valores da Unimed com até duas casas decimais.':'Informe a mensalidade da Uniodonto com até duas casas decimais.');return Math.round(Number(s)*100);});
 const revision=Number(body.revision??0);if(!Number.isSafeInteger(revision)||revision<0)throw Error('Revisão inválida.');
 const result=revision===0?await db.prepare(`INSERT INTO ${table}(month,${keys.join(',')},revision) VALUES(?,${keys.map(()=>'?').join(',')},1) ON CONFLICT(month) DO NOTHING`).bind(body.month,...values).run():await db.prepare(`UPDATE ${table} SET ${keys.map(k=>k+'=?').join(',')},revision=revision+1 WHERE month=? AND revision=?`).bind(...values,body.month,revision).run();
 if(!result.meta.changes)throw Error('Configuração alterada. Atualize antes de salvar.');
 await db.prepare('INSERT INTO audit(id,month,action,actor,created,detail) VALUES(?,?,?,?,?,?)').bind(crypto.randomUUID(),body.month,unimed?'Valores da Unimed configurados':'Mensalidade da Uniodonto configurada',actor,new Date().toISOString(),JSON.stringify(values)).run();return {ok:true};
}
