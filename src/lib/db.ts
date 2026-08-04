// ============================================================================
// Capa de acceso a datos
// ----------------------------------------------------------------------------
// Cada función lee de Supabase y, si la base no responde (o aún no está
// sembrada), devuelve los datos por defecto que ya tenía el sitio. Así el
// sitio NUNCA se cae ni se queda sin precios por un fallo de la base de datos.
// ============================================================================
import { supabaseServer } from './supabaseServer';

// ── Tipos ───────────────────────────────────────────────────────────────────
export interface VpsRegion { id: string; name: string; country: string; ping: string; status: string }
export interface VpsPlan { id: string; name: string; cpu: string; ram: string; disk: string; bw: string; price: string; regions: string[]; stock: Record<string, string>; href: string; popular: boolean }
export interface City { slug: string; name: string; province: string; country: string; active: boolean }

// ── Fallbacks (los datos reales actuales del sitio) ─────────────────────────
const FALLBACK_REGIONS: VpsRegion[] = [
  { id: 'houston', name: 'Houston, TX', country: 'us', ping: '15ms', status: 'online' },
  { id: 'ashburn', name: 'Ashburn, VA', country: 'us', ping: '12ms', status: 'online' },
  { id: 'losangeles', name: 'Los Ángeles, CA', country: 'us', ping: '8ms', status: 'online' },
  { id: 'chicago', name: 'Chicago, IL', country: 'us', ping: '18ms', status: 'online' },
  { id: 'guayaquil', name: 'Guayaquil, EC', country: 'ec', ping: '3ms', status: 'online' },
];

const R4 = ['ashburn', 'losangeles', 'chicago', 'houston'];
const FALLBACK_VPS: VpsPlan[] = [
  { id: 'tns01', name: 'TNS-01', cpu: '1 vCPU', ram: '1 GB', disk: '25 GB NVMe', bw: '1 TB', price: '$2.99', regions: R4, stock: { ashburn: 'out', losangeles: 'out', chicago: 'out', houston: 'out' }, href: 'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-01', popular: false },
  { id: 'tns02', name: 'TNS-02', cpu: '1 vCPU', ram: '2 GB', disk: '30 GB NVMe', bw: '2 TB', price: '$5.00', regions: R4, stock: { ashburn: 'out', losangeles: 'out', chicago: 'out', houston: 'available' }, href: 'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-02', popular: false },
  { id: 'tns03', name: 'TNS-03', cpu: '2 vCPU', ram: '4 GB', disk: '40 GB NVMe', bw: '3 TB', price: '$9.00', regions: R4, stock: { ashburn: 'out', losangeles: 'out', chicago: 'out', houston: 'available' }, href: 'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-03', popular: true },
  { id: 'tns04', name: 'TNS-04', cpu: '4 vCPU', ram: '8 GB', disk: '80 GB NVMe', bw: '5 TB', price: '$18.50', regions: R4, stock: { ashburn: 'out', losangeles: 'out', chicago: 'out', houston: 'available' }, href: 'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-04', popular: false },
  { id: 'tns05', name: 'TNS-05', cpu: '6 vCPU', ram: '12 GB', disk: '120 GB NVMe', bw: '6 TB', price: '$25.00', regions: ['houston', 'ashburn', 'losangeles', 'chicago'], stock: { houston: 'available', ashburn: 'out', losangeles: 'out', chicago: 'out' }, href: 'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-05', popular: false },
  { id: 'tns06', name: 'TNS-06', cpu: '8 vCPU', ram: '16 GB', disk: '150 GB NVMe', bw: '7 TB', price: '$35.00', regions: ['houston', 'ashburn', 'losangeles', 'chicago'], stock: { houston: 'available', ashburn: 'out', losangeles: 'out', chicago: 'out' }, href: 'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-06', popular: false },
  { id: 'tns07', name: 'TNS-07', cpu: '16 vCPU', ram: '32 GB', disk: '320 GB NVMe', bw: '8 TB', price: '$75.00', regions: ['houston', 'ashburn', 'losangeles', 'chicago'], stock: { houston: 'limited', ashburn: 'out', losangeles: 'out', chicago: 'out' }, href: 'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-07', popular: false },
  { id: 'tns08', name: 'TNS-08', cpu: '22 vCPU', ram: '64 GB', disk: '1024 GB NVMe', bw: '10 TB', price: '$155.00', regions: ['ashburn', 'losangeles', 'houston', 'chicago'], stock: { ashburn: 'limited', losangeles: 'limited', houston: 'limited', chicago: 'out' }, href: 'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-08', popular: false },
];

