import { supabaseBrowser as supabase } from './supabaseBrowser';

export type ColType = 'text' | 'textarea' | 'number' | 'boolean' | 'json' | 'select' | 'region-stock';

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
  mount?: string; // selector del contenedor — por defecto '#table'
  newRowDefaults?: Record<string, any>;
  labelSingular?: string;
  /** Campo que se muestra como título en la fila colapsada. Si no se indica, se detecta automáticamente. */
  titleKey?: string;
  /** Campo que se muestra como subtítulo (chip) en la fila colapsada. */
  subtitleKey?: string;
  /** Campo con una URL de imagen para la miniatura de la fila colapsada. */
  imageKey?: string;
  /** Cuántas filas mostrar antes de "Cargar más". Por defecto 20. */
  pageSize?: number;
}

// ── Utilidades ───────────────────────────────────────────────────────────────
function esc(v: any): string {
  if (v === null || v === undefined) return '';
  return String(v).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');
}

function truncate(s: string, n: number): string {
  const str = String(s ?? '');
  return str.length > n ? str.slice(0, n - 1) + '…' : str;
}

// ── Iconos (SVG inline, sin dependencias ni emojis) ──────────────────────────
const ICO = {
  chevron: `<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0 transition-transform" aria-hidden="true"><path d="M6 8l4 4 4-4" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  trash: `<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.6" class="h-3.5 w-3.5" aria-hidden="true"><path d="M4 6h12M8 6V4.5A1.5 1.5 0 0 1 9.5 3h1A1.5 1.5 0 0 1 12 4.5V6m2 0v9a1.5 1.5 0 0 1-1.5 1.5h-5A1.5 1.5 0 0 1 6 15V6h8Z" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  save: `<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" class="h-3.5 w-3.5" aria-hidden="true"><path d="M4 10.5 8 14l8-8" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  plus: `<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4" aria-hidden="true"><path d="M10 4v12M4 10h12" stroke-linecap="round"/></svg>`,
  search: `<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" class="h-4 w-4" aria-hidden="true"><circle cx="9" cy="9" r="6"/><path d="m17 17-4-4" stroke-linecap="round"/></svg>`,
  image: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="h-5 w-5" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="3"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="m21 15-5-5L5 21" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
};

