create or replace function public.save_finance_salary(p_month text,p_actor text,p_token text,p_action text,p_apply_open boolean,p_versions jsonb,p_records jsonb)
returns boolean language plpgsql security invoker set search_path='' as $$
declare item jsonb;expected jsonb;provided jsonb;
begin
 if p_actor is null or length(p_actor) not between 1 and 200 or p_token is null or p_token !~ '^[a-f0-9]{32}$' or p_action is null or p_action not in('salary_adjust','salary_rows_apply') or p_apply_open is null or p_versions is null or jsonb_typeof(p_versions)<>'array' or jsonb_array_length(p_versions)>1000 or p_records is null or jsonb_typeof(p_records)<>'array' then raise exception 'Invalid salary request';end if;
 lock table public.allowances,public.childcare_children,public.employees,public.event_plans,public.installments,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions in share row exclusive mode;
 if public.finance_calculation_snapshot(p_month)->>'token' is distinct from p_token then return false;end if;
 if p_apply_open and ((p_action='salary_rows_apply' and not exists(select 1 from public.periods where month=p_month and status='open')) or exists(select 1 from public.periods where month=p_month and status='closed')) then return false;end if;
 if (select count(distinct value->>'employee') from jsonb_array_elements(p_versions))<>jsonb_array_length(p_versions) then raise exception 'Duplicate employees';end if;
 for item in select value from jsonb_array_elements(p_versions) loop
  if not exists(select 1 from public.versions where employee=item->>'employee' and month<=p_month) or jsonb_typeof((item->>'data')::jsonb) is distinct from 'object' or coalesce(((item->>'data')::jsonb->>'K')::numeric,0)<=0 then return false;end if;
 end loop;
 if p_action='salary_adjust' then
  select coalesce(jsonb_agg(id order by id),'[]') into expected from public.employees e where active=1 and exists(select 1 from public.versions where employee=e.id and month<=p_month);
  select coalesce(jsonb_agg(value->>'employee' order by value->>'employee'),'[]') into provided from jsonb_array_elements(p_versions);
  if expected<>provided then return false;end if;
 end if;
 select coalesce(jsonb_agg(employee order by employee),'[]') into expected from public.records where month=p_month and p_apply_open and exists(select 1 from public.periods where month=p_month and status='open') and employee in(select value->>'employee' from jsonb_array_elements(p_versions));
 select coalesce(jsonb_agg(value->>'employee' order by value->>'employee'),'[]') into provided from jsonb_array_elements(p_records);
 if expected<>provided then return false;end if;
 for item in select value from jsonb_array_elements(p_records) loop
  if jsonb_typeof((item->>'data')::jsonb) is distinct from 'object' or not exists(select 1 from public.records where month=p_month and employee=item->>'employee' and revision=(item->>'revision')::integer) then return false;end if;
 end loop;
 for item in select value from jsonb_array_elements(p_versions) loop
  insert into public.versions(employee,month,data) values(item->>'employee',p_month,item->>'data') on conflict(employee,month) do update set data=excluded.data;
 end loop;
 for item in select value from jsonb_array_elements(p_records) loop
  update public.records set data=item->>'data',revision=revision+1 where month=p_month and employee=item->>'employee';
 end loop;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,p_action,p_actor,now()::text,jsonb_build_object('applyOpen',p_apply_open,'employees',(select jsonb_agg(value->>'employee') from jsonb_array_elements(p_versions)))::text);
 return true;
end $$;
revoke all on function public.save_finance_salary(text,text,text,text,boolean,jsonb,jsonb) from public,anon,authenticated;
grant execute on function public.save_finance_salary(text,text,text,text,boolean,jsonb,jsonb) to service_role;
