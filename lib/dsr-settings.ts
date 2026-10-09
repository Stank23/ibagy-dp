import {commissionDays,commissionAmounts} from './commission';
const gross=(useful:number,rest:number)=>`(ROUND(COALESCE(json_extract(data,'$.U'),0)*100)+ROUND(ROUND(COALESCE(json_extract(data,'$.U'),0)*100)*${rest}.0/${useful}))`;
export async function saveDSRSettings(db:any,body:any,actor:string){
 const {month}=body,days=commissionDays(month);
 const amounts=commissionAmounts('0','',body.useful,body.rest,days.total),useful=amounts.commissionUseful,rest=amounts.commissionRest;
 const revision=body.revision??0;if(!Number.isInteger(revision)||revision<0)throw Error('Calendário inválido. Atualize a página.');
 const guard="NOT EXISTS(SELECT 1 FROM periods WHERE month=? AND (status='closed' OR commission_status='closed'))";
 const invalid=`EXISTS(SELECT 1 FROM records WHERE month=? AND json_extract(data,'$.commissionNet') IS NOT NULL AND json_extract(data,'$.commissionNet')<>'' AND ROUND(json_extract(data,'$.commissionNet')*100)>${gross(useful,rest)})`;
 const saved="EXISTS(SELECT 1 FROM dsr_settings WHERE month=? AND revision=? AND useful=? AND rest=?)";
 const dsr=`ROUND(ROUND(COALESCE(json_extract(data,'$.U'),0)*100)*${rest}.0/${useful})`;
 const auditId=crypto.randomUUID();
 const results=await db.batch([
 db.prepare(`INSERT INTO dsr_settings(month,useful,rest,revision,write_id) SELECT ?,?,?,1,? WHERE ${guard} AND COALESCE((SELECT revision FROM dsr_settings WHERE month=?),0)=? AND NOT ${invalid} ON CONFLICT(month) DO UPDATE SET useful=excluded.useful,rest=excluded.rest,revision=dsr_settings.revision+1,write_id=excluded.write_id`).bind(month,useful,rest,auditId,month,month,revision,month),
 db.prepare(`INSERT INTO audit(id,month,action,actor,created,detail) SELECT ?,?,?,?,?,? WHERE ${saved} AND EXISTS(SELECT 1 FROM dsr_settings WHERE month=? AND write_id=?)`).bind(auditId,month,'Calendário DSR configurado',actor,new Date().toISOString(),JSON.stringify({useful,rest}),month,revision+1,useful,rest,month,auditId),
 db.prepare(`UPDATE records SET data=json_set(data,'$.T',printf('%.2f',${dsr}/100.0),'$.commissionUseful',?,'$.commissionRest',?,'$.commissionIR',CASE WHEN json_extract(data,'$.commissionNet') IS NULL OR json_extract(data,'$.commissionNet')='' THEN '' ELSE printf('%.2f',(${gross(useful,rest)}-ROUND(json_extract(data,'$.commissionNet')*100))/100.0) END),revision=revision+1 WHERE month=? AND (json_extract(data,'$.P')<>'' OR json_extract(data,'$.commissionType')<>'' OR COALESCE(json_extract(data,'$.U'),0)>0) AND EXISTS(SELECT 1 FROM audit WHERE id=?)`).bind(useful,rest,month,auditId)
 ]);
 if(!results[0].meta.changes)throw Error('Não foi possível salvar: calendário alterado, competência fechada ou líquido maior que o novo bruto. Atualize e confira os valores.');
 return {ok:true};
}
