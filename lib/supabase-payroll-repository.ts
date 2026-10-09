import 'server-only';
import {supabaseAdminRequest} from './supabase-admin';

/**
 * Repositório PostgreSQL/Supabase da migração v77.
 * Uso exclusivo em rotas de servidor que já verificaram a sessão e permissão.
 * Não criar endpoints públicos que chamem estas funções diretamente.
 */
export type EmployeeRow = { id: string; registration: string; active: number };
export type PeriodRow = { month: string; status: string; commission_status: string };
export type PayrollRecordRow = { month: string; employee: string; data: string; revision: number };

function monthParam(month: string): string {
  if (!/^\d{4}-(0[1-9]|1[0-2])$/.test(month)) throw new Error('Competência inválida');
  return encodeURIComponent(month);
}

function idParam(id: string): string {
  if (!id || id.length > 120 || /[\u0000-\u001f]/.test(id)) throw new Error('Identificador inválido');
  return encodeURIComponent(id);
}

export async function listEmployees(): Promise<EmployeeRow[]> {
  return supabaseAdminRequest<EmployeeRow[]>('/rest/v1/employees?select=id,registration,active&order=registration.asc');
}

export async function findEmployee(id: string): Promise<EmployeeRow | null> {
  const rows = await supabaseAdminRequest<EmployeeRow[]>(
    `/rest/v1/employees?select=id,registration,active&id=eq.${idParam(id)}&limit=1`,
  );
  return rows[0] ?? null;
}

export async function listPeriods(): Promise<PeriodRow[]> {
  return supabaseAdminRequest<PeriodRow[]>('/rest/v1/periods?select=month,status,commission_status&order=month.desc');
}

export async function listPayrollRecords(month: string): Promise<PayrollRecordRow[]> {
  return supabaseAdminRequest<PayrollRecordRow[]>(
    `/rest/v1/records?select=month,employee,data,revision&month=eq.${monthParam(month)}&order=employee.asc`,
  );
}

export async function findPayrollRecord(month: string, employeeId: string): Promise<PayrollRecordRow | null> {
  const rows = await supabaseAdminRequest<PayrollRecordRow[]>(
    `/rest/v1/records?select=month,employee,data,revision&month=eq.${monthParam(month)}&employee=eq.${idParam(employeeId)}&limit=1`,
  );
  return rows[0] ?? null;
}

/**
 * Escritas opt-in: apenas chamadas internas após autenticação/autorização.
 * O registro de folha exige competência previamente cadastrada e colaborador existente.
 * O conflito de versão impede sobrescrever alterações concorrentes.
 */
export async function createEmployee(employee: EmployeeRow): Promise<EmployeeRow> {
  if (!employee.id || !employee.registration || ![0, 1].includes(employee.active)) {
    throw new Error('Dados do colaborador inválidos');
  }
  const rows = await supabaseAdminRequest<EmployeeRow[]>('/rest/v1/employees?select=id,registration,active', {
    method: 'POST',
    body: employee,
    prefer: 'return=representation',
  });
  if (rows.length !== 1) throw new Error('Não foi possível cadastrar o colaborador');
  return rows[0];
}

export async function createPeriod(month: string): Promise<PeriodRow> {
  const rows = await supabaseAdminRequest<PeriodRow[]>('/rest/v1/periods?select=month,status,commission_status', {
    method: 'POST',
    body: {month: monthParam(month)},
    prefer: 'return=representation',
  });
  if (rows.length !== 1) throw new Error('Não foi possível cadastrar a competência');
  return rows[0];
}

export async function createPayrollRecord(record: PayrollRecordRow): Promise<PayrollRecordRow> {
  monthParam(record.month);
  idParam(record.employee);
  if (!Number.isInteger(record.revision) || record.revision !== 1 || typeof record.data !== 'string') {
    throw new Error('Registro de folha inválido');
  }
  const rows = await supabaseAdminRequest<PayrollRecordRow[]>('/rest/v1/records?select=month,employee,data,revision', {
    method: 'POST',
    body: record,
    prefer: 'return=representation',
  });
  if (rows.length !== 1) throw new Error('Não foi possível cadastrar o lançamento');
  return rows[0];
}

export async function updatePayrollRecord(
  month: string,
  employeeId: string,
  data: string,
  expectedRevision: number,
): Promise<PayrollRecordRow> {
  if (!Number.isInteger(expectedRevision) || expectedRevision < 1 || typeof data !== 'string') {
    throw new Error('Revisão ou dados inválidos');
  }
  const rows = await supabaseAdminRequest<PayrollRecordRow[]>(
    `/rest/v1/records?select=month,employee,data,revision&month=eq.${monthParam(month)}&employee=eq.${idParam(employeeId)}&revision=eq.${expectedRevision}`,
    {
      method: 'PATCH',
      body: {data, revision: expectedRevision + 1},
      prefer: 'return=representation',
    },
  );
  if (rows.length !== 1) throw new Error('Conflito de revisão: recarregue o lançamento antes de salvar');
  return rows[0];
}
