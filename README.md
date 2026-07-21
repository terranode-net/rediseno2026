# Terranode — Sitio Web (Astro + Supabase + Vercel)

Sitio corporativo bilingüe (Español / Inglés) para **terranode.net**, construido con
Astro, Tailwind CSS, Supabase (formulario de contacto) y pensado para desplegarse en Vercel.

---

## 1. Estructura del proyecto

```
src/
  components/     Header, Footer, Hero, Pricing, FAQ, ContactForm, etc.
  layouts/        BaseLayout.astro (head, SEO, Header/Footer)
  lib/
    site.ts       Configuración central: datos de empresa, idiomas, mapa de URLs
    schema.ts      JSON-LD reutilizable (Organization, Service, FAQ, Breadcrumb...)
    supabase.ts    Cliente de Supabase (browser-safe, usa la anon key)
  pages/
    es/           Página en español de cada sección (código independiente)
    en/           Página en inglés de cada sección (código independiente)
    index.astro   Redirección "/" -> "/es/"
supabase/
  schema.sql       Tabla `contacts` + políticas de seguridad (RLS) — CÓRRELO EN SUPABASE
vercel.json         Redirect 301 "/" -> "/es/" + headers de seguridad
```

**Importante sobre el idioma:** tal como pediste, **no hay traducción en vivo**.
Cada sección tiene un archivo `.astro` propio en español y otro en inglés, con
contenido escrito a mano en cada idioma. `src/lib/site.ts` solo mantiene el
**mapa de URLs** entre ambos (para el botón de idioma y las etiquetas `hreflang`),
no traduce nada automáticamente.

---

## 2. Instalación local

```bash
npm install
cp .env.example .env   # ya viene pre-rellenado con tus credenciales de Supabase
npm run dev
```

Abre `http://localhost:4321/es/` (o `/en/`).

## 3. Supabase — formulario de contacto

1. Entra a tu proyecto de Supabase → **SQL Editor** → pega el contenido de
   `supabase/schema.sql` → **Run**. Esto crea la tabla `contacts` con Row Level
   Security activado (el público solo puede *insertar*, nunca leer datos).
2. Variables de entorno usadas por el proyecto (ver `.env.example`):

   ```
   PUBLIC_SUPABASE_URL=https://cjapoonbmrfmwxzrqpgk.supabase.co
   PUBLIC_SUPABASE_ANON_KEY=sb_publishable_...
   ```

   ⚠️ Nota: Supabase te mostró `SUPABASE_URL` / `SUPABASE_KEY`, pero en Astro
   toda variable usada en el navegador (como el formulario) necesita el
   prefijo `PUBLIC_`, si no, el build no la expone al cliente. Por eso el
   `.env.example` ya viene con los nombres correctos y tus valores.

3. **Para ver los leads que lleguen:** entra a Supabase → **Table Editor** →
   tabla `contacts`. La anon key nunca puede leer la tabla (solo insertar),
   así que solo tú, con tu cuenta de Supabase, puedes verlos — es la
   configuración de seguridad recomendada para un formulario público.
4. (Opcional, próximo paso) Puedo configurarte una Edge Function de Supabase
   que te envíe un correo o mensaje de Slack automáticamente cuando llegue un
   lead nuevo — solo pídemelo cuando quieras implementarlo.

## 4. Despliegue en Vercel

1. Sube este proyecto a un repositorio de GitHub/GitLab.
2. En Vercel → **Add New Project** → importa el repositorio (detecta Astro automáticamente).
3. En **Environment Variables**, agrega:
   - `PUBLIC_SUPABASE_URL`
   - `PUBLIC_SUPABASE_ANON_KEY`
4. Deploy. `vercel.json` ya incluye el redirect 301 de `/` → `/es/` y headers de seguridad básicos.
5. Configura el dominio `terranode.net` (y `www.terranode.net` si aplica) en **Settings → Domains**.

---

## 5. Qué falta completar (contenido pendiente marcado con TODO)

Busca `TODO` en `src/lib/site.ts` para completar:
- Teléfono real (`ORG.phone`) y enlace de WhatsApp
- Correo real (`ORG.email`) si es distinto al usado como referencia
- Dirección física exacta (para el schema `LocalBusiness`/`Organization`)
- Enlaces reales a redes sociales (`ORG.sameAs`)

También puedes:
- Reemplazar los precios de referencia por tus tarifas reales vigentes (VPS, hosting, dedicados, Terramail, M365)
- Subir capturas o fotos reales del equipo/datacenter si quieres reforzar el "Nosotros"

## 6. SEO / GEO / AEO — qué ya está implementado

- **Técnico:** título y meta description únicos por página, canonical, `hreflang`
  real (es-EC / en-US / x-default) en las 8 secciones x2 idiomas, sitemap XML
  con alternates i18n (`@astrojs/sitemap`), `robots.txt` con permisos explícitos
  para crawlers de IA (GPTBot, PerplexityBot, ClaudeBot, Google-Extended, OAI-SearchBot).
- **Structured data (JSON-LD):** `Organization`, `WebSite`, `Service`, `Product`
  (por plan de precios), `FAQPage`, `BreadcrumbList` — presentes en cada página relevante.
- **AEO:** cada sección clave tiene un bloque de FAQ con preguntas en formato
  natural ("¿Qué es...?", "¿Puedo...?") con respuestas directas de 40-60
  palabras — el formato que Google / IA suelen extraer para snippets y
  respuestas directas. Las tablas comparativas (specs de VPS/dedicados) están
  en HTML semántico `<table>`, ideal para "table snippets".
- **E-E-A-T / GEO:** página "Nosotros" con la historia real de la empresa,
  testimonios reales con nombre, mención explícita de "Partner de Microsoft"
  en la página de M365 (factor de autoridad), datos de contacto visibles.
- **Multi-país:** el `Service` schema declara `areaServed` con varios países
  (EC, US, GB, CO, PE, MX, CL, AR) — ajusta esa lista en `src/lib/schema.ts`
  según los países que realmente quieras priorizar.
- **Rendimiento:** HTML estático (sin JS de framework pesado), Tailwind
  purgado en build, fuentes con `display=swap`, imágenes con `width`/`height`
  explícitos para evitar layout shift.

### Después de publicar, no olvides:
1. Verificar el dominio en **Google Search Console** (ambas versiones si usas
   subcarpetas: se verifica el dominio completo una sola vez) y enviar el
   sitemap: `https://terranode.net/sitemap-index.xml`.
2. Repetir en **Bing Webmaster Tools**.
3. Configurar **Google Business Profile** para Terranode Ecuador (refuerza
   el SEO local en Guayaquil/Ecuador).
4. Añadir Google Analytics 4 o Plausible cuando decidas cuál usar (no viene
   incluido por defecto para no afectar el performance ni tomar decisiones
   de tracking/consentimiento por ti).
5. Cuando tengas dominios de referencia (medios, marketplaces, directorios de
   hosting) que te enlacen, ese *backlink profile* es lo único que este sitio
   no puede resolver por sí solo — es trabajo de link-building continuo.

---

## 7. Comandos

| Comando            | Acción                                      |
|---------------------|----------------------------------------------|
| `npm run dev`       | Servidor de desarrollo                        |
| `npm run build`     | Build de producción a `dist/`                 |
| `npm run preview`   | Sirve el build de producción localmente       |
