create or replace function public.save_job_function(p_name text,p_key text,p_actor text,p_month text)
returns text language plpgsql security invoker set search_path=public as $$
declare v_name text;v_inserted boolean;
begin
 if p_name is null or length(p_name)<1 or length(p_name)>180 or p_name<>btrim(p_name) or p_name ~ '[[:cntrl:]]' then raise exception 'Invalid function name';end if;
 if p_key is null or p_key<>lower(p_name) or length(p_key)>180 then raise exception 'Invalid function key';end if;
 if p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_actor is null or length(p_actor) not between 1 and 200 then raise exception 'Invalid audit context';end if;
 insert into job_functions(name,key) values(p_name,p_key) on conflict(key) do nothing;
 v_inserted:=found;
 select name into v_name from job_functions where key=p_key;
 if v_inserted then insert into audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Função cadastrada',p_actor,now()::text,jsonb_build_object('name',v_name)::text);end if;
 return v_name;
end $$;
revoke all on function public.save_job_function(text,text,text,text) from public,anon,authenticated;
grant execute on function public.save_job_function(text,text,text,text) to service_role;