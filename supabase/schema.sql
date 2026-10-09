CREATE SCHEMA ibagy;

REVOKE ALL ON SCHEMA ibagy FROM PUBLIC, anon, authenticated;

GRANT USAGE ON SCHEMA ibagy TO service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA ibagy REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA ibagy REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;

CREATE TABLE ibagy."administrators" (
  "account_id" text NOT NULL,
  "email" text NOT NULL,
  PRIMARY KEY ("account_id")
);

CREATE TABLE ibagy."allowances" (
  "month" text NOT NULL,
  "amount" bigint NOT NULL,
  PRIMARY KEY ("month")
);

CREATE TABLE ibagy."app_login_attempts" (
  "key" text NOT NULL,
  "failures" bigint NOT NULL,
  "since" bigint NOT NULL,
  PRIMARY KEY ("key")
);

CREATE TABLE ibagy."app_sessions" (
  "token_hash" text NOT NULL,
  "user_id" text NOT NULL,
  "expires" bigint NOT NULL,
  PRIMARY KEY ("token_hash")
);

CREATE TABLE ibagy."app_users" (
  "id" text NOT NULL,
  "username" text NOT NULL,
  "name" text NOT NULL,
  "role" text NOT NULL,
  "salt" text NOT NULL,
  "password_hash" text NOT NULL,
  "active" bigint NOT NULL DEFAULT 1,
  "email" text,
  PRIMARY KEY ("id")
);

CREATE TABLE ibagy."audit" (
  "id" text NOT NULL,
  "month" text NOT NULL,
  "action" text NOT NULL,
  "actor" text NOT NULL,
  "created" text NOT NULL,
  "detail" text NOT NULL CHECK ("detail"::jsonb IS NOT NULL),
  PRIMARY KEY ("id")
);

CREATE TABLE ibagy."childcare_children" (
  "id" text NOT NULL,
  "employee" text NOT NULL,
  "child_name" text NOT NULL,
  "birth_date" text NOT NULL,
  "start" text NOT NULL,
  "last_credit" text NOT NULL,
  "revision" bigint NOT NULL DEFAULT 1,
  "created" text NOT NULL,
  PRIMARY KEY ("id")
);

CREATE TABLE ibagy."dsr_settings" (
  "write_id" text NOT NULL,
  "month" text NOT NULL,
  "useful" bigint NOT NULL,
  "rest" bigint NOT NULL,
  "revision" bigint NOT NULL DEFAULT 1,
  PRIMARY KEY ("month")
);

CREATE TABLE ibagy."employees" (
  "id" text NOT NULL,
  "registration" text NOT NULL,
  "active" bigint NOT NULL DEFAULT 1,
  PRIMARY KEY ("id")
);

CREATE TABLE ibagy."event_plans" (
  "id" text NOT NULL,
  "employee" text NOT NULL,
  "event" text NOT NULL,
  "amount" bigint NOT NULL,
  "count" bigint NOT NULL,
  "start" text NOT NULL,
  "end" text NOT NULL,
  "created" text NOT NULL,
  PRIMARY KEY ("id")
);

CREATE TABLE ibagy."files" (
  "id" text NOT NULL,
  "month" text NOT NULL,
  "kind" text NOT NULL,
  "name" text NOT NULL,
  "key" text NOT NULL,
  "created" text NOT NULL,
  PRIMARY KEY ("id")
);

CREATE TABLE ibagy."installments" (
  "loan" text NOT NULL,
  "employee" text NOT NULL,
  "month" text NOT NULL,
  "number" bigint NOT NULL,
  "principal" bigint NOT NULL,
  "fee" bigint NOT NULL,
  "amount" bigint NOT NULL,
  PRIMARY KEY ("loan", "month")
);

CREATE TABLE ibagy."job_functions" (
  "name" text NOT NULL,
  "key" text NOT NULL,
  PRIMARY KEY ("name")
);

CREATE TABLE ibagy."loans" (
  "id" text NOT NULL,
  "employee" text NOT NULL,
  "amount" bigint NOT NULL,
  "count" bigint NOT NULL,
  "start" text NOT NULL,
  "end" text NOT NULL,
  "created" text NOT NULL,
  PRIMARY KEY ("id")
);

CREATE TABLE ibagy."minimum_wages" (
  "month" text NOT NULL,
  "amount" bigint NOT NULL,
  PRIMARY KEY ("month")
);

CREATE TABLE ibagy."normative_wages" (
  "month" text NOT NULL,
  "amount" bigint NOT NULL,
  PRIMARY KEY ("month")
);

CREATE TABLE ibagy."periods" (
  "month" text NOT NULL,
  "status" text NOT NULL DEFAULT 'open',
  "commission_status" text NOT NULL DEFAULT 'open',
  PRIMARY KEY ("month")
);

CREATE TABLE ibagy."records" (
  "month" text NOT NULL,
  "employee" text NOT NULL,
  "data" text NOT NULL CHECK ("data"::jsonb IS NOT NULL),
  "revision" bigint NOT NULL DEFAULT 1,
  PRIMARY KEY ("month", "employee")
);

CREATE TABLE ibagy."unimed_rates" (
  "month" text NOT NULL,
  "young" bigint NOT NULL,
  "middle" bigint NOT NULL,
  "senior" bigint NOT NULL,
  "revision" bigint NOT NULL DEFAULT 1,
  PRIMARY KEY ("month")
);

CREATE TABLE ibagy."uniodonto_fixed_rates" (
  "month" text NOT NULL,
  "amount" bigint NOT NULL,
  "revision" bigint NOT NULL DEFAULT 1,
  PRIMARY KEY ("month")
);

