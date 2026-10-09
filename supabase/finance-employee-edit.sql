create or replace function public.finance_employee_edit_snapshot(p_month text,p_employee text)
returns jsonb language sql stable security invoker set search_path='' as $$
 with s as (select (public.finance_calculation_snapshot(p_month)->'snapshot')||jsonb_build_object(
 'affected_records',coalesce((select jsonb_agg(to_jsonb(r) order by r.month) from public.records r join public.periods p on p.month=r.month where r.employee=p_employee and r.month>=p_month and p.status='open'),'[]'::jsonb),
 'future_versions',coalesce((select jsonb_agg(to_jsonb(v) order by month) from public.versions v where employee=p_employee and month>p_month),'[]'::jsonb),
 'future_normative_wages',coalesce((select jsonb_agg(to_jsonb(n) order by month) from public.normative_wages n where month>p_month),'[]'::jsonb)) as state)
 select jsonb_build_object('snapshot',state,'token',md5(state::text)) from s;
$$;
revoke all on function public.finance_employee_edit_snapshot(text,text) from public,anon,authenticated;
grant execute on function public.finance_employee_edit_snapshot(text,text) to service_role;
create or replace function public.save_finance_employee_edit(p_month text,p_employee text,p_actor text,p_token text,p_data jsonb,p_active integer,p_records jsonb)
returns boolean language plpgsql security invoker set search_path='' as $$
declare state jsonb;item jsonb;expected jsonb; supplied jsonb;
begin
 if p_actor is null or length(p_actor) not between 1 and 200 or p_active is null or p_active not in(0,1) or p_token is null or p_token !~ '^[a-f0-9]{32}$' or p_data is null or jsonb_typeof(p_data)<>'object' or p_records is null or jsonb_typeof(p_records)<>'array' then raise exception 'Invalid employee edit';end if;
 lock table public.allowances,public.childcare_children,public.employees,public.event_plans,public.installments,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions in share row exclusive mode;
 state:=public.finance_employee_edit_snapshot(p_month,p_employee);
 if state->>'token' is distinct from p_token or not exists(select 1 from public.employees where id=p_employee and registration=p_data->>'B') then return false;end if;
 if coalesce(p_data->>'C','')='' or coalesce(p_data->>'H','')='' or p_data->>'D' !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' or length(regexp_replace(coalesce(p_data->>'E',''),'[^0-9]','','g'))<>11 then raise exception 'Invalid employee data';end if;
 if p_data->>'receivesVA' is distinct from 'false' and not exists(select 1 from public.allowances where month<=p_month) then raise exception 'VA not configured';end if;
 select coalesce(jsonb_agg(month order by month),'[]'::jsonb) into expected from public.records r where employee=p_employee and month>=p_month and exists(select 1 from public.periods p where p.month=r.month and status='open');
 select coalesce(jsonb_agg(value->>'month' order by value->>'month'),'[]'::jsonb) into supplied from jsonb_array_elements(p_records);
 if expected is distinct from supplied then return false;end if;
 for item in select value from jsonb_array_elements(p_records) loop
  if item->>'employee' is distinct from p_employee or not exists(select 1 from public.records where employee=p_employee and month=item->>'month' and revision=(item->>'revision')::integer) or jsonb_typeof((item->>'data')::jsonb)<>'object' then return false;end if;
 end loop;
 update public.employees set active=p_active where id=p_employee;
 insert into public.versions(employee,month,data) values(p_employee,p_month,p_data::text) on conflict(employee,month) do update set data=excluded.data;
 for item in select value from jsonb_array_elements(p_records) loop
  update public.records set data=item->>'data',revision=revision+1 where employee=p_employee and month=item->>'month';
 end loop;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Cadastro atualizado',p_actor,now()::text,jsonb_build_object('employee',p_employee,'effective',p_month,'updatedOpenRecords',jsonb_array_length(p_records))::text);
 return true;
end $$;
revoke all on function public.save_finance_employee_edit(text,text,text,text,jsonb,integer,jsonb) from public,anon,authenticated;
grant execute on function public.save_finance_employee_edit(text,text,text,text,jsonb,integer,jsonb) to service_role;
