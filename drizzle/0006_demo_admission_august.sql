UPDATE versions SET data=json_set(data,'$.D','2026-08-01','$.M','0.00','$.O',printf('%.2f',CAST(json_extract(data,'$.K') AS REAL)+COALESCE(CAST(json_extract(data,'$.N') AS REAL),0))) WHERE employee IN (SELECT id FROM employees WHERE id LIKE 'ibagy-teste-%');
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT employee,'2026-08',data FROM versions v WHERE employee IN (SELECT id FROM employees WHERE id LIKE 'ibagy-teste-%') AND month=(SELECT MIN(month) FROM versions WHERE employee=v.employee) AND month>'2026-08' ON CONFLICT(employee,month) DO NOTHING;
--> statement-breakpoint
UPDATE records SET data=json_set(data,'$.D','2026-08-01','$.M','0.00','$.salaryCompetencia',printf('%.2f',CAST(json_extract(data,'$.K') AS REAL)),'$.O',printf('%.2f',CAST(json_extract(data,'$.K') AS REAL)+COALESCE(CAST(json_extract(data,'$.N') AS REAL),0))),revision=revision+1 WHERE employee IN (SELECT id FROM employees WHERE id LIKE 'ibagy-teste-%') AND month>='2026-08';
