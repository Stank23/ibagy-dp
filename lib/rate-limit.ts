import {RequestError} from './request-security';
export const clientAddress=(request:Request)=>request.headers.get('cf-connecting-ip')||'unknown';
export async function consumeRateLimit(db:any,namespace:string,subject:string,max:number,windowMs:number,now=Date.now()){
 const hash=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(namespace+'|'+subject)),key='rate:'+Array.from(new Uint8Array(hash),b=>b.toString(16).padStart(2,'0')).join(''),cutoff=now-windowMs;
 // The conditional UPSERT reserves one attempt atomically, including concurrent requests.
 const result=await db.prepare('INSERT INTO app_login_attempts(key,failures,since) VALUES(?,1,?) ON CONFLICT(key) DO UPDATE SET failures=CASE WHEN app_login_attempts.since<=? THEN 1 ELSE app_login_attempts.failures+1 END,since=CASE WHEN app_login_attempts.since<=? THEN excluded.since ELSE app_login_attempts.since END WHERE app_login_attempts.since<=? OR app_login_attempts.failures<?').bind(key,now,cutoff,cutoff,cutoff,max).run();
 if(!result.meta.changes)throw new RequestError('Limite de requisições atingido. Aguarde antes de tentar novamente.',429,Math.ceil(windowMs/1000));
}