// ── Helper genérico ─────────────────────────────────────────────────────────
async function fetchTable<T>(table: string, fallback: T[], order = 'sort_order'): Promise<T[]> {
  try {
    const { data, error } = await supabaseServer
      .from(table)
      .select('*')
      .eq('active', true)
      .order(order, { ascending: true });
    if (error || !data || data.length === 0) return fallback;
    return data as T[];
  } catch {
    return fallback;
  }
}

// ── API pública ─────────────────────────────────────────────────────────────
// Nota: los planes de Dedicated, Correo (TerraMail), Hosting y Microsoft 365
// ya NO se leen de Supabase — son contenido estático directamente en cada
// componente (DedicatedContent.astro, TerraMailContent.astro,
// HostingContent.astro / src/lib/staticPlans.ts, M365Content.astro).
export const getVpsRegions = () => fetchTable<VpsRegion>('vps_regions', FALLBACK_REGIONS);
export const getVpsPlans = () => fetchTable<VpsPlan>('vps_plans', FALLBACK_VPS);
export const getCities = () => fetchTable<City>('cities', []);

/** Ajustes de marca (fila única). */
export async function getBrand(): Promise<Record<string, any>> {
  try {
    const { data } = await supabaseServer.from('brand_settings').select('data').eq('id', 1).maybeSingle();
    return (data?.data as Record<string, any>) ?? {};
  } catch {
    return {};
  }
}

// ── Blog ─────────────────────────────────────────────────────────────────
export interface BlogPostRow {
  slug: string;
  locale: string;
  category: string;
  title: string;
  excerpt: string;
  published_at: string;
  read_time: string;
  author: string;
  tags: string[];
  intro: string;
  sections: { h: string; body: string }[];
  conclusion: string;
  image: string | null;
  faqs: { q: string; a: string }[];
  featured: boolean;
  seo_title: string | null;
  seo_description: string | null;
}

/**
 * Lista de artículos publicados, más recientes primero.
 * No filtra por idioma: /es/blog y /en/blog muestran el mismo listado
 * completo, ya que hoy los artículos se redactan en un solo idioma (es)
 * y se quiere que ambas versiones del sitio los muestren igual.
 * El parámetro `locale` se mantiene por compatibilidad con quien ya
 * llama a esta función, pero no afecta el resultado.
 */
export async function getBlogPosts(_locale?: string): Promise<BlogPostRow[]> {
  try {
    const { data, error } = await supabaseServer
      .from('blog_posts')
      .select('*')
      .eq('published', true)
      .order('published_at', { ascending: false });
    if (error || !data) return [];
    return data as BlogPostRow[];
  } catch {
    return [];
  }
}

/** Un artículo por slug (o null si no existe / no está publicado). No filtra por idioma. */
export async function getBlogPost(_locale: string, slug: string): Promise<BlogPostRow | null> {
  try {
    const { data, error } = await supabaseServer
      .from('blog_posts')
      .select('*')
      .eq('slug', slug)
      .eq('published', true)
      .maybeSingle();
    if (!error && data) return data as BlogPostRow;
    return null;
  } catch {
    return null;
  }
}

/** Slugs de todos los artículos publicados (para generar rutas/sitemap). */
export async function getBlogSlugs(locale: string): Promise<string[]> {
  const posts = await getBlogPosts(locale);
  return posts.map((p) => p.slug);
}

/** Extrae el número de un precio con formato "$12.50" → "12.50" (para JSON-LD). */
export function priceNumber(price: string): string {
  const m = String(price).match(/[\d.]+/);
  return m ? m[0] : '0';
}
