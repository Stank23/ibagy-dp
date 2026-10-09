CREATE TABLE `childcare_children` (
	`id` text PRIMARY KEY NOT NULL,
	`employee` text NOT NULL,
	`child_name` text NOT NULL,
	`birth_date` text NOT NULL,
	`start` text NOT NULL,
	`last_credit` text NOT NULL,
	`revision` integer DEFAULT 1 NOT NULL,
	`created` text NOT NULL,
	FOREIGN KEY (`employee`) REFERENCES `employees`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_childcare_children_employee_start` ON `childcare_children` (`employee`,`start`);