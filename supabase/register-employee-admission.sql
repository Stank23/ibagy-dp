-- Keep the v77 admission range: employees may have joined before year 2000.
-- Competence validation remains unchanged. Existing employees/versions are untouched.
create or replace function public.register_finance_employee(p_id text,p_registration text,p_month text,p_effective text,p_data jsonb,p_actor text,p_active integer)
returns boolean language plpgsql security invoker set search_path=public as $$
declare v_cpf text;v_existing text;
begin
 if p_id is null or length(p_id) not between 1 and 120 or p_registration is null or length(p_registration) not between 1 and 80 or p_registration ~ '[[:cntrl:]]' then raise exception 'Invalid identity';end if;
 if p_month !~ '^20[0-9]{2}-(0[1-9]|1[0-2])$' or p_effective !~ '^[0-9]{4}-(0[1-9]|1[0-2])$' or p_actor is null or length(p_actor) not between 1 and 200 then raise exception 'Invalid context';end if;
 if p_active not in(0,1) or p_data->>'B' is distinct from p_registration or coalesce(p_data->>'C','')='' or coalesce(p_data->>'H','')='' or p_data->>'D' !~ '^[0-9]{4}-(0[1-9]|1[0-2])-[0-3][0-9]$' or left(p_data->>'D',7)<>p_effective then raise exception 'Invalid employee data';end if;
 v_cpf:=regexp_replace(coalesce(p_data->>'E',''),'[^0-9]','','g');
 if length(v_cpf)<>11 then raise exception 'Invalid CPF';end if;
 perform pg_advisory_xact_lock(hashtext('ibagy-employee-register'));
 if exists(select 1 from employees where id=p_id or registration=p_registration) then return false;end if;
 if exists(select 1 from versions where regexp_replace(coalesce(data::jsonb->>'E',''),'[^0-9]','','g')=v_cpf) then return false;end if;
 if coalesce(p_data->>'receivesVA','true')<>'false' and not exists(select 1 from allowances where month<=p_month) then raise exception 'VA not configured';end if;
 insert into employees(id,registration,active) values(p_id,p_registration,p_active);
 insert into versions(employee,month,data) values(p_id,p_effective,p_data::text);
 insert into audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,p_month,'Cadastro atualizado',p_actor,now()::text,jsonb_build_object('employee',p_id,'effective',p_effective)::text);
 return true;
end $$;
revoke all on function public.register_finance_employee(text,text,text,text,jsonb,text,integer) from public,anon,authenticated;
grant execute on function public.register_finance_employee(text,text,text,text,jsonb,text,integer) to service_role;
