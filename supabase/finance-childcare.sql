-- Mirrors v77 childcareRefresh, bounded to the selected month to preserve earlier history.
create or replace function public.refresh_finance_childcare(p_month text,p_employee text default null)
returns integer language plpgsql security invoker set search_path='' as $$
declare r record;children jsonb;normative bigint;receives boolean;next jsonb;changed integer:=0;total_cents bigint;
begin
 for r in select rec.* from public.records rec join public.periods p on p.month=rec.month where rec.month>=p_month and p.status='open' and coalesce(rec.data::jsonb->>'_excluded','false')<>'true' and (p_employee is null or rec.employee=p_employee) order by rec.month,rec.employee loop
  select coalesce(jsonb_agg(jsonb_build_object('id',c.id,'name',c.child_name,'birthDate',c.birth_date,'lastCredit',c.last_credit) order by c.id),'[]') into children from public.childcare_children c where c.employee=r.employee and c.start<=r.month and left(c.birth_date,7)<=r.month and c.last_credit>=r.month;
  normative:=coalesce((select amount from public.normative_wages where month<=r.month order by month desc limit 1),0);
  receives:=coalesce(r.data::jsonb->>'gender','')='Feminino' and jsonb_array_length(children)>0;
  next:=r.data::jsonb||jsonb_build_object('AG',case when receives then to_char(round(normative*0.2)/100,'FM999999999990.00') else '0.00' end,'receivesChildcare',receives,'_normativeWage',normative,'_childcareChildren',children);
  -- v77 applyProvisions: DF = CS + AG + CT + CY + AP + DE, in cents.
  -- Refresh the only cost dependent on AG in this same write; GET stays read-only.
  select sum(round(coalesce(nullif(next->>cost.key,''),'0')::numeric*100)) into total_cents from unnest(array['CS','AG','CT','CY','AP','DE']) as cost(key);
  next:=jsonb_set(next,'{DF}',to_jsonb(to_char(total_cents::numeric/100,'FM999999999990.00')));
  if next is distinct from r.data::jsonb then update public.records set data=next::text,revision=revision+1 where month=r.month and employee=r.employee;changed:=changed+1;end if;
 end loop;
 return changed;
end $$;
revoke all on function public.refresh_finance_childcare(text,text) from public,anon,authenticated;
grant execute on function public.refresh_finance_childcare(text,text) to service_role;
create or replace function public.save_finance_childcare(p_month text,p_actor text,p_action text,p_child jsonb)
returns jsonb language plpgsql security invoker set search_path='' as $$
declare old public.childcare_children%rowtype;v text;start_month text;last_month text;birth date;changed integer;
begin
 if p_month is null or p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_actor is null or length(p_actor) not between 1 and 200 or p_action is null or p_action not in('childcare_child','childcare_sync') then raise exception 'Invalid childcare action';end if;
 lock table public.childcare_children,public.employees,public.normative_wages,public.periods,public.records,public.versions in share row exclusive mode;
 if p_action='childcare_sync' then changed:=public.refresh_finance_childcare(p_month,null);return jsonb_build_object('ok',true,'changed',changed);end if;
 if p_child is null or jsonb_typeof(p_child)<>'object' or coalesce(p_child->>'id','') !~ '^[-a-zA-Z0-9]{20,80}$' or length(coalesce(p_child->>'name','')) not between 1 and 200 or coalesce(p_child->>'birthDate','') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then raise exception 'Invalid child';end if;
 birth:=(p_child->>'birthDate')::date;
 if birth>(now() at time zone 'America/Sao_Paulo')::date then raise exception 'Future birth';end if;
 start_month:=left(p_child->>'birthDate',7);last_month:=to_char(birth+interval '7 years','YYYY-MM');
 select data into v from public.versions where employee=p_child->>'employee' and month<=p_month order by month desc limit 1;
 if v is null or v::jsonb->>'gender' is distinct from 'Feminino' or not exists(select 1 from public.employees where id=p_child->>'employee' and active=1) or not exists(select 1 from public.normative_wages where month<=p_month) then return jsonb_build_object('ok',false);end if;
 select * into old from public.childcare_children where id=p_child->>'id';
 if found then
  if not p_child ? 'revision' and old.employee=p_child->>'employee' and old.child_name=p_child->>'name' and old.birth_date=p_child->>'birthDate' then return jsonb_build_object('ok',true,'id',old.id);end if;
  if old.employee is distinct from p_child->>'employee' or old.revision is distinct from (p_child->>'revision')::integer then return jsonb_build_object('ok',false);end if;
 end if;
 if exists(select 1 from public.childcare_children where employee=p_child->>'employee' and child_name=p_child->>'name' and birth_date=p_child->>'birthDate' and id<>p_child->>'id') then return jsonb_build_object('ok',false);end if;
 insert into public.childcare_children(id,employee,child_name,birth_date,start,last_credit,revision,created) values(p_child->>'id',p_child->>'employee',p_child->>'name',p_child->>'birthDate',start_month,last_month,1,now()::text) on conflict(id) do update set child_name=excluded.child_name,birth_date=excluded.birth_date,start=excluded.start,last_credit=excluded.last_credit,revision=childcare_children.revision+1;
 changed:=public.refresh_finance_childcare(p_month,p_child->>'employee');
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Filho(a) do auxílio-creche cadastrado',p_actor,now()::text,p_child::text);
 return jsonb_build_object('ok',true,'id',p_child->>'id','changed',changed);
end $$;
revoke all on function public.save_finance_childcare(text,text,text,jsonb) from public,anon,authenticated;
grant execute on function public.save_finance_childcare(text,text,text,jsonb) to service_role;
