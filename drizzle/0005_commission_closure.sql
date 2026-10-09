ALTER TABLE periods ADD COLUMN commission_status TEXT NOT NULL DEFAULT 'open';
--> statement-breakpoint
UPDATE periods SET commission_status = 'closed' WHERE status = 'closed';
