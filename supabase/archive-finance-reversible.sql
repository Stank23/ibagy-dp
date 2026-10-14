-- Explicitly authorized operational archive. No financial rows are deleted.
-- Run as database owner, once, in a transaction. Restore with companion script.
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
DO $archive$
DECLARE
  names text[] := ARRAY['administrators','allowances','audit','childcare_children','dsr_city_settings','dsr_settings','employees','event_plans','files','installments','job_functions','loans','minimum_wages','normative_wages','periods','records','unimed_rates','uniodonto_fixed_rates','uniodonto_rates','versions'];
  n text; r record; c bigint; h text;
BEGIN
  IF to_regnamespace('ibagy_archive_20261013') IS NOT NULL THEN RAISE EXCEPTION 'Archive already exists'; END IF;
  IF (SELECT count(*) FROM pg_tables WHERE schemaname='public') <> 23 THEN RAISE EXCEPTION 'Unexpected public tables'; END IF;
  IF EXISTS(SELECT 1 FROM pg_class WHERE relnamespace='public'::regnamespace AND relkind IN ('S','v','m')) THEN RAISE EXCEPTION 'Unsupported sequence/view'; END IF;
  IF EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid IN (SELECT oid FROM pg_class WHERE relnamespace='public'::regnamespace) AND NOT tgisinternal) THEN RAISE EXCEPTION 'Unsupported trigger'; END IF;
  IF EXISTS(SELECT 1 FROM pg_proc WHERE pronamespace='public'::regnamespace AND (prorettype IN (SELECT reltype FROM pg_class WHERE relnamespace='public'::regnamespace) OR proargtypes::oid[] && ARRAY(SELECT reltype FROM pg_class WHERE relnamespace='public'::regnamespace))) THEN RAISE EXCEPTION 'Unsupported typed function'; END IF;
  IF (SELECT count(*) FROM public.app_users) <> 1 OR NOT EXISTS(SELECT 1 FROM public.app_users WHERE username='adm' AND role='admin' AND active=1) THEN RAISE EXCEPTION 'Admin precondition failed'; END IF;
  FOREACH n IN ARRAY names LOOP EXECUTE format('LOCK TABLE public.%I IN ACCESS EXCLUSIVE MODE',n); END LOOP;
  CREATE SCHEMA ibagy_archive_20261013;
  REVOKE ALL ON SCHEMA ibagy_archive_20261013 FROM PUBLIC,anon,authenticated,service_role;
  CREATE TABLE ibagy_archive_20261013._checks(name text PRIMARY KEY, rows bigint NOT NULL, digest text NOT NULL);
  CREATE TABLE ibagy_archive_20261013._foreign_keys(name text, constraint_name text, definition text);
  CREATE TABLE ibagy_archive_20261013._functions(definition text NOT NULL);
  -- Qualify FK destinations before moving originals.
  PERFORM set_config('search_path','pg_catalog',true);
  INSERT INTO ibagy_archive_20261013._foreign_keys
    SELECT cl.relname,con.conname,pg_get_constraintdef(con.oid) FROM pg_constraint con JOIN pg_class cl ON cl.oid=con.conrelid
    WHERE con.contype='f' AND cl.relnamespace='public'::regnamespace AND cl.relname=ANY(names);
  IF EXISTS(SELECT 1 FROM pg_constraint con JOIN pg_class parent ON parent.oid=con.confrelid JOIN pg_class child ON child.oid=con.conrelid WHERE con.contype='f' AND parent.relnamespace='public'::regnamespace AND parent.relname=ANY(names) AND NOT(child.relnamespace='public'::regnamespace AND child.relname=ANY(names))) THEN RAISE EXCEPTION 'External incoming FK'; END IF;
  INSERT INTO ibagy_archive_20261013._functions SELECT pg_get_functiondef(oid) FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname<>'rls_auto_enable';
  FOREACH n IN ARRAY names LOOP
    EXECUTE format('SELECT count(*),md5(coalesce(jsonb_agg(to_jsonb(t) ORDER BY to_jsonb(t)::text)::text,''[]'')) FROM public.%I t',n) INTO c,h;
    INSERT INTO ibagy_archive_20261013._checks VALUES(n,c,h);
    EXECUTE format('ALTER TABLE public.%I SET SCHEMA ibagy_archive_20261013',n);
  END LOOP;
  FOREACH n IN ARRAY names LOOP
    EXECUTE format('CREATE TABLE public.%I (LIKE ibagy_archive_20261013.%I INCLUDING ALL)',n,n);
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',n);
    EXECUTE format('REVOKE ALL ON TABLE public.%I FROM PUBLIC,anon,authenticated,service_role',n);
    EXECUTE format('GRANT SELECT,INSERT,UPDATE,DELETE ON TABLE public.%I TO service_role',n);
  END LOOP;
  REVOKE UPDATE,DELETE ON public.audit FROM service_role;
  FOR r IN SELECT * FROM ibagy_archive_20261013._foreign_keys LOOP EXECUTE format('ALTER TABLE public.%I ADD CONSTRAINT %I %s',r.name,r.constraint_name,r.definition); END LOOP;
  FOR r IN SELECT * FROM ibagy_archive_20261013._functions LOOP EXECUTE r.definition; END LOOP;
  FOR r IN SELECT tablename FROM pg_tables WHERE schemaname='ibagy_archive_20261013' LOOP
    EXECUTE format('ALTER TABLE ibagy_archive_20261013.%I ENABLE ROW LEVEL SECURITY',r.tablename);
  END LOOP;
  REVOKE ALL ON ALL TABLES IN SCHEMA ibagy_archive_20261013 FROM PUBLIC,anon,authenticated,service_role;
  FOR r IN SELECT * FROM ibagy_archive_20261013._checks LOOP
    EXECUTE format('SELECT count(*),md5(coalesce(jsonb_agg(to_jsonb(t) ORDER BY to_jsonb(t)::text)::text,''[]'')) FROM ibagy_archive_20261013.%I t',r.name) INTO c,h;
    IF c<>r.rows OR h<>r.digest THEN RAISE EXCEPTION 'Archive integrity failed: %',r.name; END IF;
    EXECUTE format('SELECT count(*) FROM public.%I',r.name) INTO c;
    IF c<>0 THEN RAISE EXCEPTION 'Fresh table not empty'; END IF;
  END LOOP;
END $archive$;
NOTIFY pgrst, 'reload schema';
