// Configuración central del sitio. Edita aquí los datos de la empresa una sola vez.
export const SITE_URL = 'https://terranode.net';
export const BRAND = 'Terranode';

export const ORG = {
  legalName: 'Terranode',
  // TODO: confirma razón social / RUC si quieres incluirlo en el schema LocalBusiness
  foundingYear: '2023',
  formerName: 'Vsphost',
  email: 'hola@terranode.net', // TODO: reemplazar por el correo real
  phone: '+593-000-000-000', // TODO: reemplazar por el teléfono real (formato E.164)
  whatsapp: 'https://wa.me/593000000000', // TODO
  address: {
    streetAddress: 'Av. Principal', // TODO
    addressLocality: 'Guayaquil',
    addressRegion: 'Guayas',
    postalCode: '090150', // TODO
    addressCountry: 'EC',
  },
  sameAs: [
    'https://www.facebook.com/terranode',
    'https://twitter.com/terranode',
    'https://www.linkedin.com/company/terranode',
    'https://www.instagram.com/terranode',
  ],
  clientPortal: 'https://my.terranode.net',
};

export type Locale = 'es' | 'en';

export const LOCALES: Record<Locale, { label: string; htmlLang: string; ogLocale: string }> = {
  es: { label: 'Español', htmlLang: 'es-EC', ogLocale: 'es_EC' },
  en: { label: 'English', htmlLang: 'en-US', ogLocale: 'en_US' },
};

// Mapa de slugs por sección. Cada sección tiene una URL distinta por idioma
// (no traducción en vivo — son páginas y contenido separados).
export const PAGE_MAP = {
  home: { es: '', en: '' },
  vps: { es: 'vps', en: 'vps' },
  hosting: { es: 'hosting', en: 'hosting' },
  dedicados: { es: 'servidores-dedicados', en: 'dedicated-servers' },
  terramail: { es: 'terramail', en: 'terramail' },
  m365: { es: 'm365', en: 'm365' },
  nosotros: { es: 'nosotros', en: 'about-us' },
  contacto: { es: 'contacto', en: 'contact' },
} as const;

export type PageKey = keyof typeof PAGE_MAP;

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

export const NAV: { key: PageKey; label: { es: string; en: string } }[] = [
  { key: 'vps', label: { es: 'VPS', en: 'VPS' } },
  { key: 'hosting', label: { es: 'Hosting', en: 'Hosting' } },
  { key: 'dedicados', label: { es: 'Servidores Dedicados', en: 'Dedicated Servers' } },
  { key: 'terramail', label: { es: 'Terramail', en: 'Terramail' } },
  { key: 'm365', label: { es: 'Microsoft 365', en: 'Microsoft 365' } },
  { key: 'nosotros', label: { es: 'Nosotros', en: 'About Us' } },
  { key: 'contacto', label: { es: 'Contacto', en: 'Contact' } },
];
