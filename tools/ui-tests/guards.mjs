export const previewHost='ibagy-pkaqxo4jr-marcelostank3-1898.vercel.app';
export function targetURL(value){
 const u=new URL(value);
 if(u.protocol!=='https:'||u.hostname!==previewHost||u.username||u.password||u.port||u.search||u.hash)throw Error('Use somente o preview verificado, sem tokens na URL.');
 return u.origin;
}
export function allowWrite(url,method,body,mode){
 if(['GET','HEAD','OPTIONS'].includes(method))return true;
 const u=new URL(url);
 if(u.origin!==mode.origin)return false;
 if(u.pathname==='/api/auth')return ['login','logout'].includes(body?.action);
 return mode.enabled===true&&u.pathname==='/api/finance'&&method==='POST'&&body?.action==='record'&&body.month==='2099-12'&&body.employee===mode.employee&&Number.isSafeInteger(body.revision)&&body.revision>0;
}
export function verifyFixture(data,registration){
 if(!/^TEST-UI-[A-Z0-9-]+$/.test(registration))throw Error('A matrícula deve começar com TEST-UI-.');
 const period=data.periods?.find(p=>p.month==='2099-12');
 if(!period||period.status!=='open'||!data.canEdit)throw Error('Requer competência exclusiva 12/2099 aberta e conta com edição.');
 const records=data.records?.filter(r=>JSON.parse(r.data).B===registration)||[];
 if(records.length!==1)throw Error('Colaborador de teste ausente ou matrícula duplicada.');
 const r=records[0],v=JSON.parse(r.data);
 if(!/^TESTE UI\b/.test(v.C)||v._excluded===true||r.month!=='2099-12')throw Error('Use exclusivamente colaborador fictício com nome TESTE UI e registro ativo em 12/2099.');
 return r;
}
