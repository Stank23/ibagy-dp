DO $$ DECLARE t record; BEGIN FOR t IN SELECT tablename FROM pg_tables WHERE schemaname='ibagy' LOOP EXECUTE format('CREATE POLICY backend_only ON ibagy.%I FOR ALL TO service_role USING (true) WITH CHECK (true)', t.tablename); END LOOP; END $$;
CREATE INDEX idx_loans_employee ON ibagy.loans(employee);
CREATE INDEX idx_app_sessions_expires ON ibagy.app_sessions(expires);
CREATE INDEX idx_app_login_attempts_since ON ibagy.app_login_attempts(since);
