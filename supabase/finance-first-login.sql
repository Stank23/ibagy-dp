-- Additive migration; existing accounts retain access until explicitly reset.
alter table public.app_users add column if not exists must_change_password boolean not null default false;
create or replace function public.create_finance_auth_session(p_user text,p_expected_hash text,p_token text,p_expires bigint,p_now bigint,p_old_token text default null)
returns boolean language plpgsql security invoker set search_path='' as $$
declare u public.app_users;
begin
 if p_user is null or p_expected_hash is null or p_expected_hash !~ '^[a-f0-9]{64}$' or p_token is null or p_token !~ '^[a-f0-9]{64}$' or p_now is null or p_expires is null or p_expires<=p_now or p_expires>p_now+28800000 then raise exception 'Invalid session';end if;
 select * into u from public.app_users where id=p_user for update;
 if not found or u.active<>1 or u.must_change_password or u.password_hash is distinct from p_expected_hash then return false;end if;
 delete from public.app_sessions where user_id=p_user and expires<=p_now;
 if p_old_token is not null then delete from public.app_sessions where token_hash=p_old_token;end if;
 delete from public.app_sessions where user_id=p_user and token_hash in(select token_hash from public.app_sessions where user_id=p_user order by expires desc,token_hash offset 4);
 insert into public.app_sessions(token_hash,user_id,expires) values(p_token,p_user,p_expires);
 return true;
end $$;
revoke all on function public.create_finance_auth_session(text,text,text,bigint,bigint,text) from public,anon,authenticated;
grant execute on function public.create_finance_auth_session(text,text,text,bigint,bigint,text) to service_role;
create or replace function public.change_finance_password_and_session(p_user text,p_expected_hash text,p_salt text,p_hash text,p_token text,p_expires bigint,p_now bigint,p_old_token text default null)
returns boolean language plpgsql security invoker set search_path='' as $$
declare u public.app_users;
begin
 if p_salt is null or p_salt !~ '^[a-f0-9]{32}$' or p_hash is null or p_hash !~ '^[a-f0-9]{64}$' or p_hash=p_expected_hash then raise exception 'Invalid new password';end if;
 select * into u from public.app_users where id=p_user for update;
 if not found or u.active<>1 or u.password_hash is distinct from p_expected_hash then return false;end if;
 update public.app_users set salt=p_salt,password_hash=p_hash,must_change_password=false where id=p_user;
 delete from public.app_sessions where user_id=p_user;
 if not public.create_finance_auth_session(p_user,p_hash,p_token,p_expires,p_now,p_old_token) then raise exception 'Session changed';end if;
 insert into public.audit(id,month,action,actor,created,detail) values(gen_random_uuid()::text,to_char(now() at time zone 'America/Sao_Paulo','YYYY-MM'),'Senha pessoal definida',u.username,now()::text,jsonb_build_object('user',p_user,'firstLogin',u.must_change_password)::text);
 return true;
end $$;
revoke all on function public.change_finance_password_and_session(text,text,text,text,text,bigint,bigint,text) from public,anon,authenticated;
grant execute on function public.change_finance_password_and_session(text,text,text,text,text,bigint,bigint,text) to service_role;
