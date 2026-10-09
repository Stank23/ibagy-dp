CREATE TABLE app_users (id TEXT PRIMARY KEY NOT NULL, username TEXT NOT NULL, name TEXT NOT NULL, role TEXT NOT NULL CHECK(role IN ('admin','viewer')), salt TEXT NOT NULL, password_hash TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1);
--> statement-breakpoint
CREATE UNIQUE INDEX app_users_username_unique ON app_users(username);
--> statement-breakpoint
CREATE TABLE app_sessions (token_hash TEXT PRIMARY KEY NOT NULL, user_id TEXT NOT NULL REFERENCES app_users(id), expires INTEGER NOT NULL);
--> statement-breakpoint
CREATE INDEX app_sessions_user ON app_sessions(user_id);
--> statement-breakpoint
CREATE TABLE app_login_attempts (key TEXT PRIMARY KEY NOT NULL, failures INTEGER NOT NULL, since INTEGER NOT NULL);
--> statement-breakpoint
-- Credencial inicial removida da cópia de recuperação. Cadastre uma conta e autorize-a pelo administrador do banco.
