CREATE TABLE `unimed_rates` (
	`month` text PRIMARY KEY NOT NULL,
	`young` integer NOT NULL,
	`middle` integer NOT NULL,
	`senior` integer NOT NULL,
	`revision` integer DEFAULT 1 NOT NULL
);
--> statement-breakpoint
CREATE TABLE `uniodonto_fixed_rates` (
	`month` text PRIMARY KEY NOT NULL,
	`amount` integer NOT NULL,
	`revision` integer DEFAULT 1 NOT NULL
);

--> statement-breakpoint
INSERT INTO unimed_rates(month,young,middle,senior,revision)
SELECT month,young,middle,senior,revision FROM uniodonto_rates WHERE 1
ON CONFLICT(month) DO NOTHING;
