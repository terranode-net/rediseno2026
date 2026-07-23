import { supabaseBrowser as supabase } from './supabaseBrowser';

export type ColType = 'text' | 'textarea' | 'number' | 'boolean' | 'json' | 'select';

export interface ColumnDef {
  key: string;
  label: string;
  type: ColType;
  options?: string[]; // para type 'select'
  placeholder?: string;
  width?: string; // ej. 'w-24'
}

export interface AdminTableConfig {
  table: string;
  pk: string;
  columns: ColumnDef[];
  orderBy?: string; // default 'sort_order'
  mount: string; // selector del contenedor
  newRowDefaults?: Record<string, any>;
  labelSingular?: string;
}

function esc(v: any): string {
  if (v === null || v === undefined) return '';
  return String(v).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');
}

function inputFor(col: ColumnDef, value: any, rowKey: string): string {
  const name = `f_${col.key}`;
  const base =
    'w-full rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-sm text-ink focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent';
  if (col.type === 'boolean') {
    return `<input type="checkbox" data-field="${col.key}" ${value ? 'checked' : ''} class="h-4 w-4 rounded border-slate-300 text-accent focus:ring-accent" />`;
  }
  if (col.type === 'textarea' || col.type === 'json') {
    const v = col.type === 'json' ? JSON.stringify(value ?? (Array.isArray(value) ? [] : {}), null, 0) : (value ?? '');
    return `<textarea data-field="${col.key}" rows="2" placeholder="${esc(col.placeholder)}" class="${base} font-mono text-xs">${esc(v)}</textarea>`;
  }
  if (col.type === 'select' && col.options) {
    const opts = col.options
      .map((o) => `<option value="${esc(o)}" ${o === value ? 'selected' : ''}>${esc(o)}</option>`)
      .join('');
    return `<select data-field="${col.key}" class="${base}">${opts}</select>`;
  }
  if (col.type === 'number') {
    return `<input type="number" step="any" data-field="${col.key}" value="${esc(value)}" placeholder="${esc(col.placeholder)}" class="${base}" />`;
  }
  return `<input type="text" data-field="${col.key}" value="${esc(value)}" placeholder="${esc(col.placeholder)}" class="${base}" />`;
}

function readValue(el: HTMLElement, col: ColumnDef): any {
  if (col.type === 'boolean') return (el as HTMLInputElement).checked;
  if (col.type === 'number') {
    const v = (el as HTMLInputElement).value;
    return v === '' ? null : Number(v);
  }
  if (col.type === 'json') {
    const raw = (el as HTMLTextAreaElement).value.trim();
    if (!raw) return col.key.match(/stock|feats$|data$/) ? {} : [];
    try {
      return JSON.parse(raw);
    } catch {
      throw new Error(`JSON inválido en "${col.label}"`);
    }
  }
  return (el as HTMLInputElement | HTMLTextAreaElement).value;
}

function status(mountEl: HTMLElement, msg: string, kind: 'ok' | 'err' | 'info' = 'info') {
  let bar = mountEl.querySelector<HTMLDivElement>('.admin-status');
  if (!bar) {
    bar = document.createElement('div');
    bar.className = 'admin-status mb-4 rounded-lg px-3 py-2 text-sm';
    mountEl.prepend(bar);
  }
  const colors =
    kind === 'ok'
      ? 'bg-signal-soft text-signal border border-signal/30'
      : kind === 'err'
        ? 'bg-red-50 text-red-700 border border-red-200'
        : 'bg-accent-soft text-accent border border-accent/20';
  bar.className = `admin-status mb-4 rounded-lg px-3 py-2 text-sm ${colors}`;
  bar.textContent = msg;
  if (kind !== 'err') setTimeout(() => bar && bar.remove(), 2500);
}