// ── Campos de edición ─────────────────────────────────────────────────────────
function inputFor(col: ColumnDef, value: any, ariaCtx: string): string {
  const base =
    'w-full rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-sm text-ink focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent';
  if (col.type === 'boolean') {
    return `<label class="relative inline-flex cursor-pointer items-center" aria-label="${esc(col.label)} — ${esc(ariaCtx)}">
      <input type="checkbox" data-field="${col.key}" ${value ? 'checked' : ''} class="peer sr-only" />
      <span class="h-6 w-11 rounded-full bg-slate-200 transition-colors peer-checked:bg-accent peer-focus-visible:ring-2 peer-focus-visible:ring-accent peer-focus-visible:ring-offset-2"></span>
      <span class="pointer-events-none absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform peer-checked:translate-x-5"></span>
    </label>`;
  }
  if (col.type === 'textarea' || col.type === 'json') {
    const v = col.type === 'json' ? JSON.stringify(value ?? (Array.isArray(value) ? [] : {}), null, 0) : (value ?? '');
    return `<textarea data-field="${col.key}" rows="3" placeholder="${esc(col.placeholder)}" aria-label="${esc(col.label)}" class="${base} font-mono text-xs leading-relaxed">${esc(v)}</textarea>`;
  }
  if (col.type === 'select' && col.options) {
    const opts = col.options
      .map((o) => `<option value="${esc(o)}" ${o === value ? 'selected' : ''}>${esc(o)}</option>`)
      .join('');
    return `<select data-field="${col.key}" aria-label="${esc(col.label)}" class="${base}">${opts}</select>`;
  }
  if (col.type === 'number') {
    return `<input type="number" step="any" data-field="${col.key}" value="${esc(value)}" placeholder="${esc(col.placeholder)}" aria-label="${esc(col.label)}" class="${base}" />`;
  }
  return `<input type="text" data-field="${col.key}" value="${esc(value)}" placeholder="${esc(col.placeholder)}" aria-label="${esc(col.label)}" class="${base}" />`;
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

const STOCK_LABELS: Record<string, string> = { available: 'Disponible', limited: 'Limitado', out: 'Agotado' };

/** Widget compuesto: checkbox por región + estado de stock. Escribe a la vez `regions` (array) y `stock` (objeto). */
function regionStockWidget(row: Record<string, any>, regionsList: { id: string; name: string }[]): string {
  const currentRegions: string[] = Array.isArray(row.regions) ? row.regions : [];
  const currentStock: Record<string, string> = row.stock && typeof row.stock === 'object' ? row.stock : {};
  const rows = regionsList
    .map((r) => {
      const included = currentRegions.includes(r.id);
      const st = currentStock[r.id] ?? 'available';
      const options = Object.entries(STOCK_LABELS)
        .map(([v, l]) => `<option value="${v}" ${v === st ? 'selected' : ''}>${l}</option>`)
        .join('');
      return `<div class="flex items-center gap-2 py-1" data-region-row="${esc(r.id)}">
        <input type="checkbox" data-region-check="${esc(r.id)}" ${included ? 'checked' : ''} class="h-4 w-4 rounded border-slate-300 text-accent focus:ring-accent" />
        <span class="flex-1 text-sm text-ink">${esc(r.name)}</span>
        <select data-region-status="${esc(r.id)}" class="rounded-md border border-slate-200 bg-white px-2 py-1 text-xs focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent" ${included ? '' : 'disabled'}>${options}</select>
      </div>`;
    })
    .join('');
  return `<div class="rounded-lg border border-slate-200 p-2.5">${rows || '<p class="text-xs text-slate-400">No hay regiones creadas todavía en Regiones VPS.</p>'}</div>`;
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

// Prioridad para auto-detectar qué booleanos mostrar como chip rápido en la fila colapsada.
const QUICK_TOGGLE_PRIORITY = ['published', 'active', 'featured', 'popular'];

export function mountAdminTable(cfg: AdminTableConfig) {
  const mountSelector = cfg.mount || '#table';
  const mountEl = document.querySelector<HTMLElement>(mountSelector);
  if (!mountEl) {
    console.error(`mountAdminTable: no se encontró "${mountSelector}" en la página. Revisa el <div id="table"> y el selector "mount".`);
    return;
  }
  const orderBy = cfg.orderBy ?? (cfg.columns.some((c) => c.key === 'sort_order') ? 'sort_order' : cfg.pk);
  const label = cfg.labelSingular ?? 'registro';
  const needsRegions = cfg.columns.some((c) => c.type === 'region-stock');
  const pageSize = cfg.pageSize ?? 20;
  let regionsList: { id: string; name: string }[] = [];

  // Detección automática de qué columna usar como título/subtítulo si no se configuró.
  const textCols = cfg.columns.filter((c) => c.type === 'text' && c.key !== cfg.pk);
  const titleKey =
    cfg.titleKey ?? textCols.find((c) => /^(title|name|nombre)$/i.test(c.key))?.key ?? textCols[0]?.key ?? cfg.pk;
  const subtitleKey =
    cfg.subtitleKey ?? textCols.find((c) => c.key !== titleKey && /^(category|categoria|price|precio|tagline)$/i.test(c.key))?.key;
  const quickToggleCols = cfg.columns.filter((c) => c.type === 'boolean' && QUICK_TOGGLE_PRIORITY.includes(c.key));

  let allRows: Record<string, any>[] = [];
  let searchTerm = '';
  let visibleCount = pageSize;
  const expandedKeys = new Set<string>();

  function skeleton() {
    mountEl!.innerHTML = `
      <div class="space-y-2.5">
        ${[0, 1, 2, 3]
          .map(
            () => `<div class="animate-pulse rounded-xl border border-slate-200 bg-white p-4">
              <div class="flex items-center gap-3">
                <div class="h-11 w-11 rounded-lg bg-slate-100"></div>
                <div class="flex-1 space-y-2">
                  <div class="h-3 w-1/3 rounded bg-slate-100"></div>
                  <div class="h-2.5 w-1/5 rounded bg-slate-100"></div>
                </div>
              </div>
            </div>`
          )
          .join('')}
      </div>`;
  }

  async function load() {
    skeleton();
    if (needsRegions && regionsList.length === 0) {
      const { data: regionsData } = await supabase.from('vps_regions').select('id,name').order('sort_order', { ascending: true });
      regionsList = regionsData ?? [];
    }
    const { data, error } = await supabase.from(cfg.table).select('*').order(orderBy, { ascending: true });
    if (error) {
      mountEl!.innerHTML = `<div class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700">Error cargando datos: ${esc(error.message)}</div>`;
      return;
    }
    allRows = data ?? [];
    render();
  }

  function matchesSearch(row: Record<string, any>, term: string): boolean {
    if (!term) return true;
    const t = term.toLowerCase();
    return cfg.columns
      .filter((c) => c.type === 'text' || c.type === 'select')
      .some((c) => String(row[c.key] ?? '').toLowerCase().includes(t));
  }

  function render() {
    const filtered = allRows.filter((r) => matchesSearch(r, searchTerm));
    const shown = filtered.slice(0, visibleCount);
    const hasMore = filtered.length > shown.length;

    const toolbar = `
      <div class="sticky top-0 z-10 -mx-1 mb-3 flex flex-wrap items-center gap-2.5 bg-surface/95 px-1 py-2 backdrop-blur">
        <div class="relative flex-1 min-w-[200px]">
          <span class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">${ICO.search}</span>
          <input
            id="admin-search"
            type="search"
            value="${esc(searchTerm)}"
            placeholder="Buscar ${esc(label)}…"
            aria-label="Buscar ${esc(label)}"
            class="w-full rounded-lg border border-slate-200 bg-white py-2 pl-9 pr-3 text-sm text-ink placeholder:text-slate-400 focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent"
          />
        </div>
        <p class="text-xs text-slate-400 whitespace-nowrap">${filtered.length} ${label}(s)${searchTerm ? ` de ${allRows.length}` : ''}</p>
        <button data-action="add" class="flex h-9 shrink-0 items-center gap-1.5 rounded-lg bg-ink px-3.5 text-xs font-semibold text-white hover:bg-ink-2">
          ${ICO.plus}<span>Agregar</span>
        </button>
      </div>`;

    const cards = shown
      .map((row) => {
        const pkVal = String(row[cfg.pk]);
        const isOpen = expandedKeys.has(pkVal);
        const rowTitle = truncate(row[titleKey] ?? pkVal, 70) || '(sin título)';
        const rowSubtitle = subtitleKey ? row[subtitleKey] : null;
        const img = cfg.imageKey ? row[cfg.imageKey] : null;

        const thumb = cfg.imageKey
          ? img
            ? `<img src="${esc(img)}" alt="" class="h-11 w-11 shrink-0 rounded-lg object-cover" loading="lazy" />`
            : `<div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-300">${ICO.image}</div>`
          : '';

        const chips = quickToggleCols
          .map((c) => {
            const on = !!row[c.key];
            return `<button
              type="button"
              data-quick-toggle="${c.key}"
              aria-pressed="${on}"
              aria-label="${esc(c.label)} — ${esc(rowTitle)}"
              class="rounded-full border px-2 py-0.5 text-[11px] font-medium transition-colors ${on ? 'border-accent/30 bg-accent-soft text-accent' : 'border-slate-200 bg-white text-slate-400 hover:border-slate-300'}"
            >${esc(c.label)}</button>`;
          })
          .join('');

        const fields = cfg.columns
          .map((c) => {
            const wide = c.type === 'json' || c.type === 'textarea' || c.type === 'region-stock';
            const widget = c.type === 'region-stock' ? regionStockWidget(row, regionsList) : inputFor(c, row[c.key], rowTitle);
            return `<div class="${wide ? 'col-span-full' : ''}">
              <label class="mb-1 block text-[11px] font-semibold uppercase tracking-wide text-slate-400">${esc(c.label)}</label>
              ${widget}
            </div>`;
          })
          .join('');

        return `<div data-row-pk="${esc(pkVal)}" class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-card transition-shadow hover:shadow-card-hover">
          <button type="button" data-action="toggle-row" class="flex w-full items-center gap-3 px-4 py-3 text-left">
            ${thumb}
            <div class="min-w-0 flex-1">
              <div class="flex flex-wrap items-center gap-2">
                <span class="truncate font-display text-sm font-semibold text-ink">${esc(rowTitle)}</span>
                ${rowSubtitle ? `<span class="shrink-0 rounded-full bg-slate-100 px-2 py-0.5 text-[11px] text-slate-500">${esc(rowSubtitle)}</span>` : ''}
              </div>
              ${chips ? `<div class="mt-1.5 flex flex-wrap gap-1.5">${chips}</div>` : ''}
            </div>
            <span class="shrink-0 text-slate-400 ${isOpen ? 'rotate-180' : ''}">${ICO.chevron}</span>
          </button>
          <div class="${isOpen ? '' : 'hidden'} border-t border-slate-100 bg-slate-50/60 p-4" data-row-editor>
            <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">${fields}</div>
            <div class="mt-4 flex justify-end gap-2 border-t border-slate-200 pt-3">
              <button data-action="delete" class="flex h-9 items-center gap-1.5 rounded-md border border-red-200 px-3 text-xs font-semibold text-red-600 hover:bg-red-50">
                ${ICO.trash}<span>Eliminar</span>
              </button>
              <button data-action="save" class="flex h-9 items-center gap-1.5 rounded-md bg-accent px-4 text-xs font-semibold text-white hover:bg-accent-hover">
                ${ICO.save}<span>Guardar</span>
              </button>
            </div>
          </div>
        </div>`;
      })
      .join('');

    const emptyState = allRows.length === 0
      ? `<div class="rounded-xl border border-dashed border-slate-200 p-8 text-center text-sm text-slate-400">Sin registros todavía.</div>`
      : `<div class="rounded-xl border border-dashed border-slate-200 p-8 text-center text-sm text-slate-400">No se encontraron resultados para “${esc(searchTerm)}”.</div>`;

    const loadMore = hasMore
      ? `<div class="pt-1"><button data-action="load-more" class="w-full rounded-lg border border-slate-200 bg-white py-2.5 text-xs font-semibold text-slate-500 hover:border-accent/40 hover:text-accent">Cargar más (${filtered.length - shown.length} restantes)</button></div>`
      : '';

    mountEl!.innerHTML = `
      ${toolbar}
      <div class="space-y-2.5">
        ${shown.length ? cards : emptyState}
        ${loadMore}
      </div>
    `;

    // Búsqueda (debounce ligero + preserva foco/cursor tras el re-render)
    const searchInput = mountEl!.querySelector<HTMLInputElement>('#admin-search');
    searchInput?.addEventListener('input', () => {
      searchTerm = searchInput.value;
      const caret = searchInput.selectionStart ?? searchTerm.length;
      visibleCount = pageSize;
      render();
      const freshInput = mountEl!.querySelector<HTMLInputElement>('#admin-search');
      freshInput?.focus();
      freshInput?.setSelectionRange(caret, caret);
    });

    mountEl!.querySelector('[data-action="load-more"]')?.addEventListener('click', () => {
      visibleCount += pageSize;
      render();
    });

    mountEl!.querySelector('[data-action="add"]')?.addEventListener('click', async () => {
      const pkVal = prompt(`ID único para el nuevo ${label} ("${cfg.pk}"):`);
      if (!pkVal) return;
      const payload: Record<string, any> = { [cfg.pk]: pkVal, ...(cfg.newRowDefaults ?? {}) };
      const { error } = await supabase.from(cfg.table).insert(payload);
      if (error) {
        alert('Error creando registro: ' + error.message);
        return;
      }
      expandedKeys.add(pkVal);
      load();
    });

    mountEl!.querySelectorAll<HTMLElement>('[data-row-pk]').forEach((card) => {
      const pkVal = card.dataset.rowPk!;
      const rowData = allRows.find((r) => String(r[cfg.pk]) === pkVal)!;

      card.querySelector('[data-action="toggle-row"]')?.addEventListener('click', () => {
        if (expandedKeys.has(pkVal)) expandedKeys.delete(pkVal);
        else expandedKeys.add(pkVal);
        render();
      });

      // Chips de acceso rápido: togglean y guardan un booleano al instante sin abrir el editor.
      card.querySelectorAll<HTMLButtonElement>('[data-quick-toggle]').forEach((chip) => {
        chip.addEventListener('click', async (e) => {
          e.stopPropagation();
          const key = chip.dataset.quickToggle!;
          const newVal = !rowData[key];
          chip.disabled = true;
          const { error } = await supabase.from(cfg.table).update({ [key]: newVal }).eq(cfg.pk, rowData[cfg.pk]);
          chip.disabled = false;
          if (error) {
            status(mountEl!, error.message, 'err');
            return;
          }
          rowData[key] = newVal;
          render();
          status(mountEl!, 'Guardado ✓', 'ok');
        });
      });

      const editor = card.querySelector<HTMLElement>('[data-row-editor]');
      if (!editor) return;

      editor.querySelectorAll<HTMLInputElement>('[data-region-check]').forEach((chk) => {
        chk.addEventListener('change', () => {
          const sel = editor.querySelector<HTMLSelectElement>(`[data-region-status="${chk.dataset.regionCheck}"]`);
          if (sel) sel.disabled = !chk.checked;
        });
      });

      editor.querySelector('[data-action="save"]')?.addEventListener('click', async (e) => {
        e.stopPropagation();
        try {
          const payload: Record<string, any> = {};
          cfg.columns.forEach((c) => {
            if (c.type === 'region-stock') {
              const regions: string[] = [];
              const stock: Record<string, string> = {};
              editor.querySelectorAll<HTMLInputElement>('[data-region-check]').forEach((chk) => {
                const id = chk.dataset.regionCheck!;
                if (chk.checked) {
                  regions.push(id);
                  const sel = editor.querySelector<HTMLSelectElement>(`[data-region-status="${id}"]`);
                  stock[id] = sel?.value ?? 'available';
                }
              });
              payload.regions = regions;
              payload[c.key] = stock;
              return;
            }
            const el = editor.querySelector<HTMLElement>(`[data-field="${c.key}"]`);
            if (el) payload[c.key] = readValue(el, c);
          });
          const { error } = await supabase.from(cfg.table).update(payload).eq(cfg.pk, rowData[cfg.pk]);
          if (error) throw error;
          Object.assign(rowData, payload);
          status(mountEl!, 'Guardado ✓', 'ok');
        } catch (e: any) {
          status(mountEl!, e.message ?? 'Error al guardar', 'err');
        }
      });

      editor.querySelector('[data-action="delete"]')?.addEventListener('click', async (e) => {
        e.stopPropagation();
        if (!confirm(`¿Eliminar este ${label}? Esta acción no se puede deshacer.`)) return;
        const { error } = await supabase.from(cfg.table).delete().eq(cfg.pk, rowData[cfg.pk]);
        if (error) {
          status(mountEl!, error.message, 'err');
          return;
        }
        expandedKeys.delete(pkVal);
        load();
      });
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
  if (!mountEl) {
    console.error(`mountSingletonForm: no se encontró "${opts.mount}" en la página.`);
    return;
  }

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
