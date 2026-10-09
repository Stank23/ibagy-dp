-- One-time reset explicitly requested by the owner on 2026-10-08.
-- Preserve authentication, permissions, schema and the job-function catalogue.
DELETE FROM installments;
--> statement-breakpoint
DELETE FROM loans;
--> statement-breakpoint
DELETE FROM event_plans;
--> statement-breakpoint
DELETE FROM childcare_children;
--> statement-breakpoint
DELETE FROM files;
--> statement-breakpoint
DELETE FROM records;
--> statement-breakpoint
DELETE FROM versions;
--> statement-breakpoint
DELETE FROM employees;
--> statement-breakpoint
DELETE FROM periods;
--> statement-breakpoint
DELETE FROM allowances;
--> statement-breakpoint
DELETE FROM minimum_wages;
--> statement-breakpoint
DELETE FROM normative_wages;
--> statement-breakpoint
DELETE FROM dsr_settings;
--> statement-breakpoint
DELETE FROM unimed_rates;
--> statement-breakpoint
DELETE FROM uniodonto_fixed_rates;
--> statement-breakpoint
DELETE FROM uniodonto_rates;
--> statement-breakpoint
DELETE FROM audit;
