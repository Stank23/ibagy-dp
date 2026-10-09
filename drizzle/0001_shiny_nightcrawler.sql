CREATE TABLE `allowances` (
	`month` text PRIMARY KEY NOT NULL,
	`amount` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `installments` (
	`loan` text NOT NULL,
	`employee` text NOT NULL,
	`month` text NOT NULL,
	`number` integer NOT NULL,
	`principal` integer NOT NULL,
	`fee` integer NOT NULL,
	`amount` integer NOT NULL,
	PRIMARY KEY(`loan`, `month`),
	FOREIGN KEY (`loan`) REFERENCES `loans`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`employee`) REFERENCES `employees`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_installments_employee_month` ON `installments` (`employee`,`month`);--> statement-breakpoint
CREATE TABLE `loans` (
	`id` text PRIMARY KEY NOT NULL,
	`employee` text NOT NULL,
	`amount` integer NOT NULL,
	`count` integer NOT NULL,
	`start` text NOT NULL,
	`end` text NOT NULL,
	`created` text NOT NULL,
	FOREIGN KEY (`employee`) REFERENCES `employees`(`id`) ON UPDATE no action ON DELETE no action
);
