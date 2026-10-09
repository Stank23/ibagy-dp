'use client';
import {useState} from 'react';
import {Input} from '@/components/ui/input';
import {formatDuration,validDuration} from '@/lib/hours';
export function HourInput({value,onChange,...props}:any){const [editing,setEditing]=useState(false);const shown=editing?String(value??''):formatDuration(value);return <Input {...props} type="text" inputMode="text" placeholder="HH:MM" maxLength={9} value={shown} aria-invalid={Boolean(value)&&String(value).includes(':')&&!validDuration(String(value))} onFocus={()=>{setEditing(true);if(shown!==String(value??''))onChange(shown);}} onChange={e=>{if(/^[0-9:]*$/.test(e.target.value))onChange(e.target.value);}} onBlur={()=>{try{onChange(formatDuration(value));setEditing(false);}catch{}}}/>;}
