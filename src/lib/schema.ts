import { SITE_URL, BRAND, ORG, alternatesFor, type Locale, type PageKey } from '@/lib/site';

export function organizationSchema(locale: Locale) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    '@id': `${SITE_URL}/#organization`,
    name: BRAND,
    legalName: locale === 'es' ? ORG.legalNameEC : ORG.legalNameUS,
    url: SITE_URL,
    logo: `${SITE_URL}/logo.png`,
    image: `${SITE_URL}/og/og-default.png`,
    foundingDate: ORG.foundingYear,
    email: ORG.email,
    telephone: ORG.phone,
    sameAs: ORG.sameAs,
    address: {
      '@type': 'PostalAddress',
      streetAddress: ORG.address.streetAddress,
      addressLocality: ORG.address.addressLocality,
      addressRegion: ORG.address.addressRegion,
      postalCode: ORG.address.postalCode,
      addressCountry: ORG.address.addressCountry,
    },
    geo: {
      '@type': 'GeoCoordinates',
      latitude: ORG.geo.latitude,
      longitude: ORG.geo.longitude,
    },
    hasMap: ORG.hasMap,
    contactPoint: [
      {
        '@type': 'ContactPoint',
        contactType: locale === 'es' ? 'atención al cliente' : 'customer support',
        telephone: ORG.phone,
        email: ORG.email,
        availableLanguage: ['es', 'en'],
        areaServed: 'Worldwide',
      },
    ],
    description:
      locale === 'es'
        ? 'Terranode es un proveedor de infraestructura cloud, VPS, hosting y servidores dedicados con presencia en Ecuador y Estados Unidos.'
        : 'Terranode is a cloud infrastructure provider offering VPS, hosting and dedicated servers with presence in Ecuador and the United States.',
  };
}

export function websiteSchema(locale: Locale) {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    '@id': `${SITE_URL}/#website`,
    url: SITE_URL,
    name: BRAND,
    publisher: { '@id': `${SITE_URL}/#organization` },
    inLanguage: locale === 'es' ? 'es-EC' : 'en-US',
  };
}

export function breadcrumbSchema(
  locale: Locale,
  items: { name: string; key: PageKey }[]
) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: item.name,
      item: alternatesFor(item.key)[locale],
    })),
  };
}

export function faqSchema(qas: { q: string; a: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: qas.map((qa) => ({
      '@type': 'Question',
      name: qa.q,
      acceptedAnswer: {
        '@type': 'Answer',
        text: qa.a,
      },
    })),
  };
}

export function serviceSchema(locale: Locale, opts: {
  name: string;
  description: string;
  pageKey: PageKey;
  serviceType: string;
  areaServed?: string[];
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Service',
    serviceType: opts.serviceType,
    name: opts.name,
    description: opts.description,
    provider: { '@id': `${SITE_URL}/#organization` },
    areaServed: opts.areaServed ?? ['EC', 'US', 'CO', 'PE', 'MX', 'CL', 'AR'],
    url: alternatesFor(opts.pageKey)[locale],
  };
}

export function productPlanSchema(plans: {
  name: string;
  price: string;
  currency?: string;
  description: string;
  url: string;
}[]) {
  return plans.map((p) => ({
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: p.name,
    description: p.description,
    brand: { '@type': 'Brand', name: BRAND },
    offers: {
      '@type': 'Offer',
      price: p.price,
      priceCurrency: p.currency ?? 'USD',
      availability: 'https://schema.org/InStock',
      url: p.url,
    },
  }));
}
