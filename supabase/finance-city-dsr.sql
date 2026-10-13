create table public.dsr_city_settings (
 month text not null check(month ~ '^20[0-9]{2}-(0[1-9]|1[0-2])$'),
 city text not null check(city in('florianopolis','biguacu','palhoca','sao-jose')),
 useful integer not null check(useful between 1 and 31),rest integer not null check(rest between 0 and 30),
 revision integer not null default 1 check(revision>0),write_id text not null,
 primary key(month,city)
);
alter table public.dsr_city_settings enable row level security;
revoke all on public.dsr_city_settings from anon,authenticated;
grant all on public.dsr_city_settings to service_role;
create or replace function public.finance_dsr_city(p_agency text)
returns text language sql immutable security invoker set search_path='' as $$
 select case regexp_replace(regexp_replace(translate(lower(coalesce(p_agency,'')),'áàãâéêíóôõúüç','aaaaeeiooouuc'),'[^a-z0-9]','','g'),'^agencia','') when 'biguacu' then 'biguacu' when 'kobrasol' then 'sao-jose' when 'palhoca' then 'palhoca' else 'florianopolis' end;
$$;
revoke all on function public.finance_dsr_city(text) from public,anon,authenticated;
grant execute on function public.finance_dsr_city(text) to service_role;
create or replace function public.finance_record_action_snapshot(p_month text)
returns jsonb language sql stable security invoker set search_path='' as $$
 with s as (select (public.finance_calculation_snapshot(p_month)->'snapshot')||jsonb_build_object('dsr_settings',coalesce((select jsonb_agg(state order by state->>'city') from (select to_jsonb(d)||jsonb_build_object('city','all') state from public.dsr_settings d where month=p_month union all select to_jsonb(d) from public.dsr_city_settings d where month=p_month) calendars),'[]'::jsonb)) as state)
 select jsonb_build_object('snapshot',state,'token',md5(state::text)) from s;
$$;
revoke all on function public.finance_record_action_snapshot(text) from public,anon,authenticated;
grant execute on function public.finance_record_action_snapshot(text) to service_role;
create or replace function public.save_finance_record_action(p_month text,p_action text,p_actor text,p_token text,p_records jsonb)
returns boolean language plpgsql security invoker set search_path='' as $$
declare s jsonb;item jsonb;current_token text;
begin
 if p_action is null or p_action not in('commission_value','health_sync','health_copart','health_copart_bulk','health_monthly_bulk') or p_records is null or jsonb_typeof(p_records)<>'array' or jsonb_array_length(p_records) not between 1 and 1000 then raise exception 'Invalid action';end if;
 if p_token is null or p_token !~ '^[a-f0-9]{32}$' then raise exception 'Invalid token';end if;
 lock table public.allowances,public.childcare_children,public.employees,public.event_plans,public.installments,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions,public.dsr_settings,public.dsr_city_settings in share row exclusive mode;
 s:=public.finance_record_action_snapshot(p_month);
 if s->>'token' is distinct from p_token or s->'snapshot'->'period'->>'status' is distinct from 'open' then return false;end if;
 if p_action='commission_value' and (s->'snapshot'->'period'->>'commission_status' is distinct from 'open' or jsonb_array_length(p_records)<>1) then return false;end if;
 if p_action in('health_sync','health_copart') and jsonb_array_length(p_records)<>1 then raise exception 'Invalid single record action';end if;
 if (select count(distinct value->>'employee') from jsonb_array_elements(p_records))<>jsonb_array_length(p_records) then raise exception 'Duplicate employees';end if;
 for item in select value from jsonb_array_elements(p_records) loop
  if not exists(select 1 from public.records where month=p_month and employee=item->>'employee' and revision=(item->>'revision')::integer and coalesce(data::jsonb->>'_excluded','false')<>'true') then return false;end if;
 end loop;
 for item in select value from jsonb_array_elements(p_records) loop
  current_token:=public.finance_calculation_snapshot(p_month)->>'token';
  if not public.save_calculated_finance_period(p_month,'record',p_actor,current_token,jsonb_build_array(item)) then raise exception 'Record changed';end if;
 end loop;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,p_action,p_actor,now()::text,jsonb_build_object('employees',(select jsonb_agg(value->>'employee') from jsonb_array_elements(p_records)))::text);
 return true;
