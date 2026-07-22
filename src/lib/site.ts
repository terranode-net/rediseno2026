// Configuración central del sitio. Edita aquí los datos de la empresa una sola vez.
export const SITE_URL = 'https://terranode.net';
export const BRAND = 'Terranode';

export const ORG = {
  legalName: 'Terranode',
  legalNameEC: 'Terranode S.A.S.',
  legalNameUS: 'Terranode LLC',
  foundingYear: '2023',
  email: 'ventas@terranode.net',
  phone: '+593 99 819 7150',
  phoneHref: 'tel:+593998197150',
  whatsappSupport: 'https://wa.link/nooz4l',
  whatsappSales: 'https://wa.link/03c1ug',
  discord: 'https://discord.com/invite/VAAQ6rDXRE',
  ticketUrl: 'https://my.terranode.net/submitticket',
  address: {
    streetAddress: 'Edificio City Offices',
    addressLocality: 'Guayaquil',
    addressRegion: 'Guayas',
    postalCode: '090150',
    addressCountry: 'EC',
  },
  geo: { latitude: -2.1437644, longitude: -79.9104008 },
  hasMap: 'https://www.google.com/maps?cid=12881806615684494307',
  sameAs: [
    'https://twitter.com/terranode',
    'https://linkedin.com/company/terranode',
    'https://discord.gg/terranode',
  ],
  clientPortal: 'https://my.terranode.net',
};

export type Locale = 'es' | 'en';

export const LOCALES: Record<Locale, { label: string; htmlLang: string; ogLocale: string }> = {
  es: { label: 'Español', htmlLang: 'es-EC', ogLocale: 'es_EC' },
  en: { label: 'English', htmlLang: 'en-US', ogLocale: 'en_US' },
};

// Mapa de slugs por sección — tomado 1:1 de las rutas reales de App.jsx (Shell).
// Cada sección tiene una URL distinta por idioma (no traducción en vivo).
export const PAGE_MAP = {
  home: { es: '', en: '' },
  vps: { es: 'vps', en: 'vps' },
  hosting: { es: 'hosting', en: 'hosting' },
  dedicados: { es: 'servidores-dedicados', en: 'dedicated' },
  terramail: { es: 'email', en: 'email' },
  m365: { es: 'm365', en: 'm365' },
  nosotros: { es: 'nosotros', en: 'about' },
  contacto: { es: 'contacto', en: 'contact' },
  blog: { es: 'blog', en: 'blog' },
  devweb: { es: 'desarrollo-web', en: 'web-development' },
  devsistemas: { es: 'desarrollo-sistemas', en: 'systems' },
  terms: { es: 'terminos-y-condiciones', en: 'terms-and-conditions' },
  privacy: { es: 'politica-de-privacidad', en: 'privacy-policy' },
  refund: { es: 'politica-de-reembolso', en: 'refund-policy' },
  myip: { es: 'my-ip', en: 'my-ip' },
  dns: { es: 'dns', en: 'dns' },
  hostingDetector: { es: 'hosting-detector', en: 'hosting-detector' },
  htaccess: { es: 'htaccess', en: 'htaccess' },
  emailTools: { es: 'email-tools', en: 'email-tools' },
} as const;

export type PageKey = keyof typeof PAGE_MAP;

// Páginas que existen como rutas en App.jsx pero aún no tienen contenido propio
// (se muestran en el menú ya, como pidió el cliente, con una landing "Próximamente").
export const COMING_SOON: PageKey[] = [];

export function pathFor(locale: Locale, key: PageKey): string {
  const slug = PAGE_MAP[key][locale];
  return `/${locale}/${slug}`.replace(/\/$/, '') + (slug === '' ? '/' : '/');
}

// Dado un pageKey, devuelve las rutas absolutas ES/EN para hreflang y el selector de idioma
export function alternatesFor(key: PageKey) {
  return {
    es: `${SITE_URL}${pathFor('es', key)}`,
    en: `${SITE_URL}${pathFor('en', key)}`,
  };
}

// Submenú "Servicios" (dropdown en el header) — grupo Infraestructura
export const SERVICES_NAV: { key: PageKey; label: { es: string; en: string } }[] = [
  { key: 'vps', label: { es: 'VPS', en: 'VPS' } },
  { key: 'hosting', label: { es: 'Hosting', en: 'Hosting' } },
  { key: 'dedicados', label: { es: 'Servidores Dedicados', en: 'Dedicated Servers' } },
  { key: 'terramail', label: { es: 'Correo / Terramail', en: 'Email / Terramail' } },
  { key: 'm365', label: { es: 'Microsoft 365', en: 'Microsoft 365' } },
  { key: 'devweb', label: { es: 'Diseño Web & E-Commerce', en: 'Web Design & E-Commerce' } },
  { key: 'devsistemas', label: { es: 'Desarrollo de Sistemas', en: 'Systems Development' } },
];

// Ítems de nivel superior en el header (fuera del dropdown de servicios)
export const TOP_NAV: { key: PageKey; label: { es: string; en: string } }[] = [
  { key: 'blog', label: { es: 'Blog', en: 'Blog' } },
  { key: 'nosotros', label: { es: 'Nosotros', en: 'About Us' } },
  { key: 'contacto', label: { es: 'Contacto', en: 'Contact' } },
];

// Lista plana (todas las páginas) — usada por el Footer y el sitemap manual
export const NAV: { key: PageKey; label: { es: string; en: string } }[] = [
  ...SERVICES_NAV,
  { key: 'blog', label: { es: 'Blog', en: 'Blog' } },
  { key: 'nosotros', label: { es: 'Nosotros', en: 'About Us' } },
  { key: 'contacto', label: { es: 'Contacto', en: 'Contact' } },
];
