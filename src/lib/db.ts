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
export interface DedicatedPlan { id: string; name: string; cpu: string; cores: string; ram: string; disk: string; net: string; ip: string; price: string; period: string; tagline: string; href: string; popular: boolean }
export interface MailPlan { id: string; name: string; users: number; storage: string; price: string; period: string; monthly: string; tagline: string; feats: string[]; href: string; popular: boolean }
export interface HostingPlan { id: string; name: string; price: string; period: string; tagline: string; feats: string[]; href: string; popular: boolean }
export interface M365Plan { id: string; name: string; badge: string | null; price: string; period: string; tagline: string; feats: string[]; href: string; popular: boolean }
export interface SeoMeta { title?: string; description?: string; keywords?: string; og_title?: string; og_description?: string; og_image?: string }
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

const FALLBACK_DED: DedicatedPlan[] = [
  { id: 'e3', name: 'Intel Xeon E3-1230 V5', cpu: 'Intel Xeon E3-1230 V5 @ 3.4 GHz', cores: '4 Cores / 8 Threads', ram: '32 GB DDR4', disk: '1 TB SSD', net: '1 Gbps Ilimitado', ip: 'IPv4 + IPv6', price: '$50.00', period: '/mes', tagline: 'Ideal para proyectos personales', href: 'https://my.terranode.net/store/dedicated-servers', popular: false },
  { id: 'e5', name: 'Intel Xeon Dual E5-2680 V4', cpu: 'Intel Xeon Dual E5-2680 V4 @ 2.4 GHz', cores: '28 Cores / 56 Threads', ram: '128 GB DDR4', disk: '1 TB SSD', net: '1 Gbps Ilimitado', ip: 'IPv4 + IPv6', price: '$94.99', period: '/mes', tagline: 'Para proyectos en crecimiento', href: 'https://my.terranode.net/store/dedicated-servers', popular: true },
  { id: 'gold', name: 'Intel Xeon Dual Gold 6138', cpu: 'Intel Xeon Dual Gold 6138 @ 2.0 GHz', cores: '40 Cores / 80 Threads', ram: '256 GB DDR4', disk: '2 TB U.2 NVMe', net: '10 Gbps (330 TB)', ip: 'IPv4 + IPv6', price: '$149.99', period: '/mes', tagline: 'Para proyectos escalables y empresariales', href: 'https://my.terranode.net/store/dedicated-servers', popular: false },
];

const HOST_FEATS = (n: string) => [`${n} Espacio NVMe`, 'Correos ilimitados', "SSL Let's Encrypt gratis", 'cPanel incluido', '1-clic WordPress', 'Soporte 24/7'];
const FALLBACK_HOSTING: HostingPlan[] = [
  { id: '8gb', name: 'Plan 8 GB', price: '$40', period: '/año', tagline: 'Para proyectos personales', popular: false, href: 'https://my.terranode.net/store/business-hosting/hosting-8-gb', feats: HOST_FEATS('8 GB') },
  { id: '14gb', name: 'Plan 14 GB', price: '$64', period: '/año', tagline: 'Para proyectos en crecimiento', popular: true, href: 'https://my.terranode.net/store/business-hosting/hosting-14-gb', feats: HOST_FEATS('14 GB') },
  { id: '35gb', name: 'Plan 35 GB', price: '$175', period: '/año', tagline: 'Para empresas medianas', popular: false, href: 'https://my.terranode.net/store/business-hosting/hosting-35-gb', feats: HOST_FEATS('35 GB') },
];