export function mountAdminTable(cfg: AdminTableConfig) {
  const mountEl = document.querySelector<HTMLElement>(cfg.mount);
  if (!mountEl) return;
  const orderBy = cfg.orderBy ?? (cfg.columns.some((c) => c.key === 'sort_order') ? 'sort_order' : cfg.pk);
  const label = cfg.labelSingular ?? 'registro';

  async function load() {
    mountEl!.innerHTML = '<p class="text-sm text-slate-400">Cargando…</p>';
    const { data, error } = await supabase.from(cfg.table).select('*').order(orderBy, { ascending: true });
    if (error) {
      mountEl!.innerHTML = `<div class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700">Error cargando datos: ${esc(error.message)}</div>`;
      return;
    }
    render(data ?? []);
  }

  function render(rows: Record<string, any>[]) {
    const head = cfg.columns.map((c) => `<th class="px-2 py-2 text-left text-xs font-semibold uppercase tracking-wide text-slate-400">${esc(c.label)}</th>`).join('');
    const body = rows
      .map((row, i) => {
        const cells = cfg.columns
          .map((c) => `<td class="px-2 py-1.5 align-top ${c.width ?? ''}">${inputFor(c, row[c.key], String(row[cfg.pk]))}</td>`)
          .join('');
        return `<tr data-row="${i}" data-pk="${esc(row[cfg.pk])}" class="border-b border-slate-100 hover:bg-surface/60">
          ${cells}
          <td class="whitespace-nowrap px-2 py-1.5 text-right align-top">
            <button data-action="save" class="rounded-md bg-accent px-3 py-1.5 text-xs font-semibold text-white hover:bg-accent-hover">Guardar</button>
            <button data-action="delete" class="ml-1 rounded-md border border-red-200 px-3 py-1.5 text-xs font-semibold text-red-600 hover:bg-red-50">Eliminar</button>
          </td>
        </tr>`;
      })
      .join('');

    mountEl!.innerHTML = `
      <div class="mb-3 flex items-center justify-between">
        <p class="text-sm text-slate-500">${rows.length} ${label}(s)</p>
        <button data-action="add" class="rounded-md bg-ink px-3 py-1.5 text-xs font-semibold text-white hover:bg-ink-2">+ Agregar ${esc(label)}</button>
      </div>
      <div class="overflow-x-auto rounded-xl border border-slate-200 bg-white">
        <table class="w-full border-collapse">
          <thead><tr class="bg-surface">${head}<th></th></tr></thead>
          <tbody>${body || `<tr><td class="p-4 text-sm text-slate-400" colspan="${cfg.columns.length + 1}">Sin registros todavía.</td></tr>`}</tbody>
        </table>
      </div>
    `;

    mountEl!.querySelectorAll('tr[data-row]').forEach((tr) => {
      const rowIndex = Number((tr as HTMLElement).dataset.row);
      const rowData = rows[rowIndex];

      tr.querySelector('[data-action="save"]')?.addEventListener('click', async () => {
        try {
          const payload: Record<string, any> = {};
          cfg.columns.forEach((c) => {
            const el = tr.querySelector<HTMLElement>(`[data-field="${c.key}"]`);
            if (el) payload[c.key] = readValue(el, c);
          });
          const { error } = await supabase.from(cfg.table).update(payload).eq(cfg.pk, rowData[cfg.pk]);
          if (error) throw error;
          status(mountEl!, 'Guardado ✓', 'ok');
        } catch (e: any) {
          status(mountEl!, e.message ?? 'Error al guardar', 'err');
        }
      });

      tr.querySelector('[data-action="delete"]')?.addEventListener('click', async () => {
        if (!confirm(`¿Eliminar este ${label}? Esta acción no se puede deshacer.`)) return;
        const { error } = await supabase.from(cfg.table).delete().eq(cfg.pk, rowData[cfg.pk]);
        if (error) {
          status(mountEl!, error.message, 'err');
          return;
        }
        load();
      });
    });

    mountEl!.querySelector('[data-action="add"]')?.addEventListener('click', async () => {
      const pkVal = prompt(`ID único para el nuevo ${label} (clave primaria "${cfg.pk}"):`);
      if (!pkVal) return;
      const payload: Record<string, any> = { [cfg.pk]: pkVal, ...(cfg.newRowDefaults ?? {}) };
      const { error } = await supabase.from(cfg.table).insert(payload);
      if (error) {
        alert('Error creando registro: ' + error.message);
        return;
      }
      load();
    });
  }

  load();
}

/** Para tablas "singleton" (una sola fila con una columna jsonb `data`), ej. brand_settings. */
export function mountSingletonForm(opts: {
  table: string;
  mount: string;
  fields: { key: string; label: string; type?: 'text' | 'textarea' | 'password' }[];
}) {
  const mountEl = document.querySelector<HTMLElement>(opts.mount);
  if (!mountEl) return;

  async function load() {
    mountEl!.innerHTML = '<p class="text-sm text-slate-400">Cargando…</p>';
    const { data, error } = await supabase.from(opts.table).select('data').eq('id', 1).maybeSingle();
    if (error) {
      mountEl!.innerHTML = `<div class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700">${esc(error.message)}</div>`;
      return;
    }
    render((data?.data as Record<string, any>) ?? {});
  }

  function render(values: Record<string, any>) {
    const rows = opts.fields
      .map((f) => {
        const v = values[f.key] ?? '';
        const inputEl =
          f.type === 'textarea'
            ? `<textarea data-key="${f.key}" rows="3" class="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent">${esc(v)}</textarea>`
            : `<input type="${f.type === 'password' ? 'password' : 'text'}" data-key="${f.key}" value="${esc(v)}" class="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent" />`;
        return `<div><label class="mb-1 block text-xs font-semibold uppercase tracking-wide text-slate-400">${esc(f.label)}</label>${inputEl}</div>`;
      })
      .join('');

    mountEl!.innerHTML = `
      <div class="grid gap-4 sm:grid-cols-2">${rows}</div>
      <button data-action="save" class="mt-5 rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white hover:bg-accent-hover">Guardar cambios</button>
    `;

    mountEl!.querySelector('[data-action="save"]')?.addEventListener('click', async () => {
      const payload: Record<string, any> = {};
      opts.fields.forEach((f) => {
        const el = mountEl!.querySelector<HTMLInputElement | HTMLTextAreaElement>(`[data-key="${f.key}"]`);
        if (el) payload[f.key] = el.value;
      });
      const { error } = await supabase.from(opts.table).update({ data: payload }).eq('id', 1);
      status(mountEl!, error ? error.message : 'Guardado ✓', error ? 'err' : 'ok');
    });
  }

  load();
}
