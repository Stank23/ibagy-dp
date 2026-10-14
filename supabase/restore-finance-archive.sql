-- Preserve post-archive records too. Never overwrites or deletes financial rows.
-- Review deployed function/schema versions before restoration. Owner only.
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
DO $restore$
DECLARE r record;
BEGIN
  IF to_regnamespace('ibagy_archive_20261013') IS NULL OR to_regnamespace('ibagy_after_archive_20261013') IS NOT NULL THEN RAISE EXCEPTION 'Restore precondition failed'; END IF;
  CREATE SCHEMA ibagy_after_archive_20261013;
  REVOKE ALL ON SCHEMA ibagy_after_archive_20261013 FROM PUBLIC,anon,authenticated,service_role;
  FOR r IN SELECT name FROM ibagy_archive_20261013._checks ORDER BY name LOOP EXECUTE format('LOCK TABLE public.%I IN ACCESS EXCLUSIVE MODE',r.name); END LOOP;
  FOR r IN SELECT name FROM ibagy_archive_20261013._checks ORDER BY name LOOP EXECUTE format('ALTER TABLE public.%I SET SCHEMA ibagy_after_archive_20261013',r.name); END LOOP;
  FOR r IN SELECT name FROM ibagy_archive_20261013._checks ORDER BY name LOOP
    EXECUTE format('ALTER TABLE ibagy_archive_20261013.%I SET SCHEMA public',r.name);
    EXECUTE format('GRANT SELECT,INSERT,UPDATE,DELETE ON public.%I TO service_role',r.name);
  END LOOP;
  REVOKE UPDATE,DELETE ON public.audit FROM service_role;
  REVOKE ALL ON ALL TABLES IN SCHEMA ibagy_after_archive_20261013 FROM PUBLIC,anon,authenticated,service_role;
  FOR r IN SELECT definition FROM ibagy_archive_20261013._functions LOOP EXECUTE r.definition; END LOOP;
END $restore$;
NOTIFY pgrst, 'reload schema';
