CREATE TABLE `event_plans` (
	`id` text PRIMARY KEY NOT NULL,
	`employee` text NOT NULL,
	`event` text NOT NULL,
	`amount` integer NOT NULL,
	`count` integer NOT NULL,
	`start` text NOT NULL,
	`end` text NOT NULL,
	`created` text NOT NULL,
	FOREIGN KEY (`employee`) REFERENCES `employees`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_event_plans_employee_start` ON `event_plans` (`employee`,`start`);