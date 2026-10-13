-- The application uses server-only credentials and its own account/session checks.
revoke all on table public.administrators,public.allowances,public.app_login_attempts,public.app_sessions,public.app_users,public.audit,public.childcare_children,public.dsr_settings,public.employees,public.event_plans,public.files,public.installments,public.job_functions,public.loans,public.minimum_wages,public.normative_wages,public.periods,public.records,public.unimed_rates,public.uniodonto_fixed_rates,public.uniodonto_rates,public.versions,public.dsr_city_settings from public,anon,authenticated;
create or replace function public.create_finance_auth_session(p_user text,p_expected_hash text,p_token text,p_expires bigint,p_now bigint,p_old_token text default null)
returns boolean language plpgsql security invoker set search_path='' as $$
declare u public.app_users;
begin
 if p_user is null or p_expected_hash is null or p_expected_hash !~ '^[a-f0-9]{64}$' or p_token is null or p_token !~ '^[a-f0-9]{64}$' or p_now is null or p_expires is null or p_expires<=p_now or p_expires>p_now+28800000 then raise exception 'Invalid session';end if;
 select * into u from public.app_users where id=p_user for update;
 if not found or u.active<>1 or u.password_hash is distinct from p_expected_hash then return false;end if;
 delete from public.app_sessions where user_id=p_user and expires<=p_now;
 if p_old_token is not null then delete from public.app_sessions where token_hash=p_old_token;end if;
 delete from public.app_sessions where user_id=p_user and token_hash in(select token_hash from public.app_sessions where user_id=p_user order by expires desc,token_hash offset 4);
 insert into public.app_sessions(token_hash,user_id,expires) values(p_token,p_user,p_expires);
 return true;
end $$;
revoke all on function public.create_finance_auth_session(text,text,text,bigint,bigint,text) from public,anon,authenticated;
grant execute on function public.create_finance_auth_session(text,text,text,bigint,bigint,text) to service_role;
create or replace function public.mutate_finance_account(p_actor text,p_action text,p_data jsonb)
returns boolean language plpgsql security invoker set search_path='' as $$
declare actor public.app_users;target public.app_users;target_id text;
begin
 if p_actor is null or p_action not in('create','email','password','role','toggle') or p_data is null or jsonb_typeof(p_data)<>'object' then raise exception 'Invalid account action';end if;
 lock table public.app_users in share row exclusive mode;
 select * into actor from public.app_users where id=p_actor and active=1 and role='admin';if not found then return false;end if;
 target_id:=p_data->>'id';if target_id is null or length(target_id) not between 1 and 120 then return false;end if;
 if p_action='create' then
  if p_data->>'role' not in('admin','viewer') or p_data->>'username' !~ '^[a-z0-9._-]{3,60}$' or coalesce(length(p_data->>'name'),0) not between 1 and 120 or p_data->>'salt' !~ '^[a-f0-9]{32}$' or p_data->>'password_hash' !~ '^[a-f0-9]{64}$' then return false;end if;
  insert into public.app_users(id,username,name,email,role,salt,password_hash,active) values(target_id,p_data->>'username',p_data->>'name',p_data->>'email',p_data->>'role',p_data->>'salt',p_data->>'password_hash',1);
 else
  select * into target from public.app_users where id=target_id;if not found then return false;end if;
  if p_action='password' then
   if p_data->>'salt' !~ '^[a-f0-9]{32}$' or p_data->>'password_hash' !~ '^[a-f0-9]{64}$' then return false;end if;
   update public.app_users set salt=p_data->>'salt',password_hash=p_data->>'password_hash' where id=target_id;
  elsif p_action='role' then
   if target_id=p_actor or p_data->>'role' not in('admin','viewer') then return false;end if;
   update public.app_users set role=p_data->>'role' where id=target_id;
  elsif p_action='toggle' then
   if target_id=p_actor then return false;end if;
   update public.app_users set active=case when active=1 then 0 else 1 end where id=target_id;
  elsif p_action='email' then
   if coalesce(length(p_data->>'email'),0) not between 3 and 254 then return false;end if;
   update public.app_users set email=p_data->>'email' where id=target_id;
  end if;
  if p_action in('password','role','toggle') then delete from public.app_sessions where user_id=target_id;end if;
 end if;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,to_char(now() at time zone 'America/Sao_Paulo','YYYY-MM'),'Conta: '||p_action,actor.username,now()::text,jsonb_build_object('target',target_id,'action',p_action)::text);
 return true;
exception when unique_violation then return false;
end $$;
revoke all on function public.mutate_finance_account(text,text,jsonb) from public,anon,authenticated;
grant execute on function public.mutate_finance_account(text,text,jsonb) to service_role;
revoke update,delete,truncate on public.audit from service_role;
