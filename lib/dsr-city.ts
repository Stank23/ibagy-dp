import {commissionDays} from './commission';
export const dsrCities=[{id:'florianopolis',name:'Florianópolis',agencies:'Demais agências'},{id:'biguacu',name:'Biguaçu',agencies:'Agência Biguaçu'},{id:'palhoca',name:'Palhoça',agencies:'Agência Palhoça'},{id:'sao-jose',name:'São José',agencies:'Agência Kobrasol'}];
export function dsrCity(agency:unknown){const name=String(agency??'').normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9]/g,'').replace(/^agencia/,'');return name==='biguacu'?'biguacu':name==='kobrasol'?'sao-jose':name==='palhoca'?'palhoca':'florianopolis';}
export function dsrCalendar(configured:any[],month:string,agency:unknown){const city=dsrCity(agency);return configured.find(r=>r.month===month&&r.city===city)||configured.find(r=>r.month===month&&r.city==='florianopolis')||configured.find(r=>r.month===month&&(!r.city||r.city==='all'))||commissionDays(month);}

export function dsrAffectedCity(configured:any[],month:string,selected:string|undefined,agency:unknown){const target=dsrCity(agency);return !selected||target===selected||selected==='florianopolis'&&!configured.some(r=>r.month===month&&r.city===target);}
