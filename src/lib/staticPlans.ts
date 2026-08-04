// ============================================================================
// Planes de Web Hosting — contenido estático.
// ----------------------------------------------------------------------------
// Ya no se administra desde /admin ni se lee de Supabase (tabla hosting_plans
// en desuso). Usado por HostingContent.astro y por las landings dinámicas de
// ciudad (hosting-en-[city].astro / hosting-in-[city].astro) para que ambas
// muestren siempre los mismos precios, sin riesgo de desincronizarse.
// Para actualizar precios o texto, edita directamente aquí.
// ============================================================================

export interface HostingPlanStatic {
  id: string;
  name: string;
  price: string;
  period: string;
  tagline: string;
  popular: boolean;
  href: string;
  feats: string[];
}

export const HOSTING_PLANS_ES: HostingPlanStatic[] = [
  { id: '8gb', name: 'Plan 8 GB', price: '$40', period: '/año', tagline: 'Para proyectos personales', popular: false, href: 'https://my.terranode.net/store/business-hosting/hosting-8-gb', feats: ['8 GB Espacio NVMe', '40 GB Banda ancha', '5 Bases de datos', 'Correos ilimitados', "SSL Let's Encrypt gratis", 'cPanel incluido', '1-clic WordPress', 'Soporte 24/7'] },
  { id: '14gb', name: 'Plan 14 GB', price: '$64', period: '/año', tagline: 'Para proyectos en crecimiento', popular: true, href: 'https://my.terranode.net/store/business-hosting/hosting-14-gb', feats: ['14 GB Espacio NVMe', '70 GB Banda ancha', '7 Bases de datos', 'Correos ilimitados', "SSL Let's Encrypt gratis", 'cPanel incluido', '1-clic WordPress', 'Soporte 24/7'] },
  { id: '35gb', name: 'Plan 35 GB', price: '$175', period: '/año', tagline: 'Para empresas medianas', popular: false, href: 'https://my.terranode.net/store/business-hosting/hosting-35-gb', feats: ['35 GB Espacio NVMe', '175 GB Banda ancha', '17 Bases de datos', 'Correos ilimitados', "SSL Let's Encrypt gratis", 'cPanel incluido', '1-clic WordPress', 'Soporte prioritario 24/7'] },
];

export const HOSTING_PLANS_EN: HostingPlanStatic[] = [
  { id: '8gb', name: '8 GB Plan', price: '$40', period: '/yr', tagline: 'For personal projects', popular: false, href: 'https://my.terranode.net/store/business-hosting/hosting-8-gb', feats: ['8 GB NVMe Space', '40 GB Bandwidth', '5 Databases', 'Unlimited emails', "Free Let's Encrypt SSL", 'cPanel included', '1-click WordPress', '24/7 Support'] },
  { id: '14gb', name: '14 GB Plan', price: '$64', period: '/yr', tagline: 'For growing projects', popular: true, href: 'https://my.terranode.net/store/business-hosting/hosting-14-gb', feats: ['14 GB NVMe Space', '70 GB Bandwidth', '7 Databases', 'Unlimited emails', "Free Let's Encrypt SSL", 'cPanel included', '1-click WordPress', '24/7 Support'] },
  { id: '35gb', name: '35 GB Plan', price: '$175', period: '/yr', tagline: 'For mid-size businesses', popular: false, href: 'https://my.terranode.net/store/business-hosting/hosting-35-gb', feats: ['35 GB NVMe Space', '175 GB Bandwidth', '17 Databases', 'Unlimited emails', "Free Let's Encrypt SSL", 'cPanel included', '1-click WordPress', '24/7 Priority Support'] },
];

export function getHostingPlansStatic(locale: 'es' | 'en'): HostingPlanStatic[] {
  return locale === 'es' ? HOSTING_PLANS_ES : HOSTING_PLANS_EN;
}
