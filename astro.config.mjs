import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';
import vercel from '@astrojs/vercel';

// Reemplaza por tu dominio final antes de desplegar a producción
const SITE_URL = 'https://terranode.net';

export default defineConfig({
  site: SITE_URL,
  output: 'static', // páginas estáticas por defecto; usa `export const prerender = false` en una página para hacerla server-rendered (ej. una futura API route)
  adapter: vercel(),
  integrations: [
    tailwind({ applyBaseStyles: false }),
    sitemap({
      i18n: {
        defaultLocale: 'es',
        locales: {
          es: 'es-EC',
          en: 'en-US',
        },
      },
      filter: (page) =>
        !page.includes('/gracias') &&
        !page.includes('/thank-you') &&
        page !== `${SITE_URL}/`,
    }),
  ],
});