const FALLBACK_M365: M365Plan[] = [
  { id: 'exchange', name: 'Exchange Online Plan 1', badge: null, price: '$5.50', period: '/mes/usuario', tagline: 'Correo empresarial con Outlook sin apps de escritorio', popular: false, href: 'https://my.terranode.net', feats: ['Buzón de 50 GB por usuario', 'Mensajes hasta 150 MB', 'Outlook Web App', 'Antispam y antimalware', 'Soporte Terranode 24/7'] },
  { id: 'basic', name: 'Microsoft 365 Business Basic', badge: 'M365', price: '$7.20', period: '/mes/usuario', tagline: 'Productividad en la nube para todo tu equipo', popular: false, href: 'https://my.terranode.net', feats: ['Buzón de 50 GB por usuario', '1 TB en OneDrive', 'Teams: chat, llamadas y video', 'SharePoint colaborativo', 'Soporte Terranode 24/7'] },
  { id: 'standard', name: 'Microsoft 365 Business Standard', badge: 'M365', price: '$12.50', period: '/mes/usuario', tagline: 'Todo lo de Basic más las apps de escritorio descargables', popular: true, href: 'https://my.terranode.net', feats: ['Todo lo del plan Business Basic', 'Apps de escritorio instalables', 'Hasta 5 PCs o Macs por usuario', 'Soporte Terranode 24/7 + migración gratis'] },
];

const MAIL_FEATS_BASE = ['Webmail Terramail Suite', 'Sincronización móvil (ActiveSync)', 'Acceso POP3 / IMAP / SMTP', 'Antivirus en tiempo real', 'Antispam avanzado', 'SSL/TLS cifrado'];
const FALLBACK_MAIL: MailPlan[] = [
  { id: 'starter', name: 'Starter', users: 1, storage: '10 GB', price: '$50', period: '/año', monthly: '≈ $2.08/mes', tagline: 'Para profesionales independientes', popular: false, href: 'https://my.terranode.net/store/corporate-email', feats: ['Buzón de 10 GB', ...MAIL_FEATS_BASE, 'Soporte 24/7'] },
  { id: 'business', name: 'Business', users: 5, storage: '30 GB', price: '$69.99', period: '/año', monthly: '≈ $5.83/mes', tagline: 'Para equipos y empresas en crecimiento', popular: true, href: 'https://my.terranode.net/store/corporate-email', feats: ['Buzón de 30 GB', ...MAIL_FEATS_BASE, 'Calendario y contactos compartidos', 'Soporte prioritario 24/7'] },
  { id: 'custom', name: 'Empresarial', users: 0, storage: 'Custom', price: 'Custom', period: '', monthly: 'Contacta al equipo de ventas', tagline: 'Solución a medida para grandes empresas', popular: false, href: '/contacto', feats: ['Almacenamiento ilimitado', 'Administración centralizada', 'Soporte dedicado', 'SLA empresarial'] },
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
export const getVpsRegions = () => fetchTable<VpsRegion>('vps_regions', FALLBACK_REGIONS);
export const getVpsPlans = () => fetchTable<VpsPlan>('vps_plans', FALLBACK_VPS);
export const getDedicatedPlans = () => fetchTable<DedicatedPlan>('dedicated_plans', FALLBACK_DED);
export const getMailPlans = () => fetchTable<MailPlan>('mail_plans', FALLBACK_MAIL);
export const getHostingPlans = () => fetchTable<any>('hosting_plans', []);
export const getM365Plans = () => fetchTable<any>('m365_plans', []);
export const getCities = () => fetchTable<City>('cities', []);

/** Metadatos SEO de una ruta. Devuelve null si no hay override en la base. */
export async function getSeo(path: string): Promise<SeoMeta | null> {
  try {
    const { data, error } = await supabaseServer.from('site_seo').select('*').eq('path', path).maybeSingle();
    if (error || !data) return null;
    return data as SeoMeta;
  } catch {
    return null;
  }
}

/** Ajustes de marca (fila única). */
export async function getBrand(): Promise<Record<string, any>> {
  try {
    const { data } = await supabaseServer.from('brand_settings').select('data').eq('id', 1).maybeSingle();
    return (data?.data as Record<string, any>) ?? {};
  } catch {
    return {};
  }
}

/** Extrae el número de un precio con formato "$12.50" → "12.50" (para JSON-LD). */
export function priceNumber(price: string): string {
  const m = String(price).match(/[\d.]+/);
  return m ? m[0] : '0';
}