end $$;
revoke all on function public.save_finance_record_action(text,text,text,text,jsonb) from public,anon,authenticated;
grant execute on function public.save_finance_record_action(text,text,text,text,jsonb) to service_role;
create or replace function public.save_finance_city_dsr(p_month text,p_city text,p_actor text,p_token text,p_useful integer,p_rest integer,p_revision integer,p_records jsonb)
returns boolean language plpgsql security invoker set search_path='' as $$
declare item jsonb;expected jsonb;provided jsonb;days integer;
begin
 if p_city is null or p_city not in('florianopolis','biguacu','palhoca','sao-jose') or p_month is null or p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_actor is null or length(p_actor) not between 1 and 200 or p_token is null or p_token !~ '^[a-f0-9]{32}$' or p_revision is null or p_revision<0 or p_records is null or jsonb_typeof(p_records)<>'array' then raise exception 'Invalid DSR request';end if;
 days:=extract(day from (to_date(p_month||'-01','YYYY-MM-DD')+interval '1 month'-interval '1 day'));
 if p_useful is null or p_rest is null or p_useful<1 or p_rest<0 or p_useful+p_rest<>days then raise exception 'Invalid days';end if;
 lock table public.allowances,public.childcare_children,public.employees,public.event_plans,public.installments,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions,public.dsr_settings,public.dsr_city_settings in share row exclusive mode;
 if public.finance_record_action_snapshot(p_month)->>'token' is distinct from p_token or exists(select 1 from public.periods where month=p_month and (status='closed' or commission_status='closed')) or coalesce((select revision from public.dsr_city_settings where month=p_month and city=p_city),0)<>p_revision then return false;end if;
 -- Match v77: validate net for all records; update only commission rows, including excluded rows.
 if exists(select 1 from public.records where month=p_month and public.finance_dsr_city(data::jsonb->>'H')=p_city and coalesce(data::jsonb->>'commissionNet','')<>'' and round((data::jsonb->>'commissionNet')::numeric*100)>round(coalesce(nullif(data::jsonb->>'U',''),'0')::numeric*100)+round(round(coalesce(nullif(data::jsonb->>'U',''),'0')::numeric*100)*p_rest/p_useful)) then return false;end if;
 select coalesce(jsonb_agg(employee order by employee),'[]') into expected from public.records where month=p_month and public.finance_dsr_city(data::jsonb->>'H')=p_city and (coalesce(data::jsonb->>'P','')<>'' or coalesce(data::jsonb->>'commissionType','')<>'' or coalesce(nullif(data::jsonb->>'U',''),'0')::numeric>0);
 select coalesce(jsonb_agg(value->>'employee' order by value->>'employee'),'[]') into provided from jsonb_array_elements(p_records);
 if expected<>provided then return false;end if;
 for item in select value from jsonb_array_elements(p_records) loop
  if jsonb_typeof((item->>'data')::jsonb) is distinct from 'object' then raise exception 'Invalid record';end if;
  if not exists(select 1 from public.records where month=p_month and public.finance_dsr_city(data::jsonb->>'H')=p_city and employee=item->>'employee' and revision=(item->>'revision')::integer) then return false;end if;
 end loop;
 insert into public.dsr_city_settings(month,city,useful,rest,revision,write_id) values(p_month,p_city,p_useful,p_rest,1,gen_random_uuid()::text) on conflict(month,city) do update set useful=excluded.useful,rest=excluded.rest,revision=dsr_city_settings.revision+1,write_id=excluded.write_id;
 for item in select value from jsonb_array_elements(p_records) loop
  update public.records set data=item->>'data',revision=revision+1 where month=p_month and employee=item->>'employee';
 end loop;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Calendário DSR configurado',p_actor,now()::text,jsonb_build_object('city',p_city,'useful',p_useful,'rest',p_rest)::text);
 return true;
end $$;
revoke all on function public.save_finance_city_dsr(text,text,text,text,integer,integer,integer,jsonb) from public,anon,authenticated;
grant execute on function public.save_finance_city_dsr(text,text,text,text,integer,integer,integer,jsonb) to service_role;
