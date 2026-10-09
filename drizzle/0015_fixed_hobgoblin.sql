ALTER TABLE `app_users` ADD `email` text;--> statement-breakpoint
CREATE UNIQUE INDEX `app_users_email_unique` ON `app_users` (`email`);