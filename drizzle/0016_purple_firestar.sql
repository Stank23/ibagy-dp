CREATE TABLE `uniodonto_rates` (
	`month` text PRIMARY KEY NOT NULL,
	`young` integer NOT NULL,
	`middle` integer NOT NULL,
	`senior` integer NOT NULL,
	`revision` integer DEFAULT 1 NOT NULL
);
