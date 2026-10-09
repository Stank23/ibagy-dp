CREATE TABLE `audit` (
	`id` text PRIMARY KEY NOT NULL,
	`month` text NOT NULL,
	`action` text NOT NULL,
	`actor` text NOT NULL,
	`created` text NOT NULL,
	`detail` text NOT NULL
);
--> statement-breakpoint
CREATE INDEX `idx_audit_month` ON `audit` (`month`);--> statement-breakpoint
CREATE TABLE `employees` (
	`id` text PRIMARY KEY NOT NULL,
	`registration` text NOT NULL,
	`active` integer DEFAULT 1 NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `employees_registration_unique` ON `employees` (`registration`);--> statement-breakpoint
CREATE TABLE `files` (
	`id` text PRIMARY KEY NOT NULL,
	`month` text NOT NULL,
	`kind` text NOT NULL,
	`name` text NOT NULL,
	`key` text NOT NULL,
	`created` text NOT NULL,
	FOREIGN KEY (`month`) REFERENCES `periods`(`month`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_files_month` ON `files` (`month`);--> statement-breakpoint
CREATE TABLE `periods` (
	`month` text PRIMARY KEY NOT NULL,
	`status` text DEFAULT 'open' NOT NULL
);
--> statement-breakpoint
CREATE TABLE `records` (
	`month` text NOT NULL,
	`employee` text NOT NULL,
	`data` text NOT NULL,
	`revision` integer DEFAULT 1 NOT NULL,
	PRIMARY KEY(`month`, `employee`),
	FOREIGN KEY (`month`) REFERENCES `periods`(`month`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`employee`) REFERENCES `employees`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_records_employee` ON `records` (`employee`);--> statement-breakpoint
CREATE TABLE `versions` (
	`employee` text NOT NULL,
	`month` text NOT NULL,
	`data` text NOT NULL,
	PRIMARY KEY(`employee`, `month`),
	FOREIGN KEY (`employee`) REFERENCES `employees`(`id`) ON UPDATE no action ON DELETE no action
);
