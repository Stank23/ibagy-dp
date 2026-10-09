CREATE TABLE `administrators` (
	`account_id` text PRIMARY KEY NOT NULL,
	`email` text NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `administrators_email_unique` ON `administrators` (`email`);
--> statement-breakpoint
INSERT INTO administrators(account_id,email) VALUES('9caae8d5-bf48-4904-bd33-30bf73470698','marcelostank3@gmail.com') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-001','990001',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-001','2026-09','{"B":"990001","C":"Ana Martins (Teste)","D":"2012-01-01","E":"","G":"Normal","H":"Matriz","J":"Administrativo","K":"2500.00","P":"","commissionType":"","receivesVA":false,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente administrativo","F":"1980-01-01"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-001' AND registration='990001') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-002','990002',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-002','2026-09','{"B":"990002","C":"Bruno Martins (Teste)","D":"2013-02-02","E":"","G":"Normal","H":"Biguaçu","J":"Administrativo Condomínio","K":"2533.55","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista administrativo","F":"1981-02-02"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-002' AND registration='990002') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-003','990003',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-003','2026-09','{"B":"990003","C":"Carla Martins (Teste)","D":"2014-03-03","E":"","G":"Normal","H":"Campeche","J":"Administrativo IPTU","K":"2567.11","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de IPTU","F":"1982-03-03"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-003' AND registration='990003') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-004','990004',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-004','2026-09','{"B":"990004","C":"Daniel Martins (Teste)","D":"2015-04-04","E":"","G":"Normal","H":"Centro","J":"Administrativo Água/Luz","K":"2600.67","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de contas","F":"1983-04-04"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-004' AND registration='990004') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-005','990005',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-005','2026-09','{"B":"990005","C":"Eduarda Martins (Teste)","D":"2016-05-05","E":"","G":"Normal","H":"Ingleses","J":"Financeiro","K":"2634.22","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"100.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista financeiro","F":"1984-05-05"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-005' AND registration='990005') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-006','990006',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-006','2026-09','{"B":"990006","C":"Felipe Martins (Teste)","D":"2017-06-06","E":"","G":"Normal","H":"Kobrasol","J":"RH","K":"2667.78","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de pessoal","F":"1985-06-06"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-006' AND registration='990006') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-007','990007',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-007','2026-09','{"B":"990007","C":"Gabriela Martins (Teste)","D":"2018-07-07","E":"","G":"Normal","H":"Palhoça","J":"CPD","K":"2701.34","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Analista de sistemas","F":"1986-07-07"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-007' AND registration='990007') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-008','990008',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-008','2026-09','{"B":"990008","C":"Henrique Martins (Teste)","D":"2019-08-08","E":"","G":"Normal","H":"Trindade","J":"Jurídico","K":"2734.89","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente jurídico","F":"1987-08-08"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-008' AND registration='990008') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-009','990009',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-009','2026-09','{"B":"990009","C":"Isabela Martins (Teste)","D":"2020-09-09","E":"","G":"Normal","H":"Matriz","J":"Arquivo","K":"2768.45","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de arquivo","F":"1988-09-09"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-009' AND registration='990009') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-010','990010',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-010','2026-09','{"B":"990010","C":"João Martins (Teste)","D":"2021-01-10","E":"","G":"Normal","H":"Biguaçu","J":"Recepção","K":"2802.01","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Recepcionista","F":"1989-10-10"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-010' AND registration='990010') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-011','990011',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-011','2026-09','{"B":"990011","C":"Karen Martins (Teste)","D":"2022-02-11","E":"","G":"Normal","H":"Campeche","J":"Comercial","K":"2835.57","P":"Comissão Honorários Normais","commissionType":"Comissão Honorários Normais","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor comercial","F":"1990-11-11"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-011' AND registration='990011') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-012','990012',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-012','2026-09','{"B":"990012","C":"Lucas Martins (Teste)","D":"2023-03-12","E":"","G":"Normal","H":"Centro","J":"Comercial Captador","K":"2869.12","P":"Comissão Tx Intermediação Captação","commissionType":"Comissão Tx Intermediação Captação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Captador de imóveis","F":"1991-12-12"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-012' AND registration='990012') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-013','990013',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-013','2026-09','{"B":"990013","C":"Mariana Martins (Teste)","D":"2024-04-13","E":"","G":"Normal","H":"Ingleses","J":"Comercial Leads","K":"2902.68","P":"Comissão Leads","commissionType":"Comissão Leads","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Consultor de leads","F":"1980-01-13"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-013' AND registration='990013') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-014','990014',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-014','2026-09','{"B":"990014","C":"Nicolas Martins (Teste)","D":"2025-05-14","E":"","G":"Normal","H":"Kobrasol","J":"Relacionamento","K":"2936.24","P":"Comissão Relacionamento","commissionType":"Comissão Relacionamento","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de relacionamento","F":"1981-02-14"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-014' AND registration='990014') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-015','990015',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-015','2026-09','{"B":"990015","C":"Olívia Martins (Teste)","D":"2026-06-15","E":"","G":"Normal","H":"Palhoça","J":"Manutenção","K":"2969.79","P":"Comissão Manutenção","commissionType":"Comissão Manutenção","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico de manutenção","F":"1982-03-15"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-015' AND registration='990015') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-016','990016',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-016','2026-09','{"B":"990016","C":"Pedro Martins (Teste)","D":"2012-07-16","E":"","G":"Normal","H":"Trindade","J":"Manutenção Externa","K":"3003.35","P":"Comissão Condominio Manutenção","commissionType":"Comissão Condominio Manutenção","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":true,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico externo","F":"1983-04-16"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-016' AND registration='990016') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-017','990017',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-017','2026-09','{"B":"990017","C":"Rafaela Martins (Teste)","D":"2013-08-17","E":"","G":"Normal","H":"Matriz","J":"Agente de Visitas","K":"3036.91","P":"Comissão Agente de Visita","commissionType":"Comissão Agente de Visita","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Agente de visitas","F":"1984-05-17"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-017' AND registration='990017') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-018','990018',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-018','2026-09','{"B":"990018","C":"Samuel Martins (Teste)","D":"2014-09-18","E":"","G":"Normal","H":"Biguaçu","J":"Contratos Comercial","K":"3070.46","P":"Premiação - Contratos","commissionType":"Premiação - Contratos","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de contratos","F":"1985-06-18"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-018' AND registration='990018') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-019','990019',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-019','2026-09','{"B":"990019","C":"Tatiana Martins (Teste)","D":"2015-01-19","E":"","G":"Normal","H":"Campeche","J":"Locação","K":"3104.02","P":"Comissão Taxa Intermediação","commissionType":"Comissão Taxa Intermediação","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor de locação","F":"1986-07-19"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-019' AND registration='990019') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-020','990020',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-020','2026-09','{"B":"990020","C":"Vinícius Martins (Teste)","D":"2016-02-20","E":"","G":"Normal","H":"Centro","J":"Renovações","K":"3137.58","P":"Taxa de Intermediação Reajuste Real","commissionType":"Taxa de Intermediação Reajuste Real","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de renovações","F":"1987-08-20"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-020' AND registration='990020') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-021','990021',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-021','2026-09','{"B":"990021","C":"Amanda Martins (Teste)","D":"2017-03-21","E":"","G":"Normal","H":"Ingleses","J":"Qualidade","K":"3171.14","P":"","commissionType":"","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de qualidade","F":"1988-09-21"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-021' AND registration='990021') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-022','990022',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-022','2026-09','{"B":"990022","C":"Caio Martins (Teste)","D":"2018-04-22","E":"","G":"Normal","H":"Kobrasol","J":"Vistoria Ocupação","K":"3204.69","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador","F":"1989-10-22"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-022' AND registration='990022') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-023','990023',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-023','2026-09','{"B":"990023","C":"Débora Martins (Teste)","D":"2019-05-23","E":"","G":"Normal","H":"Palhoça","J":"Vistoria Desocupação","K":"3238.25","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador de saída","F":"1990-11-23"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-023' AND registration='990023') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-024','990024',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-024','2026-09','{"B":"990024","C":"Enzo Martins (Teste)","D":"2020-06-24","E":"","G":"Normal","H":"Trindade","J":"Seguro","K":"3271.81","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de seguros","F":"1991-12-24"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-024' AND registration='990024') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-025','990025',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-025','2026-09','{"B":"990025","C":"Fernanda Martins (Teste)","D":"2021-07-25","E":"","G":"Normal","H":"Matriz","J":"Limpeza","K":"3305.36","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"150.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de limpeza","F":"1980-01-25"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-025' AND registration='990025') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-026','990026',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-026','2026-09','{"B":"990026","C":"Gustavo Martins (Teste)","D":"2022-08-26","E":"","G":"Normal","H":"Biguaçu","J":"Administrativo","K":"3338.92","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente administrativo","F":"1981-02-26"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-026' AND registration='990026') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-027','990027',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-027','2026-09','{"B":"990027","C":"Helena Martins (Teste)","D":"2023-09-27","E":"","G":"Normal","H":"Campeche","J":"Administrativo Condomínio","K":"3372.48","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista administrativo","F":"1982-03-27"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-027' AND registration='990027') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-028','990028',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-028','2026-09','{"B":"990028","C":"Igor Martins (Teste)","D":"2024-01-01","E":"","G":"Normal","H":"Centro","J":"Administrativo IPTU","K":"3406.04","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de IPTU","F":"1983-04-28"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-028' AND registration='990028') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-029','990029',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-029','2026-09','{"B":"990029","C":"Juliana Martins (Teste)","D":"2025-02-02","E":"","G":"Normal","H":"Ingleses","J":"Administrativo Água/Luz","K":"3439.59","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de contas","F":"1984-05-01"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-029' AND registration='990029') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-030','990030',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-030','2026-09','{"B":"990030","C":"Leonardo Martins (Teste)","D":"2026-03-03","E":"","G":"Normal","H":"Kobrasol","J":"Financeiro","K":"3473.15","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"100.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista financeiro","F":"1985-06-02"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-030' AND registration='990030') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-031','990031',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-031','2026-09','{"B":"990031","C":"Ana Costa (Teste)","D":"2012-04-04","E":"","G":"Normal","H":"Palhoça","J":"RH","K":"3506.71","P":"","commissionType":"","receivesVA":false,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de pessoal","F":"1986-07-03"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-031' AND registration='990031') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-032','990032',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-032','2026-09','{"B":"990032","C":"Bruno Costa (Teste)","D":"2013-05-05","E":"","G":"Normal","H":"Trindade","J":"CPD","K":"3540.26","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Analista de sistemas","F":"1987-08-04"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-032' AND registration='990032') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-033','990033',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-033','2026-09','{"B":"990033","C":"Carla Costa (Teste)","D":"2014-06-06","E":"","G":"Normal","H":"Matriz","J":"Jurídico","K":"3573.82","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente jurídico","F":"1988-09-05"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-033' AND registration='990033') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-034','990034',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-034','2026-09','{"B":"990034","C":"Daniel Costa (Teste)","D":"2015-07-07","E":"","G":"Normal","H":"Biguaçu","J":"Arquivo","K":"3607.38","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de arquivo","F":"1989-10-06"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-034' AND registration='990034') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-035','990035',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-035','2026-09','{"B":"990035","C":"Eduarda Costa (Teste)","D":"2016-08-08","E":"","G":"Normal","H":"Campeche","J":"Recepção","K":"3640.93","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Recepcionista","F":"1990-11-07"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-035' AND registration='990035') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-036','990036',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-036','2026-09','{"B":"990036","C":"Felipe Costa (Teste)","D":"2017-09-09","E":"","G":"Normal","H":"Centro","J":"Comercial","K":"3674.49","P":"Comissão Honorários Normais","commissionType":"Comissão Honorários Normais","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor comercial","F":"1991-12-08"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-036' AND registration='990036') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-037','990037',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-037','2026-09','{"B":"990037","C":"Gabriela Costa (Teste)","D":"2018-01-10","E":"","G":"Normal","H":"Ingleses","J":"Comercial Captador","K":"3708.05","P":"Comissão Tx Intermediação Captação","commissionType":"Comissão Tx Intermediação Captação","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Captador de imóveis","F":"1980-01-09"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-037' AND registration='990037') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-038','990038',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-038','2026-09','{"B":"990038","C":"Henrique Costa (Teste)","D":"2019-02-11","E":"","G":"Normal","H":"Kobrasol","J":"Comercial Leads","K":"3741.61","P":"Comissão Leads","commissionType":"Comissão Leads","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Consultor de leads","F":"1981-02-10"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-038' AND registration='990038') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-039','990039',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-039','2026-09','{"B":"990039","C":"Isabela Costa (Teste)","D":"2020-03-12","E":"","G":"Normal","H":"Palhoça","J":"Relacionamento","K":"3775.16","P":"Comissão Relacionamento","commissionType":"Comissão Relacionamento","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de relacionamento","F":"1982-03-11"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-039' AND registration='990039') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-040','990040',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-040','2026-09','{"B":"990040","C":"João Costa (Teste)","D":"2021-04-13","E":"","G":"Normal","H":"Trindade","J":"Manutenção","K":"3808.72","P":"Comissão Manutenção","commissionType":"Comissão Manutenção","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico de manutenção","F":"1983-04-12"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-040' AND registration='990040') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-041','990041',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-041','2026-09','{"B":"990041","C":"Karen Costa (Teste)","D":"2022-05-14","E":"","G":"Normal","H":"Matriz","J":"Manutenção Externa","K":"3842.28","P":"Comissão Condominio Manutenção","commissionType":"Comissão Condominio Manutenção","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":true,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico externo","F":"1984-05-13"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-041' AND registration='990041') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-042','990042',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-042','2026-09','{"B":"990042","C":"Lucas Costa (Teste)","D":"2023-06-15","E":"","G":"Normal","H":"Biguaçu","J":"Agente de Visitas","K":"3875.83","P":"Comissão Agente de Visita","commissionType":"Comissão Agente de Visita","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Agente de visitas","F":"1985-06-14"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-042' AND registration='990042') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-043','990043',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-043','2026-09','{"B":"990043","C":"Mariana Costa (Teste)","D":"2024-07-16","E":"","G":"Normal","H":"Campeche","J":"Contratos Comercial","K":"3909.39","P":"Premiação - Contratos","commissionType":"Premiação - Contratos","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de contratos","F":"1986-07-15"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-043' AND registration='990043') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-044','990044',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-044','2026-09','{"B":"990044","C":"Nicolas Costa (Teste)","D":"2025-08-17","E":"","G":"Normal","H":"Centro","J":"Locação","K":"3942.95","P":"Comissão Taxa Intermediação","commissionType":"Comissão Taxa Intermediação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor de locação","F":"1987-08-16"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-044' AND registration='990044') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-045','990045',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-045','2026-09','{"B":"990045","C":"Olívia Costa (Teste)","D":"2026-09-18","E":"","G":"Normal","H":"Ingleses","J":"Renovações","K":"3976.51","P":"Taxa de Intermediação Reajuste Real","commissionType":"Taxa de Intermediação Reajuste Real","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de renovações","F":"1988-09-17"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-045' AND registration='990045') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-046','990046',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-046','2026-09','{"B":"990046","C":"Pedro Costa (Teste)","D":"2012-01-19","E":"","G":"Normal","H":"Kobrasol","J":"Qualidade","K":"4010.06","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de qualidade","F":"1989-10-18"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-046' AND registration='990046') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-047','990047',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-047','2026-09','{"B":"990047","C":"Rafaela Costa (Teste)","D":"2013-02-20","E":"","G":"Normal","H":"Palhoça","J":"Vistoria Ocupação","K":"4043.62","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador","F":"1990-11-19"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-047' AND registration='990047') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-048','990048',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-048','2026-09','{"B":"990048","C":"Samuel Costa (Teste)","D":"2014-03-21","E":"","G":"Normal","H":"Trindade","J":"Vistoria Desocupação","K":"4077.18","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador de saída","F":"1991-12-20"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-048' AND registration='990048') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-049','990049',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-049','2026-09','{"B":"990049","C":"Tatiana Costa (Teste)","D":"2015-04-22","E":"","G":"Normal","H":"Matriz","J":"Seguro","K":"4110.73","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de seguros","F":"1980-01-21"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-049' AND registration='990049') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-050','990050',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-050','2026-09','{"B":"990050","C":"Vinícius Costa (Teste)","D":"2016-05-23","E":"","G":"Normal","H":"Biguaçu","J":"Limpeza","K":"4144.29","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"150.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de limpeza","F":"1981-02-22"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-050' AND registration='990050') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-051','990051',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-051','2026-09','{"B":"990051","C":"Amanda Costa (Teste)","D":"2017-06-24","E":"","G":"Normal","H":"Campeche","J":"Administrativo","K":"4177.85","P":"","commissionType":"","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente administrativo","F":"1982-03-23"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-051' AND registration='990051') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-052','990052',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-052','2026-09','{"B":"990052","C":"Caio Costa (Teste)","D":"2018-07-25","E":"","G":"Normal","H":"Centro","J":"Administrativo Condomínio","K":"4211.40","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista administrativo","F":"1983-04-24"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-052' AND registration='990052') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-053','990053',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-053','2026-09','{"B":"990053","C":"Débora Costa (Teste)","D":"2019-08-26","E":"","G":"Normal","H":"Ingleses","J":"Administrativo IPTU","K":"4244.96","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de IPTU","F":"1984-05-25"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-053' AND registration='990053') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-054','990054',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-054','2026-09','{"B":"990054","C":"Enzo Costa (Teste)","D":"2020-09-27","E":"","G":"Normal","H":"Kobrasol","J":"Administrativo Água/Luz","K":"4278.52","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de contas","F":"1985-06-26"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-054' AND registration='990054') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-055','990055',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-055','2026-09','{"B":"990055","C":"Fernanda Costa (Teste)","D":"2021-01-01","E":"","G":"Normal","H":"Palhoça","J":"Financeiro","K":"4312.08","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"100.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista financeiro","F":"1986-07-27"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-055' AND registration='990055') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-056','990056',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-056','2026-09','{"B":"990056","C":"Gustavo Costa (Teste)","D":"2022-02-02","E":"","G":"Normal","H":"Trindade","J":"RH","K":"4345.63","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de pessoal","F":"1987-08-28"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-056' AND registration='990056') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-057','990057',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-057','2026-09','{"B":"990057","C":"Helena Costa (Teste)","D":"2023-03-03","E":"","G":"Normal","H":"Matriz","J":"CPD","K":"4379.19","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Analista de sistemas","F":"1988-09-01"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-057' AND registration='990057') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-058','990058',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-058','2026-09','{"B":"990058","C":"Igor Costa (Teste)","D":"2024-04-04","E":"","G":"Normal","H":"Biguaçu","J":"Jurídico","K":"4412.75","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente jurídico","F":"1989-10-02"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-058' AND registration='990058') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-059','990059',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-059','2026-09','{"B":"990059","C":"Juliana Costa (Teste)","D":"2025-05-05","E":"","G":"Normal","H":"Campeche","J":"Arquivo","K":"4446.30","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de arquivo","F":"1990-11-03"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-059' AND registration='990059') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-060','990060',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-060','2026-09','{"B":"990060","C":"Leonardo Costa (Teste)","D":"2026-06-06","E":"","G":"Normal","H":"Centro","J":"Recepção","K":"4479.86","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Recepcionista","F":"1991-12-04"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-060' AND registration='990060') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-061','990061',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-061','2026-09','{"B":"990061","C":"Ana Almeida (Teste)","D":"2012-07-07","E":"","G":"Normal","H":"Ingleses","J":"Comercial","K":"4513.42","P":"Comissão Honorários Normais","commissionType":"Comissão Honorários Normais","receivesVA":false,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor comercial","F":"1980-01-05"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-061' AND registration='990061') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-062','990062',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-062','2026-09','{"B":"990062","C":"Bruno Almeida (Teste)","D":"2013-08-08","E":"","G":"Normal","H":"Kobrasol","J":"Comercial Captador","K":"4546.97","P":"Comissão Tx Intermediação Captação","commissionType":"Comissão Tx Intermediação Captação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Captador de imóveis","F":"1981-02-06"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-062' AND registration='990062') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-063','990063',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-063','2026-09','{"B":"990063","C":"Carla Almeida (Teste)","D":"2014-09-09","E":"","G":"Normal","H":"Palhoça","J":"Comercial Leads","K":"4580.53","P":"Comissão Leads","commissionType":"Comissão Leads","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Consultor de leads","F":"1982-03-07"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-063' AND registration='990063') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-064','990064',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-064','2026-09','{"B":"990064","C":"Daniel Almeida (Teste)","D":"2015-01-10","E":"","G":"Normal","H":"Trindade","J":"Relacionamento","K":"4614.09","P":"Comissão Relacionamento","commissionType":"Comissão Relacionamento","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de relacionamento","F":"1983-04-08"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-064' AND registration='990064') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-065','990065',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-065','2026-09','{"B":"990065","C":"Eduarda Almeida (Teste)","D":"2016-02-11","E":"","G":"Normal","H":"Matriz","J":"Manutenção","K":"4647.65","P":"Comissão Manutenção","commissionType":"Comissão Manutenção","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico de manutenção","F":"1984-05-09"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-065' AND registration='990065') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-066','990066',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-066','2026-09','{"B":"990066","C":"Felipe Almeida (Teste)","D":"2017-03-12","E":"","G":"Normal","H":"Biguaçu","J":"Manutenção Externa","K":"4681.20","P":"Comissão Condominio Manutenção","commissionType":"Comissão Condominio Manutenção","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":true,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico externo","F":"1985-06-10"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-066' AND registration='990066') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-067','990067',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-067','2026-09','{"B":"990067","C":"Gabriela Almeida (Teste)","D":"2018-04-13","E":"","G":"Normal","H":"Campeche","J":"Agente de Visitas","K":"4714.76","P":"Comissão Agente de Visita","commissionType":"Comissão Agente de Visita","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Agente de visitas","F":"1986-07-11"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-067' AND registration='990067') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-068','990068',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-068','2026-09','{"B":"990068","C":"Henrique Almeida (Teste)","D":"2019-05-14","E":"","G":"Normal","H":"Centro","J":"Contratos Comercial","K":"4748.32","P":"Premiação - Contratos","commissionType":"Premiação - Contratos","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de contratos","F":"1987-08-12"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-068' AND registration='990068') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-069','990069',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-069','2026-09','{"B":"990069","C":"Isabela Almeida (Teste)","D":"2020-06-15","E":"","G":"Normal","H":"Ingleses","J":"Locação","K":"4781.87","P":"Comissão Taxa Intermediação","commissionType":"Comissão Taxa Intermediação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor de locação","F":"1988-09-13"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-069' AND registration='990069') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-070','990070',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-070','2026-09','{"B":"990070","C":"João Almeida (Teste)","D":"2021-07-16","E":"","G":"Normal","H":"Kobrasol","J":"Renovações","K":"4815.43","P":"Taxa de Intermediação Reajuste Real","commissionType":"Taxa de Intermediação Reajuste Real","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de renovações","F":"1989-10-14"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-070' AND registration='990070') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-071','990071',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-071','2026-09','{"B":"990071","C":"Karen Almeida (Teste)","D":"2022-08-17","E":"","G":"Normal","H":"Palhoça","J":"Qualidade","K":"4848.99","P":"","commissionType":"","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de qualidade","F":"1990-11-15"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-071' AND registration='990071') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-072','990072',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-072','2026-09','{"B":"990072","C":"Lucas Almeida (Teste)","D":"2023-09-18","E":"","G":"Normal","H":"Trindade","J":"Vistoria Ocupação","K":"4882.55","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador","F":"1991-12-16"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-072' AND registration='990072') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-073','990073',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-073','2026-09','{"B":"990073","C":"Mariana Almeida (Teste)","D":"2024-01-19","E":"","G":"Normal","H":"Matriz","J":"Vistoria Desocupação","K":"4916.10","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador de saída","F":"1980-01-17"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-073' AND registration='990073') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-074','990074',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-074','2026-09','{"B":"990074","C":"Nicolas Almeida (Teste)","D":"2025-02-20","E":"","G":"Normal","H":"Biguaçu","J":"Seguro","K":"4949.66","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de seguros","F":"1981-02-18"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-074' AND registration='990074') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-075','990075',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-075','2026-09','{"B":"990075","C":"Olívia Almeida (Teste)","D":"2026-03-21","E":"","G":"Normal","H":"Campeche","J":"Limpeza","K":"4983.22","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"150.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de limpeza","F":"1982-03-19"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-075' AND registration='990075') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-076','990076',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-076','2026-09','{"B":"990076","C":"Pedro Almeida (Teste)","D":"2012-04-22","E":"","G":"Normal","H":"Centro","J":"Administrativo","K":"5016.77","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente administrativo","F":"1983-04-20"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-076' AND registration='990076') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-077','990077',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-077','2026-09','{"B":"990077","C":"Rafaela Almeida (Teste)","D":"2013-05-23","E":"","G":"Normal","H":"Ingleses","J":"Administrativo Condomínio","K":"5050.33","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista administrativo","F":"1984-05-21"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-077' AND registration='990077') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-078','990078',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-078','2026-09','{"B":"990078","C":"Samuel Almeida (Teste)","D":"2014-06-24","E":"","G":"Normal","H":"Kobrasol","J":"Administrativo IPTU","K":"5083.89","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de IPTU","F":"1985-06-22"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-078' AND registration='990078') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-079','990079',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-079','2026-09','{"B":"990079","C":"Tatiana Almeida (Teste)","D":"2015-07-25","E":"","G":"Normal","H":"Palhoça","J":"Administrativo Água/Luz","K":"5117.44","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de contas","F":"1986-07-23"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-079' AND registration='990079') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-080','990080',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-080','2026-09','{"B":"990080","C":"Vinícius Almeida (Teste)","D":"2016-08-26","E":"","G":"Normal","H":"Trindade","J":"Financeiro","K":"5151.00","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"100.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista financeiro","F":"1987-08-24"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-080' AND registration='990080') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-081','990081',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-081','2026-09','{"B":"990081","C":"Amanda Almeida (Teste)","D":"2017-09-27","E":"","G":"Normal","H":"Matriz","J":"RH","K":"5184.56","P":"","commissionType":"","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de pessoal","F":"1988-09-25"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-081' AND registration='990081') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-082','990082',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-082','2026-09','{"B":"990082","C":"Caio Almeida (Teste)","D":"2018-01-01","E":"","G":"Normal","H":"Biguaçu","J":"CPD","K":"5218.12","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Analista de sistemas","F":"1989-10-26"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-082' AND registration='990082') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-083','990083',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-083','2026-09','{"B":"990083","C":"Débora Almeida (Teste)","D":"2019-02-02","E":"","G":"Normal","H":"Campeche","J":"Jurídico","K":"5251.67","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente jurídico","F":"1990-11-27"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-083' AND registration='990083') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-084','990084',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-084','2026-09','{"B":"990084","C":"Enzo Almeida (Teste)","D":"2020-03-03","E":"","G":"Normal","H":"Centro","J":"Arquivo","K":"5285.23","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de arquivo","F":"1991-12-28"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-084' AND registration='990084') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-085','990085',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-085','2026-09','{"B":"990085","C":"Fernanda Almeida (Teste)","D":"2021-04-04","E":"","G":"Normal","H":"Ingleses","J":"Recepção","K":"5318.79","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Recepcionista","F":"1980-01-01"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-085' AND registration='990085') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-086','990086',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-086','2026-09','{"B":"990086","C":"Gustavo Almeida (Teste)","D":"2022-05-05","E":"","G":"Normal","H":"Kobrasol","J":"Comercial","K":"5352.34","P":"Comissão Honorários Normais","commissionType":"Comissão Honorários Normais","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor comercial","F":"1981-02-02"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-086' AND registration='990086') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-087','990087',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-087','2026-09','{"B":"990087","C":"Helena Almeida (Teste)","D":"2023-06-06","E":"","G":"Normal","H":"Palhoça","J":"Comercial Captador","K":"5385.90","P":"Comissão Tx Intermediação Captação","commissionType":"Comissão Tx Intermediação Captação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Captador de imóveis","F":"1982-03-03"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-087' AND registration='990087') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-088','990088',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-088','2026-09','{"B":"990088","C":"Igor Almeida (Teste)","D":"2024-07-07","E":"","G":"Normal","H":"Trindade","J":"Comercial Leads","K":"5419.46","P":"Comissão Leads","commissionType":"Comissão Leads","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Consultor de leads","F":"1983-04-04"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-088' AND registration='990088') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-089','990089',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-089','2026-09','{"B":"990089","C":"Juliana Almeida (Teste)","D":"2025-08-08","E":"","G":"Normal","H":"Matriz","J":"Relacionamento","K":"5453.02","P":"Comissão Relacionamento","commissionType":"Comissão Relacionamento","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de relacionamento","F":"1984-05-05"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-089' AND registration='990089') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-090','990090',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-090','2026-09','{"B":"990090","C":"Leonardo Almeida (Teste)","D":"2026-09-09","E":"","G":"Normal","H":"Biguaçu","J":"Manutenção","K":"5486.57","P":"Comissão Manutenção","commissionType":"Comissão Manutenção","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico de manutenção","F":"1985-06-06"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-090' AND registration='990090') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-091','990091',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-091','2026-09','{"B":"990091","C":"Ana Ribeiro (Teste)","D":"2012-01-10","E":"","G":"Normal","H":"Campeche","J":"Manutenção Externa","K":"5520.13","P":"Comissão Condominio Manutenção","commissionType":"Comissão Condominio Manutenção","receivesVA":false,"chargeSerefi":false,"receivesPericulosidade":true,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico externo","F":"1986-07-07"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-091' AND registration='990091') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-092','990092',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-092','2026-09','{"B":"990092","C":"Bruno Ribeiro (Teste)","D":"2013-02-11","E":"","G":"Normal","H":"Centro","J":"Agente de Visitas","K":"5553.69","P":"Comissão Agente de Visita","commissionType":"Comissão Agente de Visita","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Agente de visitas","F":"1987-08-08"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-092' AND registration='990092') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-093','990093',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-093','2026-09','{"B":"990093","C":"Carla Ribeiro (Teste)","D":"2014-03-12","E":"","G":"Normal","H":"Ingleses","J":"Contratos Comercial","K":"5587.24","P":"Premiação - Contratos","commissionType":"Premiação - Contratos","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de contratos","F":"1988-09-09"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-093' AND registration='990093') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-094','990094',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-094','2026-09','{"B":"990094","C":"Daniel Ribeiro (Teste)","D":"2015-04-13","E":"","G":"Normal","H":"Kobrasol","J":"Locação","K":"5620.80","P":"Comissão Taxa Intermediação","commissionType":"Comissão Taxa Intermediação","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor de locação","F":"1989-10-10"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-094' AND registration='990094') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-095','990095',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-095','2026-09','{"B":"990095","C":"Eduarda Ribeiro (Teste)","D":"2016-05-14","E":"","G":"Normal","H":"Palhoça","J":"Renovações","K":"5654.36","P":"Taxa de Intermediação Reajuste Real","commissionType":"Taxa de Intermediação Reajuste Real","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de renovações","F":"1990-11-11"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-095' AND registration='990095') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-096','990096',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-096','2026-09','{"B":"990096","C":"Felipe Ribeiro (Teste)","D":"2017-06-15","E":"","G":"Normal","H":"Trindade","J":"Qualidade","K":"5687.91","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de qualidade","F":"1991-12-12"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-096' AND registration='990096') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-097','990097',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-097','2026-09','{"B":"990097","C":"Gabriela Ribeiro (Teste)","D":"2018-07-16","E":"","G":"Normal","H":"Matriz","J":"Vistoria Ocupação","K":"5721.47","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador","F":"1980-01-13"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-097' AND registration='990097') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-098','990098',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-098','2026-09','{"B":"990098","C":"Henrique Ribeiro (Teste)","D":"2019-08-17","E":"","G":"Normal","H":"Biguaçu","J":"Vistoria Desocupação","K":"5755.03","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador de saída","F":"1981-02-14"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-098' AND registration='990098') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-099','990099',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-099','2026-09','{"B":"990099","C":"Isabela Ribeiro (Teste)","D":"2020-09-18","E":"","G":"Normal","H":"Campeche","J":"Seguro","K":"5788.59","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de seguros","F":"1982-03-15"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-099' AND registration='990099') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-100','990100',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-100','2026-09','{"B":"990100","C":"João Ribeiro (Teste)","D":"2021-01-19","E":"","G":"Normal","H":"Centro","J":"Limpeza","K":"5822.14","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"150.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de limpeza","F":"1983-04-16"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-100' AND registration='990100') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-101','990101',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-101','2026-09','{"B":"990101","C":"Karen Ribeiro (Teste)","D":"2022-02-20","E":"","G":"Normal","H":"Ingleses","J":"Administrativo","K":"5855.70","P":"","commissionType":"","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente administrativo","F":"1984-05-17"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-101' AND registration='990101') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-102','990102',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-102','2026-09','{"B":"990102","C":"Lucas Ribeiro (Teste)","D":"2023-03-21","E":"","G":"Normal","H":"Kobrasol","J":"Administrativo Condomínio","K":"5889.26","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista administrativo","F":"1985-06-18"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-102' AND registration='990102') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-103','990103',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-103','2026-09','{"B":"990103","C":"Mariana Ribeiro (Teste)","D":"2024-04-22","E":"","G":"Normal","H":"Palhoça","J":"Administrativo IPTU","K":"5922.81","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de IPTU","F":"1986-07-19"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-103' AND registration='990103') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-104','990104',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-104','2026-09','{"B":"990104","C":"Nicolas Ribeiro (Teste)","D":"2025-05-23","E":"","G":"Normal","H":"Trindade","J":"Administrativo Água/Luz","K":"5956.37","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de contas","F":"1987-08-20"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-104' AND registration='990104') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-105','990105',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-105','2026-09','{"B":"990105","C":"Olívia Ribeiro (Teste)","D":"2026-06-24","E":"","G":"Normal","H":"Matriz","J":"Financeiro","K":"5989.93","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"100.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista financeiro","F":"1988-09-21"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-105' AND registration='990105') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-106','990106',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-106','2026-09','{"B":"990106","C":"Pedro Ribeiro (Teste)","D":"2012-07-25","E":"","G":"Normal","H":"Biguaçu","J":"RH","K":"6023.48","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de pessoal","F":"1989-10-22"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-106' AND registration='990106') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-107','990107',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-107','2026-09','{"B":"990107","C":"Rafaela Ribeiro (Teste)","D":"2013-08-26","E":"","G":"Normal","H":"Campeche","J":"CPD","K":"6057.04","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Analista de sistemas","F":"1990-11-23"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-107' AND registration='990107') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-108','990108',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-108','2026-09','{"B":"990108","C":"Samuel Ribeiro (Teste)","D":"2014-09-27","E":"","G":"Normal","H":"Centro","J":"Jurídico","K":"6090.60","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente jurídico","F":"1991-12-24"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-108' AND registration='990108') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-109','990109',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-109','2026-09','{"B":"990109","C":"Tatiana Ribeiro (Teste)","D":"2015-01-01","E":"","G":"Normal","H":"Ingleses","J":"Arquivo","K":"6124.16","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de arquivo","F":"1980-01-25"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-109' AND registration='990109') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-110','990110',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-110','2026-09','{"B":"990110","C":"Vinícius Ribeiro (Teste)","D":"2016-02-02","E":"","G":"Normal","H":"Kobrasol","J":"Recepção","K":"6157.71","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Recepcionista","F":"1981-02-26"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-110' AND registration='990110') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-111','990111',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-111','2026-09','{"B":"990111","C":"Amanda Ribeiro (Teste)","D":"2017-03-03","E":"","G":"Normal","H":"Palhoça","J":"Comercial","K":"6191.27","P":"Comissão Honorários Normais","commissionType":"Comissão Honorários Normais","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor comercial","F":"1982-03-27"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-111' AND registration='990111') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-112','990112',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-112','2026-09','{"B":"990112","C":"Caio Ribeiro (Teste)","D":"2018-04-04","E":"","G":"Normal","H":"Trindade","J":"Comercial Captador","K":"6224.83","P":"Comissão Tx Intermediação Captação","commissionType":"Comissão Tx Intermediação Captação","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Captador de imóveis","F":"1983-04-28"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-112' AND registration='990112') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-113','990113',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-113','2026-09','{"B":"990113","C":"Débora Ribeiro (Teste)","D":"2019-05-05","E":"","G":"Normal","H":"Matriz","J":"Comercial Leads","K":"6258.38","P":"Comissão Leads","commissionType":"Comissão Leads","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Consultor de leads","F":"1984-05-01"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-113' AND registration='990113') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-114','990114',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-114','2026-09','{"B":"990114","C":"Enzo Ribeiro (Teste)","D":"2020-06-06","E":"","G":"Normal","H":"Biguaçu","J":"Relacionamento","K":"6291.94","P":"Comissão Relacionamento","commissionType":"Comissão Relacionamento","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de relacionamento","F":"1985-06-02"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-114' AND registration='990114') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-115','990115',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-115','2026-09','{"B":"990115","C":"Fernanda Ribeiro (Teste)","D":"2021-07-07","E":"","G":"Normal","H":"Campeche","J":"Manutenção","K":"6325.50","P":"Comissão Manutenção","commissionType":"Comissão Manutenção","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico de manutenção","F":"1986-07-03"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-115' AND registration='990115') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-116','990116',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-116','2026-09','{"B":"990116","C":"Gustavo Ribeiro (Teste)","D":"2022-08-08","E":"","G":"Normal","H":"Centro","J":"Manutenção Externa","K":"6359.06","P":"Comissão Condominio Manutenção","commissionType":"Comissão Condominio Manutenção","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":true,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico externo","F":"1987-08-04"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-116' AND registration='990116') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-117','990117',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-117','2026-09','{"B":"990117","C":"Helena Ribeiro (Teste)","D":"2023-09-09","E":"","G":"Normal","H":"Ingleses","J":"Agente de Visitas","K":"6392.61","P":"Comissão Agente de Visita","commissionType":"Comissão Agente de Visita","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Agente de visitas","F":"1988-09-05"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-117' AND registration='990117') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-118','990118',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-118','2026-09','{"B":"990118","C":"Igor Ribeiro (Teste)","D":"2024-01-10","E":"","G":"Normal","H":"Kobrasol","J":"Contratos Comercial","K":"6426.17","P":"Premiação - Contratos","commissionType":"Premiação - Contratos","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de contratos","F":"1989-10-06"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-118' AND registration='990118') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-119','990119',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-119','2026-09','{"B":"990119","C":"Juliana Ribeiro (Teste)","D":"2025-02-11","E":"","G":"Normal","H":"Palhoça","J":"Locação","K":"6459.73","P":"Comissão Taxa Intermediação","commissionType":"Comissão Taxa Intermediação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor de locação","F":"1990-11-07"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-119' AND registration='990119') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-120','990120',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-120','2026-09','{"B":"990120","C":"Leonardo Ribeiro (Teste)","D":"2026-03-12","E":"","G":"Normal","H":"Trindade","J":"Renovações","K":"6493.28","P":"Taxa de Intermediação Reajuste Real","commissionType":"Taxa de Intermediação Reajuste Real","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de renovações","F":"1991-12-08"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-120' AND registration='990120') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-121','990121',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-121','2026-09','{"B":"990121","C":"Ana Teixeira (Teste)","D":"2012-04-13","E":"","G":"Normal","H":"Matriz","J":"Qualidade","K":"6526.84","P":"","commissionType":"","receivesVA":false,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de qualidade","F":"1980-01-09"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-121' AND registration='990121') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-122','990122',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-122','2026-09','{"B":"990122","C":"Bruno Teixeira (Teste)","D":"2013-05-14","E":"","G":"Normal","H":"Biguaçu","J":"Vistoria Ocupação","K":"6560.40","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador","F":"1981-02-10"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-122' AND registration='990122') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-123','990123',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-123','2026-09','{"B":"990123","C":"Carla Teixeira (Teste)","D":"2014-06-15","E":"","G":"Normal","H":"Campeche","J":"Vistoria Desocupação","K":"6593.95","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador de saída","F":"1982-03-11"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-123' AND registration='990123') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-124','990124',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-124','2026-09','{"B":"990124","C":"Daniel Teixeira (Teste)","D":"2015-07-16","E":"","G":"Normal","H":"Centro","J":"Seguro","K":"6627.51","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de seguros","F":"1983-04-12"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-124' AND registration='990124') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-125','990125',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-125','2026-09','{"B":"990125","C":"Eduarda Teixeira (Teste)","D":"2016-08-17","E":"","G":"Normal","H":"Ingleses","J":"Limpeza","K":"6661.07","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"150.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de limpeza","F":"1984-05-13"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-125' AND registration='990125') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-126','990126',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-126','2026-09','{"B":"990126","C":"Felipe Teixeira (Teste)","D":"2017-09-18","E":"","G":"Normal","H":"Kobrasol","J":"Administrativo","K":"6694.63","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente administrativo","F":"1985-06-14"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-126' AND registration='990126') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-127','990127',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-127','2026-09','{"B":"990127","C":"Gabriela Teixeira (Teste)","D":"2018-01-19","E":"","G":"Normal","H":"Palhoça","J":"Administrativo Condomínio","K":"6728.18","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista administrativo","F":"1986-07-15"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-127' AND registration='990127') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-128','990128',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-128','2026-09','{"B":"990128","C":"Henrique Teixeira (Teste)","D":"2019-02-20","E":"","G":"Normal","H":"Trindade","J":"Administrativo IPTU","K":"6761.74","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de IPTU","F":"1987-08-16"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-128' AND registration='990128') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-129','990129',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-129','2026-09','{"B":"990129","C":"Isabela Teixeira (Teste)","D":"2020-03-21","E":"","G":"Normal","H":"Matriz","J":"Administrativo Água/Luz","K":"6795.30","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de contas","F":"1988-09-17"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-129' AND registration='990129') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-130','990130',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-130','2026-09','{"B":"990130","C":"João Teixeira (Teste)","D":"2021-04-22","E":"","G":"Normal","H":"Biguaçu","J":"Financeiro","K":"6828.85","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"100.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista financeiro","F":"1989-10-18"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-130' AND registration='990130') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-131','990131',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-131','2026-09','{"B":"990131","C":"Karen Teixeira (Teste)","D":"2022-05-23","E":"","G":"Normal","H":"Campeche","J":"RH","K":"6862.41","P":"","commissionType":"","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de pessoal","F":"1990-11-19"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-131' AND registration='990131') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-132','990132',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-132','2026-09','{"B":"990132","C":"Lucas Teixeira (Teste)","D":"2023-06-24","E":"","G":"Normal","H":"Centro","J":"CPD","K":"6895.97","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Analista de sistemas","F":"1991-12-20"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-132' AND registration='990132') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-133','990133',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-133','2026-09','{"B":"990133","C":"Mariana Teixeira (Teste)","D":"2024-07-25","E":"","G":"Normal","H":"Ingleses","J":"Jurídico","K":"6929.53","P":"","commissionType":"","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente jurídico","F":"1980-01-21"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-133' AND registration='990133') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-134','990134',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-134','2026-09','{"B":"990134","C":"Nicolas Teixeira (Teste)","D":"2025-08-26","E":"","G":"Normal","H":"Kobrasol","J":"Arquivo","K":"6963.08","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de arquivo","F":"1981-02-22"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-134' AND registration='990134') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-135','990135',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-135','2026-09','{"B":"990135","C":"Olívia Teixeira (Teste)","D":"2026-09-27","E":"","G":"Normal","H":"Palhoça","J":"Recepção","K":"6996.64","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Recepcionista","F":"1982-03-23"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-135' AND registration='990135') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-136','990136',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-136','2026-09','{"B":"990136","C":"Pedro Teixeira (Teste)","D":"2012-01-01","E":"","G":"Normal","H":"Trindade","J":"Comercial","K":"7030.20","P":"Comissão Honorários Normais","commissionType":"Comissão Honorários Normais","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor comercial","F":"1983-04-24"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-136' AND registration='990136') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-137','990137',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-137','2026-09','{"B":"990137","C":"Rafaela Teixeira (Teste)","D":"2013-02-02","E":"","G":"Normal","H":"Matriz","J":"Comercial Captador","K":"7063.75","P":"Comissão Tx Intermediação Captação","commissionType":"Comissão Tx Intermediação Captação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Captador de imóveis","F":"1984-05-25"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-137' AND registration='990137') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-138','990138',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-138','2026-09','{"B":"990138","C":"Samuel Teixeira (Teste)","D":"2014-03-03","E":"","G":"Normal","H":"Biguaçu","J":"Comercial Leads","K":"7097.31","P":"Comissão Leads","commissionType":"Comissão Leads","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"80.00","healthMembers":[],"_demo":true,"CU":"Consultor de leads","F":"1985-06-26"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-138' AND registration='990138') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-139','990139',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-139','2026-09','{"B":"990139","C":"Tatiana Teixeira (Teste)","D":"2015-04-04","E":"","G":"Normal","H":"Campeche","J":"Relacionamento","K":"7130.87","P":"Comissão Relacionamento","commissionType":"Comissão Relacionamento","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de relacionamento","F":"1986-07-27"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-139' AND registration='990139') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-140','990140',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-140','2026-09','{"B":"990140","C":"Vinícius Teixeira (Teste)","D":"2016-05-05","E":"","G":"Normal","H":"Centro","J":"Manutenção","K":"7164.42","P":"Comissão Manutenção","commissionType":"Comissão Manutenção","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico de manutenção","F":"1987-08-28"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-140' AND registration='990140') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-141','990141',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-141','2026-09','{"B":"990141","C":"Amanda Teixeira (Teste)","D":"2017-06-06","E":"","G":"Normal","H":"Ingleses","J":"Manutenção Externa","K":"7197.98","P":"Comissão Condominio Manutenção","commissionType":"Comissão Condominio Manutenção","receivesVA":false,"chargeSerefi":true,"receivesPericulosidade":true,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Técnico externo","F":"1988-09-01"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-141' AND registration='990141') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-142','990142',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-142','2026-09','{"B":"990142","C":"Caio Teixeira (Teste)","D":"2018-07-07","E":"","G":"Normal","H":"Kobrasol","J":"Agente de Visitas","K":"7231.54","P":"Comissão Agente de Visita","commissionType":"Comissão Agente de Visita","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Agente de visitas","F":"1989-10-02"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-142' AND registration='990142') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-143','990143',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-143','2026-09','{"B":"990143","C":"Débora Teixeira (Teste)","D":"2019-08-08","E":"","G":"Normal","H":"Palhoça","J":"Contratos Comercial","K":"7265.10","P":"Premiação - Contratos","commissionType":"Premiação - Contratos","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de contratos","F":"1990-11-03"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-143' AND registration='990143') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-144','990144',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-144','2026-09','{"B":"990144","C":"Enzo Teixeira (Teste)","D":"2020-09-09","E":"","G":"Normal","H":"Trindade","J":"Locação","K":"7298.65","P":"Comissão Taxa Intermediação","commissionType":"Comissão Taxa Intermediação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Consultor de locação","F":"1991-12-04"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-144' AND registration='990144') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-145','990145',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-145','2026-09','{"B":"990145","C":"Fernanda Teixeira (Teste)","D":"2021-01-10","E":"","G":"Normal","H":"Matriz","J":"Renovações","K":"7332.21","P":"Taxa de Intermediação Reajuste Real","commissionType":"Taxa de Intermediação Reajuste Real","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de renovações","F":"1980-01-05"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-145' AND registration='990145') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-146','990146',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-146','2026-09','{"B":"990146","C":"Gustavo Teixeira (Teste)","D":"2022-02-11","E":"","G":"Normal","H":"Biguaçu","J":"Qualidade","K":"7365.77","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Analista de qualidade","F":"1981-02-06"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-146' AND registration='990146') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-147','990147',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-147','2026-09','{"B":"990147","C":"Helena Teixeira (Teste)","D":"2023-03-12","E":"","G":"Normal","H":"Campeche","J":"Vistoria Ocupação","K":"7399.32","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador","F":"1982-03-07"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-147' AND registration='990147') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-148','990148',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-148','2026-09','{"B":"990148","C":"Igor Teixeira (Teste)","D":"2024-04-13","E":"","G":"Normal","H":"Centro","J":"Vistoria Desocupação","K":"7432.88","P":"Premiação","commissionType":"Premiação","receivesVA":true,"chargeSerefi":false,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Vistoriador de saída","F":"1983-04-08"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-148' AND registration='990148') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-149','990149',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-149','2026-09','{"B":"990149","C":"Juliana Teixeira (Teste)","D":"2025-05-14","E":"","G":"Normal","H":"Ingleses","J":"Seguro","K":"7466.44","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"0.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Assistente de seguros","F":"1984-05-09"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-149' AND registration='990149') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO employees(id,registration,active) VALUES('ibagy-teste-150','990150',1) ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO versions(employee,month,data) SELECT 'ibagy-teste-150','2026-09','{"B":"990150","C":"Leonardo Teixeira (Teste)","D":"2026-06-15","E":"","G":"Normal","H":"Kobrasol","J":"Limpeza","K":"7500.00","P":"","commissionType":"","receivesVA":true,"chargeSerefi":true,"receivesPericulosidade":false,"extraCaixa":"0.00","extraInsalubridade":"150.00","extraTeletrabalho":"0.00","healthMembers":[],"_demo":true,"CU":"Auxiliar de limpeza","F":"1985-06-10"}' WHERE EXISTS(SELECT 1 FROM employees WHERE id='ibagy-teste-150' AND registration='990150') ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO audit(id,month,action,actor,created,detail) VALUES('seed-150-ibagy-2026-09','2026-09','150 colaboradores fictícios cadastrados','Sistema',strftime('%Y-%m-%dT%H:%M:%fZ','now'),'{"count":150,"synthetic":true}') ON CONFLICT DO NOTHING;
