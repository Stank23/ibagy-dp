create or replace function public.finance_record_action_snapshot(p_month text)
returns jsonb language sql stable security invoker set search_path='' as $$
 with s as (select (public.finance_calculation_snapshot(p_month)->'snapshot')||jsonb_build_object('dsr_settings',coalesce((select jsonb_agg(to_jsonb(d) order by month) from public.dsr_settings d where month=p_month),'[]'::jsonb)) as state)
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
 lock table public.allowances,public.childcare_children,public.employees,public.event_plans,public.installments,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions,public.dsr_settings in share row exclusive mode;
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
