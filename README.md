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
  schema.sql       15 tablas (precios, SEO, blog, ciudades, marca, SMTP, facturación...) + RLS
  seed.sql         Datos iniciales reales (precios, ciudades, SEO)
  install.sql      schema.sql + seed.sql combinados en el orden correcto — EJECUTA SOLO ESTE
vercel.json         Redirect 301 "/" -> "/es/" + headers de seguridad
```

**Panel de administración (`/admin`):** login con Supabase Auth, protegido por
`src/middleware.ts` (nadie sin sesión de admin puede ver ninguna página bajo
`/admin`). Desde ahí editas precios, SEO, blog, ciudades, proveedores del
Hosting Detector, marca y configuración privada (SMTP/facturación) — los
cambios se reflejan al instante en el sitio público porque las páginas leen
de Supabase en cada visita (SSR).

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

## 3. Supabase — base de datos y panel de administración

### 3.1 Instalar el esquema (un solo paso)

1. Entra a tu proyecto de Supabase → **SQL Editor** → **New query**.
2. Pega **todo** el contenido de `supabase/install.sql` (no `schema.sql` ni
   `seed.sql` por separado — `install.sql` ya los combina en el orden
   correcto) → **Run**.
3. Esto crea las 15 tablas (precios de VPS/dedicados/correo/hosting/M365, SEO
   por página, blog, ciudades, proveedores, marca, SMTP, facturación,
   suscriptores) con Row Level Security: lectura pública solo en contenido
   público, escritura solo para administradores.
4. Es idempotente — puedes volver a correrlo sin duplicar ni borrar nada si
   necesitas reinstalar.

### 3.2 Crear tu usuario administrador

1. Supabase → **Authentication → Users → Add user** → crea tu usuario con
   email y contraseña. Marca **"Auto Confirm User"**.
2. Copia el UUID del usuario recién creado.
3. Supabase → **SQL Editor** → ejecuta (reemplazando los valores):

   ```sql
   insert into public.admin_users (user_id, email)
   values ('PEGA-AQUI-EL-UUID', 'tu@correo.com');
   ```

4. Entra a `https://tudominio.com/admin/login` (o `http://localhost:4321/admin/login`
   en desarrollo) con ese email y contraseña. Sin el paso 3 puedes iniciar
   sesión pero no guardar cambios — es la protección de RLS funcionando.

### 3.3 Variables de entorno

Ver `.env.example`:

```
PUBLIC_SUPABASE_URL=https://cjapoonbmrfmwxzrqpgk.supabase.co
PUBLIC_SUPABASE_ANON_KEY=sb_publishable_...
```

⚠️ Nota: Supabase te muestra `SUPABASE_URL` / `SUPABASE_KEY`, pero en Astro
toda variable usada en el navegador necesita el prefijo `PUBLIC_`, si no, el
build no la expone al cliente. El `.env.example` ya viene con los nombres
correctos.

### 3.4 Formulario de contacto y suscriptores

- Los leads del formulario de contacto van a la tabla `contacts` (creada en
  el paso 3.1, con RLS: el público solo puede insertar, nunca leer) — revísalos
  y elimínalos desde **`/admin/contacts`**.
- Los suscriptores del newsletter se administran desde `/admin/subscribers`
  (ver o exportar CSV, eliminar).

### 3.5 Panels disponibles en `/admin`

| Panel | Ruta | Qué edita |
|---|---|---|
| Regiones VPS | `/admin/vps-regions` | Ubicaciones, ping, estado |
| Planes VPS | `/admin/vps-plans` | Specs, precio, stock por región |
| Servidores dedicados | `/admin/dedicated` | Specs y precio |
| Correo (TerraMail) | `/admin/mail` | Planes de correo corporativo |
| Web hosting | `/admin/hosting` | Planes de hosting compartido |
| Microsoft 365 | `/admin/m365` | Planes M365 |
| SEO por página | `/admin/seo` | Title/description/OG por ruta |
| Blog | `/admin/blog` | Artículos ES/EN |
| Ciudades | `/admin/cities` | SEO local |
| Proveedores | `/admin/providers` | Datos del Hosting Detector |
| Marca | `/admin/brand` | Contacto, redes, WhatsApp |
| SMTP y facturación | `/admin/settings` | Configuración privada |
| Contactos | `/admin/contacts` | Leads del formulario de contacto |
| Suscriptores | `/admin/subscribers` | Lista del newsletter |

Todos (excepto login) requieren sesión de administrador — `src/middleware.ts`
redirige automáticamente a `/admin/login` si no la hay.

---

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
