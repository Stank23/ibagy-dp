import { sqliteTable,text,integer,primaryKey,index } from 'drizzle-orm/sqlite-core';
export const employees=sqliteTable('employees',{id:text('id').primaryKey(),registration:text('registration').notNull().unique(),active:integer('active').notNull().default(1)});
export const versions=sqliteTable('versions',{employee:text('employee').notNull().references(()=>employees.id),month:text('month').notNull(),data:text('data').notNull()},t=>[primaryKey({columns:[t.employee,t.month]})]);
export const periods=sqliteTable('periods',{month:text('month').primaryKey(),status:text('status').notNull().default('open'),commissionStatus:text('commission_status').notNull().default('open')});
export const records=sqliteTable('records',{month:text('month').notNull().references(()=>periods.month),employee:text('employee').notNull().references(()=>employees.id),data:text('data').notNull(),revision:integer('revision').notNull().default(1)},t=>[primaryKey({columns:[t.month,t.employee]}),index('idx_records_employee').on(t.employee)]);
export const files=sqliteTable('files',{id:text('id').primaryKey(),month:text('month').notNull().references(()=>periods.month),kind:text('kind').notNull(),name:text('name').notNull(),key:text('key').notNull(),created:text('created').notNull()},t=>[index('idx_files_month').on(t.month),index('idx_files_month_created').on(t.month,t.created)]);
export const audit=sqliteTable('audit',{id:text('id').primaryKey(),month:text('month').notNull(),action:text('action').notNull(),actor:text('actor').notNull(),created:text('created').notNull(),detail:text('detail').notNull()},t=>[index('idx_audit_month').on(t.month),index('idx_audit_month_created').on(t.month,t.created)]);
export const allowances=sqliteTable('allowances',{month:text('month').primaryKey(),amount:integer('amount').notNull()});
export const minimumWages=sqliteTable('minimum_wages',{month:text('month').primaryKey(),amount:integer('amount').notNull()});
export const loans=sqliteTable('loans',{id:text('id').primaryKey(),employee:text('employee').notNull().references(()=>employees.id),amount:integer('amount').notNull(),count:integer('count').notNull(),start:text('start').notNull(),end:text('end').notNull(),created:text('created').notNull()});
export const installments=sqliteTable('installments',{loan:text('loan').notNull().references(()=>loans.id),employee:text('employee').notNull().references(()=>employees.id),month:text('month').notNull(),number:integer('number').notNull(),principal:integer('principal').notNull(),fee:integer('fee').notNull(),amount:integer('amount').notNull()},t=>[primaryKey({columns:[t.loan,t.month]}),index('idx_installments_employee_month').on(t.employee,t.month),index('idx_installments_month_employee').on(t.month,t.employee)]);
export const administrators=sqliteTable('administrators',{accountId:text('account_id').primaryKey(),email:text('email').notNull().unique()});
export const appUsers=sqliteTable('app_users',{email:text('email').unique(),id:text('id').primaryKey(),username:text('username').notNull().unique(),name:text('name').notNull(),role:text('role').notNull(),salt:text('salt').notNull(),passwordHash:text('password_hash').notNull(),active:integer('active').notNull().default(1)});
export const appSessions=sqliteTable('app_sessions',{tokenHash:text('token_hash').primaryKey(),userId:text('user_id').notNull().references(()=>appUsers.id),expires:integer('expires').notNull()},t=>[index('app_sessions_user').on(t.userId)]);
export const appLoginAttempts=sqliteTable('app_login_attempts',{key:text('key').primaryKey(),failures:integer('failures').notNull(),since:integer('since').notNull()});

export const eventPlans=sqliteTable('event_plans',{id:text('id').primaryKey(),employee:text('employee').notNull().references(()=>employees.id),event:text('event').notNull(),amount:integer('amount').notNull(),count:integer('count').notNull(),start:text('start').notNull(),end:text('end').notNull(),created:text('created').notNull()},t=>[index('idx_event_plans_employee_start').on(t.employee,t.start),index('idx_event_plans_start_end').on(t.start,t.end)]);

export const normativeWages=sqliteTable('normative_wages',{month:text('month').primaryKey(),amount:integer('amount').notNull()});

export const childcareChildren=sqliteTable('childcare_children',{id:text('id').primaryKey(),employee:text('employee').notNull().references(()=>employees.id),childName:text('child_name').notNull(),birthDate:text('birth_date').notNull(),start:text('start').notNull(),lastCredit:text('last_credit').notNull(),revision:integer('revision').notNull().default(1),created:text('created').notNull()},t=>[index('idx_childcare_children_employee_start').on(t.employee,t.start)]);

export const dsrSettings=sqliteTable('dsr_settings',{writeId:text('write_id').notNull(),month:text('month').primaryKey(),useful:integer('useful').notNull(),rest:integer('rest').notNull(),revision:integer('revision').notNull().default(1)});

export const jobFunctions=sqliteTable('job_functions',{name:text('name').primaryKey(),key:text('key').notNull().unique()});

export const uniodontoRates=sqliteTable('uniodonto_rates',{month:text('month').primaryKey(),young:integer('young').notNull(),middle:integer('middle').notNull(),senior:integer('senior').notNull(),revision:integer('revision').notNull().default(1)});

export const unimedRates=sqliteTable('unimed_rates',{month:text('month').primaryKey(),young:integer('young').notNull(),middle:integer('middle').notNull(),senior:integer('senior').notNull(),revision:integer('revision').notNull().default(1)});
export const uniodontoFixedRates=sqliteTable('uniodonto_fixed_rates',{month:text('month').primaryKey(),amount:integer('amount').notNull(),revision:integer('revision').notNull().default(1)});
