-- Server-only RPCs. Arithmetic remains in the original v77 TypeScript engine.
create or replace function public.finance_calculation_snapshot(p_month text)
returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare s jsonb;
begin
 if p_month is null or p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' then raise exception 'Invalid month'; end if;
 select jsonb_build_object(
  'period',(select to_jsonb(p) from public.periods p where month=p_month),
  'employees',coalesce((select jsonb_agg(to_jsonb(e) order by id) from public.employees e),'[]'::jsonb),
  'versions',coalesce((select jsonb_agg(to_jsonb(v) order by employee,month) from public.versions v where month<=p_month),'[]'::jsonb),
  'records',coalesce((select jsonb_agg(to_jsonb(r) order by employee) from public.records r where month=p_month),'[]'::jsonb),
  'allowances',coalesce((select jsonb_agg(to_jsonb(a) order by month) from public.allowances a where month<=p_month),'[]'::jsonb),
  'minimum_wages',coalesce((select jsonb_agg(to_jsonb(a) order by month) from public.minimum_wages a where month<=p_month),'[]'::jsonb),
  'normative_wages',coalesce((select jsonb_agg(to_jsonb(a) order by month) from public.normative_wages a where month<=p_month),'[]'::jsonb),
  'unimed_rates',coalesce((select jsonb_agg(to_jsonb(a) order by month) from public.unimed_rates a where month<=p_month),'[]'::jsonb),
  'uniodonto_fixed_rates',coalesce((select jsonb_agg(to_jsonb(a) order by month) from public.uniodonto_fixed_rates a where month<=p_month),'[]'::jsonb),
  'installments',coalesce((select jsonb_agg(to_jsonb(i) order by loan,number) from public.installments i where month=p_month),'[]'::jsonb),
  'event_plans',coalesce((select jsonb_agg(to_jsonb(e) order by id) from public.event_plans e where start<=p_month and "end">=p_month),'[]'::jsonb),
  'childcare_children',coalesce((select jsonb_agg(to_jsonb(c) order by employee,id) from public.childcare_children c),'[]'::jsonb)
 ) into s;
 return jsonb_build_object('snapshot',s,'token',md5(s::text));
end $$;
revoke all on function public.finance_calculation_snapshot(text) from public,anon,authenticated;
grant execute on function public.finance_calculation_snapshot(text) to service_role;

create or replace function public.save_calculated_finance_period(p_month text,p_action text,p_actor text,p_token text,p_records jsonb)
returns boolean language plpgsql security invoker set search_path='' as $$
declare current_state jsonb; item jsonb; expected_count integer; expected_ids jsonb; supplied_ids jsonb;
begin
 if p_month is null or p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$'
    or p_action is null or p_action not in ('period','recalculate','record')
    or p_actor is null or length(p_actor) not between 1 and 200
    or p_token is null or p_token !~ '^[a-f0-9]{32}$'
    or p_records is null or jsonb_typeof(p_records)<>'array' then raise exception 'Invalid calculation request'; end if;
 -- Hold all calculation inputs stable through validation, writes and audit.
 -- Conflicts return false before any mutation; SQL failures roll back everything.
 lock table public.allowances,public.childcare_children,public.employees,public.event_plans,
   public.installments,public.minimum_wages,public.normative_wages,public.periods,
   public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.versions in share row exclusive mode;
 current_state:=public.finance_calculation_snapshot(p_month);
 if current_state->>'token' is distinct from p_token then return false; end if;
 if p_action='period' then
  if exists(select 1 from public.periods where month=p_month) then return false; end if;
  select coalesce(jsonb_agg(id order by id),'[]'::jsonb) into expected_ids from public.employees e
   where active=1 and exists(select 1 from public.versions v where v.employee=e.id
    and v.month=(select max(v2.month) from public.versions v2 where v2.employee=e.id and v2.month<=p_month)
    and left(v.data::jsonb->>'D',7)<=p_month);
 else
  if not exists(select 1 from public.periods where month=p_month and status='open') then return false; end if;
  if p_action='record' then
   if jsonb_array_length(p_records)<>1 then return false; end if;
   select coalesce(jsonb_agg(employee order by employee),'[]'::jsonb) into expected_ids from public.records
    where month=p_month and employee=p_records->0->>'employee' and coalesce(data::jsonb->>'_excluded','false')<>'true';
  else
   select coalesce(jsonb_agg(employee order by employee),'[]'::jsonb) into expected_ids from public.records where month=p_month;
  end if;
 end if;
 select coalesce(jsonb_agg(r->>'employee' order by r->>'employee'),'[]'::jsonb) into supplied_ids from jsonb_array_elements(p_records) r;
 if supplied_ids is distinct from expected_ids then return false; end if;
 for item in select value from jsonb_array_elements(p_records) loop
  if jsonb_typeof(item->'data') is distinct from 'string' or jsonb_typeof((item->>'data')::jsonb) is distinct from 'object'
    or coalesce(item->>'revision','') !~ '^[0-9]+$' then raise exception 'Invalid calculated record'; end if;
  if p_action='period' and (item->>'revision')::integer<>0 then return false; end if;
  if p_action<>'period' and not exists(select 1 from public.records where month=p_month and employee=item->>'employee' and revision=(item->>'revision')::integer) then return false; end if;
 end loop;
 if p_action='period' then
  insert into public.periods(month,status,commission_status) values(p_month,'open','open');
  insert into public.records(month,employee,data,revision) select p_month,r->>'employee',r->>'data',1 from jsonb_array_elements(p_records) r;
 else
  update public.records r set data=i.value->>'data',revision=r.revision+1
   from jsonb_array_elements(p_records) i where r.month=p_month and r.employee=i.value->>'employee';
 end if;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,
  case p_action when 'period' then 'Competência aberta' when 'record' then 'Lançamento atualizado' else 'Valores automáticos atualizados' end,
  p_actor,now()::text,(jsonb_build_object('employees',jsonb_array_length(p_records),'engine','v77')||
   case when p_action='record' then jsonb_build_object('employee',p_records->0->>'employee','revision',(p_records->0->>'revision')::integer+1) else '{}'::jsonb end)::text);
 return true;
end $$;
revoke all on function public.save_calculated_finance_period(text,text,text,text,jsonb) from public,anon,authenticated;
grant execute on function public.save_calculated_finance_period(text,text,text,text,jsonb) to service_role;
