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
 if exists(select 1 from public.records where month=p_month and (public.finance_dsr_city(data::jsonb->>'H')=p_city or (p_city='florianopolis' and not exists(select 1 from public.dsr_city_settings c where c.month=p_month and c.city=public.finance_dsr_city(data::jsonb->>'H')))) and coalesce(data::jsonb->>'commissionNet','')<>'' and round((data::jsonb->>'commissionNet')::numeric*100)>round(coalesce(nullif(data::jsonb->>'U',''),'0')::numeric*100)+round(round(coalesce(nullif(data::jsonb->>'U',''),'0')::numeric*100)*p_rest/p_useful)) then return false;end if;
 select coalesce(jsonb_agg(employee order by employee),'[]') into expected from public.records where month=p_month and (public.finance_dsr_city(data::jsonb->>'H')=p_city or (p_city='florianopolis' and not exists(select 1 from public.dsr_city_settings c where c.month=p_month and c.city=public.finance_dsr_city(data::jsonb->>'H')))) and (coalesce(data::jsonb->>'P','')<>'' or coalesce(data::jsonb->>'commissionType','')<>'' or coalesce(nullif(data::jsonb->>'U',''),'0')::numeric>0);
 select coalesce(jsonb_agg(value->>'employee' order by value->>'employee'),'[]') into provided from jsonb_array_elements(p_records);
 if expected<>provided then return false;end if;
 for item in select value from jsonb_array_elements(p_records) loop
  if jsonb_typeof((item->>'data')::jsonb) is distinct from 'object' then raise exception 'Invalid record';end if;
  if not exists(select 1 from public.records where month=p_month and (public.finance_dsr_city(data::jsonb->>'H')=p_city or (p_city='florianopolis' and not exists(select 1 from public.dsr_city_settings c where c.month=p_month and c.city=public.finance_dsr_city(data::jsonb->>'H')))) and employee=item->>'employee' and revision=(item->>'revision')::integer) then return false;end if;
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
