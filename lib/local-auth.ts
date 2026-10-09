import {assertSameOrigin} from './request-security';
import {cookies} from 'next/headers';
import {database} from './store';
export const SESSION_COOKIE='__Host-ibagy_session';
export const hex=(value:ArrayBuffer|Uint8Array)=>Array.from(new Uint8Array(value instanceof ArrayBuffer?value:value.buffer,value instanceof ArrayBuffer?0:value.byteOffset,value instanceof ArrayBuffer?value.byteLength:value.byteLength),b=>b.toString(16).padStart(2,'0')).join('');
export async function digest(value:string){return hex(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(value)));}
export async function passwordHash(password:string,salt:string){const key=await crypto.subtle.importKey('raw',new TextEncoder().encode(password),'PBKDF2',false,['deriveBits']);return hex(await crypto.subtle.deriveBits({name:'PBKDF2',hash:'SHA-256',salt:new TextEncoder().encode(salt),iterations:100000},key,256));}
export function equal(a:string,b:string){let difference=a.length^b.length;for(let i=0;i<Math.max(a.length,b.length);i++)difference|=(a.charCodeAt(i)||0)^(b.charCodeAt(i)||0);return difference===0;}
export const checkOrigin=assertSameOrigin;
export async function localUser(){const token=(await cookies()).get(SESSION_COOKIE)?.value;if(!token||!/^[a-f0-9]{64}$/.test(token))return null;const user:any=await database().prepare('SELECT u.id,u.username,u.name,u.role FROM app_users u JOIN app_sessions s ON s.user_id=u.id WHERE s.token_hash=? AND s.expires>? AND u.active=1').bind(await digest(token),Date.now()).first();return user?{userId:user.id,email:user.username,displayName:user.name,fullName:user.name,role:user.role}:null;}

export function sessionCookie(token:string,maxAge=28800){return `${SESSION_COOKIE}=${token}; Path=/; HttpOnly; Secure; SameSite=None; Partitioned; Max-Age=${maxAge}`;}
export function requestSession(request:Request){return request.headers.get('cookie')?.split(';').map(v=>v.trim()).find(v=>v.startsWith(SESSION_COOKIE+'='))?.slice(SESSION_COOKIE.length+1);}