CREATE TABLE ibagy."uniodonto_rates" (
  "month" text NOT NULL,
  "young" bigint NOT NULL,
  "middle" bigint NOT NULL,
  "senior" bigint NOT NULL,
  "revision" bigint NOT NULL DEFAULT 1,
  PRIMARY KEY ("month")
);

CREATE TABLE ibagy."versions" (
  "employee" text NOT NULL,
  "month" text NOT NULL,
  "data" text NOT NULL CHECK ("data"::jsonb IS NOT NULL),
  PRIMARY KEY ("employee", "month")
);

CREATE UNIQUE INDEX "administrators_email_unique" ON ibagy."administrators" ("email");

ALTER TABLE ibagy."administrators" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."administrators" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."administrators" TO service_role;

ALTER TABLE ibagy."allowances" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."allowances" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."allowances" TO service_role;

ALTER TABLE ibagy."app_login_attempts" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."app_login_attempts" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."app_login_attempts" TO service_role;

ALTER TABLE ibagy."app_sessions" ADD FOREIGN KEY ("user_id") REFERENCES ibagy."app_users" ("id");

CREATE INDEX "app_sessions_user" ON ibagy."app_sessions" ("user_id");

ALTER TABLE ibagy."app_sessions" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."app_sessions" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."app_sessions" TO service_role;

CREATE UNIQUE INDEX "app_users_email_unique" ON ibagy."app_users" ("email");

CREATE UNIQUE INDEX "app_users_username_unique" ON ibagy."app_users" ("username");

ALTER TABLE ibagy."app_users" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."app_users" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."app_users" TO service_role;

CREATE INDEX "idx_audit_month_created" ON ibagy."audit" ("month", "created");

CREATE INDEX "idx_audit_month" ON ibagy."audit" ("month");

ALTER TABLE ibagy."audit" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."audit" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."audit" TO service_role;

ALTER TABLE ibagy."childcare_children" ADD FOREIGN KEY ("employee") REFERENCES ibagy."employees" ("id");

CREATE INDEX "idx_childcare_children_employee_start" ON ibagy."childcare_children" ("employee", "start");

ALTER TABLE ibagy."childcare_children" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."childcare_children" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."childcare_children" TO service_role;

ALTER TABLE ibagy."dsr_settings" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."dsr_settings" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."dsr_settings" TO service_role;

CREATE UNIQUE INDEX "employees_registration_unique" ON ibagy."employees" ("registration");

ALTER TABLE ibagy."employees" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."employees" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."employees" TO service_role;

ALTER TABLE ibagy."event_plans" ADD FOREIGN KEY ("employee") REFERENCES ibagy."employees" ("id");

CREATE INDEX "idx_event_plans_start_end" ON ibagy."event_plans" ("start", "end");

CREATE INDEX "idx_event_plans_employee_start" ON ibagy."event_plans" ("employee", "start");

ALTER TABLE ibagy."event_plans" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."event_plans" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."event_plans" TO service_role;

ALTER TABLE ibagy."files" ADD FOREIGN KEY ("month") REFERENCES ibagy."periods" ("month");

CREATE INDEX "idx_files_month_created" ON ibagy."files" ("month", "created");

CREATE INDEX "idx_files_month" ON ibagy."files" ("month");

ALTER TABLE ibagy."files" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."files" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."files" TO service_role;

ALTER TABLE ibagy."installments" ADD FOREIGN KEY ("employee") REFERENCES ibagy."employees" ("id");

ALTER TABLE ibagy."installments" ADD FOREIGN KEY ("loan") REFERENCES ibagy."loans" ("id");

CREATE INDEX "idx_installments_month_employee" ON ibagy."installments" ("month", "employee");

CREATE INDEX "idx_installments_employee_month" ON ibagy."installments" ("employee", "month");

ALTER TABLE ibagy."installments" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."installments" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."installments" TO service_role;

CREATE UNIQUE INDEX "job_functions_key_unique" ON ibagy."job_functions" ("key");

ALTER TABLE ibagy."job_functions" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."job_functions" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."job_functions" TO service_role;

ALTER TABLE ibagy."loans" ADD FOREIGN KEY ("employee") REFERENCES ibagy."employees" ("id");

ALTER TABLE ibagy."loans" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."loans" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."loans" TO service_role;

ALTER TABLE ibagy."minimum_wages" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."minimum_wages" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."minimum_wages" TO service_role;

ALTER TABLE ibagy."normative_wages" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."normative_wages" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."normative_wages" TO service_role;

ALTER TABLE ibagy."periods" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."periods" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."periods" TO service_role;

ALTER TABLE ibagy."records" ADD FOREIGN KEY ("employee") REFERENCES ibagy."employees" ("id");

ALTER TABLE ibagy."records" ADD FOREIGN KEY ("month") REFERENCES ibagy."periods" ("month");

CREATE INDEX "idx_records_employee" ON ibagy."records" ("employee");

ALTER TABLE ibagy."records" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."records" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."records" TO service_role;

ALTER TABLE ibagy."unimed_rates" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."unimed_rates" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."unimed_rates" TO service_role;

ALTER TABLE ibagy."uniodonto_fixed_rates" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."uniodonto_fixed_rates" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."uniodonto_fixed_rates" TO service_role;

ALTER TABLE ibagy."uniodonto_rates" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."uniodonto_rates" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."uniodonto_rates" TO service_role;

ALTER TABLE ibagy."versions" ADD FOREIGN KEY ("employee") REFERENCES ibagy."employees" ("id");

ALTER TABLE ibagy."versions" ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON ibagy."versions" FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ibagy."versions" TO service_role;
