CREATE TABLE `dsr_settings` (
	`write_id` text NOT NULL,
	`month` text PRIMARY KEY NOT NULL,
	`useful` integer NOT NULL,
	`rest` integer NOT NULL,
	`revision` integer DEFAULT 1 NOT NULL
);
