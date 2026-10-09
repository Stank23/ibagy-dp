CREATE INDEX `idx_audit_month_created` ON `audit` (`month`,`created`);--> statement-breakpoint
CREATE INDEX `idx_event_plans_start_end` ON `event_plans` (`start`,`end`);--> statement-breakpoint
CREATE INDEX `idx_files_month_created` ON `files` (`month`,`created`);--> statement-breakpoint
CREATE INDEX `idx_installments_month_employee` ON `installments` (`month`,`employee`);