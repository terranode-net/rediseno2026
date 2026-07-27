// ============================================================================
// /sitemap.xml — sitemap dinámico y en vivo
// ----------------------------------------------------------------------------
// Reemplaza a los archivos sitemap-cities.xml / sitemap-es.xml / sitemap-en.xml
// que quedaron huérfanos en producción (subidos a mano en algún momento, sin
// nada en el código que los mantuviera). Este endpoint se genera en cada
// request (prerender = false) y siempre refleja el estado actual de:
//
//   1. Páginas estáticas (PAGE_MAP) en ambos idiomas.
//   2. Artículos de blog publicados (tabla blog_posts, published = true).
//   3. Landings de "Hosting en <ciudad>" (tabla cities, active = true).
//
// Al ser generado desde la base de datos en tiempo real, nunca vuelve a
// desactualizarse: cuando agregas una ciudad o publicas un artículo, ya
// aparece en el sitemap en la siguiente vez que Google (o cualquiera) lo pida
// — sin depender de un nuevo deploy.
//
// El @astrojs/sitemap automático (astro.config.mjs) sigue cubriendo las
// páginas 100% estáticas por si acaso, pero este archivo es el que debe
// enviarse a Google Search Console como fuente principal.
// ============================================================================
export const prerender = false;

import type { APIRoute } from 'astro';
import { PAGE_MAP, SITE_URL, type Locale } from '@/lib/site';
import { getBlogPosts, getCities } from '@/lib/db';

interface UrlEntry {
  loc: string;
  lastmod?: string;
  changefreq?: string;
  priority?: string;
  alternates?: { es: string; en: string };
}

function xmlEscape(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function urlBlock(entry: UrlEntry): string {
  const alt = entry.alternates
    ? `\n    <xhtml:link rel="alternate" hreflang="es" href="${xmlEscape(entry.alternates.es)}" />` +
      `\n    <xhtml:link rel="alternate" hreflang="en" href="${xmlEscape(entry.alternates.en)}" />` +
      `\n    <xhtml:link rel="alternate" hreflang="x-default" href="${xmlEscape(entry.alternates.es)}" />`
    : '';
  return (
    `  <url>\n` +
    `    <loc>${xmlEscape(entry.loc)}</loc>` +
    (entry.lastmod ? `\n    <lastmod>${entry.lastmod}</lastmod>` : '') +
    (entry.changefreq ? `\n    <changefreq>${entry.changefreq}</changefreq>` : '') +
    (entry.priority ? `\n    <priority>${entry.priority}</priority>` : '') +
    alt +
    `\n  </url>`
  );
}

export const GET: APIRoute = async () => {
  const entries: UrlEntry[] = [];
  const today = new Date().toISOString().slice(0, 10);

  // ── 1. Páginas estáticas del sitio (desde PAGE_MAP) ─────────────────────
  // Se excluyen: home (se agrega aparte con prioridad 1.0) y páginas legales
  // de bajo valor SEO (terms/privacy/refund) que no aportan tráfico orgánico
  // pero siguen siendo accesibles — solo no se listan en el sitemap.
  const SKIP_KEYS = new Set(['terms', 'privacy', 'refund']);
  for (const key of Object.keys(PAGE_MAP) as (keyof typeof PAGE_MAP)[]) {
    if (key === 'home' || SKIP_KEYS.has(key)) continue;
    const slugEs = PAGE_MAP[key].es;
    const slugEn = PAGE_MAP[key].en;
    const pathEs = `/es/${slugEs}`.replace(/\/$/, '') + '/';
    const pathEn = `/en/${slugEn}`.replace(/\/$/, '') + '/';
    entries.push({
      loc: `${SITE_URL}${pathEs}`,
      changefreq: 'weekly',
      priority: '0.8',
      alternates: { es: `${SITE_URL}${pathEs}`, en: `${SITE_URL}${pathEn}` },
    });
    entries.push({
      loc: `${SITE_URL}${pathEn}`,
      changefreq: 'weekly',
      priority: '0.8',
      alternates: { es: `${SITE_URL}${pathEs}`, en: `${SITE_URL}${pathEn}` },
    });
  }

  // Home explícito, máxima prioridad
  entries.unshift({
    loc: `${SITE_URL}/en/`,
    changefreq: 'daily',
    priority: '1.0',
    alternates: { es: `${SITE_URL}/es/`, en: `${SITE_URL}/en/` },
  });
  entries.unshift({
    loc: `${SITE_URL}/es/`,
    changefreq: 'daily',
    priority: '1.0',
    alternates: { es: `${SITE_URL}/es/`, en: `${SITE_URL}/en/` },
  });

  // ── 2. Artículos de blog publicados (es + en) ───────────────────────────
  for (const locale of ['es', 'en'] as Locale[]) {
    const posts = await getBlogPosts(locale);
    for (const post of posts) {
      const path = `/${locale}/blog/${post.slug}/`;
      entries.push({
        loc: `${SITE_URL}${path}`,
        lastmod: post.published_at || today,
        changefreq: 'monthly',
        priority: '0.7',
      });
    }
  }

  // ── 3. Landings "Hosting en <ciudad>" (200+ páginas dinámicas) ──────────
  const cities = await getCities();
  for (const city of cities) {
    const pathEs = `/es/hosting-en-${city.slug}/`;
    const pathEn = `/en/hosting-in-${city.slug}/`;
    entries.push({
      loc: `${SITE_URL}${pathEs}`,
      changefreq: 'monthly',
      priority: '0.6',
      alternates: { es: `${SITE_URL}${pathEs}`, en: `${SITE_URL}${pathEn}` },
    });
    entries.push({
      loc: `${SITE_URL}${pathEn}`,
      changefreq: 'monthly',
      priority: '0.6',
      alternates: { es: `${SITE_URL}${pathEs}`, en: `${SITE_URL}${pathEn}` },
    });
  }

  const body =
    `<?xml version="1.0" encoding="UTF-8"?>\n` +
    `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">\n` +
    entries.map(urlBlock).join('\n') +
    `\n</urlset>\n`;

  return new Response(body, {
    status: 200,
    headers: {
      'Content-Type': 'application/xml; charset=utf-8',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600', // 1h de caché en el edge de Vercel
    },
  });
};
