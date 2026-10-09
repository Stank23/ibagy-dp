create or replace function public.register_finance_event_plan(p_month text,p_actor text,p_plan jsonb)
returns boolean language plpgsql security invoker set search_path='' as $$
declare old public.event_plans%rowtype;v text;r record;next jsonb;event text;amount bigint;
begin
 if p_actor is null or length(p_actor) not between 1 and 200 or p_month is null or p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_plan is null or coalesce(p_plan->>'id','') !~ '^[-a-zA-Z0-9]{20,80}$' or coalesce(p_plan->>'event','') not in('CK','AM') or coalesce(p_plan->>'start','') !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or coalesce(p_plan->>'end','') !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or coalesce((p_plan->>'count')::integer,0) not between 1 and 120 or coalesce((p_plan->>'amount')::bigint,0)<=0 then raise exception 'Invalid event plan';end if;
 if p_plan->>'start'<p_month or to_char(to_date(p_plan->>'start'||'-01','YYYY-MM-DD')+make_interval(months=>(p_plan->>'count')::integer-1),'YYYY-MM')<>p_plan->>'end' then raise exception 'Invalid schedule';end if;
 lock table public.employees,public.event_plans,public.periods,public.records,public.versions in share row exclusive mode;
 select * into old from public.event_plans where id=p_plan->>'id';
 if found then return old.employee=p_plan->>'employee' and old.event=p_plan->>'event' and old.amount=(p_plan->>'amount')::bigint and old.count=(p_plan->>'count')::integer and old.start=p_plan->>'start';end if;
 select data into v from public.versions where employee=p_plan->>'employee' and month<=p_plan->>'start' order by month desc limit 1;
 if v is null or left(v::jsonb->>'D',7)>p_plan->>'start' or not exists(select 1 from public.employees where id=p_plan->>'employee' and active=1) or exists(select 1 from public.periods where month between p_plan->>'start' and p_plan->>'end' and status='closed') then return false;end if;
 event:=p_plan->>'event';amount:=(p_plan->>'amount')::bigint;
 insert into public.event_plans(id,employee,event,amount,count,start,"end",created) values(p_plan->>'id',p_plan->>'employee',event,amount,(p_plan->>'count')::integer,p_plan->>'start',p_plan->>'end',now()::text);
 for r in select rec.* from public.records rec join public.periods p on p.month=rec.month where rec.employee=p_plan->>'employee' and rec.month between p_plan->>'start' and p_plan->>'end' and p.status='open' and coalesce(rec.data::jsonb->>'_excluded','false')<>'true' loop
  next:=r.data::jsonb||jsonb_build_object(event,to_char((round(coalesce(nullif(r.data::jsonb->>event,''),'0')::numeric*100)+amount)/100,'FM999999999990.00'),'_eventAuto'||event,coalesce((r.data::jsonb->>('_eventAuto'||event))::bigint,0)+amount);
  update public.records set data=next::text,revision=revision+1 where month=r.month and employee=r.employee;
 end loop;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Parcelamento cadastrado',p_actor,now()::text,p_plan::text);
 return true;
end $$;
revoke all on function public.register_finance_event_plan(text,text,jsonb) from public,anon,authenticated;
grant execute on function public.register_finance_event_plan(text,text,jsonb) to service_role;
