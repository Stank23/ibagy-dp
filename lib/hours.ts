export const hourKeys=new Set(['AF','gratificacaoHorasNormais']);
export const validDuration=(v:string)=>/^\d{1,6}:[0-5]\d$/.test(v);
export function durationMinutes(v:any){const s=String(v??'').trim();if(!s)return 0;if(validDuration(s)){const [h,m]=s.split(':').map(Number);return h*60+m;}if(/^\d{1,10}(\.\d{1,2})?$/.test(s))return Math.round(Number(s)*60);throw Error('Informe as horas no formato HH:MM, com minutos de 00 a 59.');}
export function formatDuration(v:any){if(v==null||v==='')return '';const minutes=durationMinutes(v);return `${String(Math.floor(minutes/60)).padStart(2,'0')}:${String(minutes%60).padStart(2,'0')}`;}
