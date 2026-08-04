# Cómo aplicar este paquete

Este zip contiene 20 archivos con la estructura EXACTA de carpetas de tu
repo (src/pages/..., src/components/..., src/lib/..., src/layouts/...).

## Pasos

1. Descomprime este zip directamente en la RAÍZ de tu repositorio
   (donde está tu carpeta `src/`), sobrescribiendo cuando te lo pida.
2. Elimina estos 4 archivos que ya no se usan (quedaron huérfanos,
   el zip no los puede borrar por ti):
   - src/pages/admin/dedicated.astro
   - src/pages/admin/mail.astro
   - src/pages/admin/hosting.astro
   - src/pages/admin/m365.astro
3. Haz commit y push de todo.

## Qué cambia

- **Dedicated, Correo (TerraMail), Hosting y Microsoft 365** ya NO se
  administran desde Supabase/admin — su contenido (precios, specs,
  características) vive directamente en el código de cada componente,
  con los datos REALES que estaban publicados al momento de este cambio
  (verificados contra la base de datos y el sitio en vivo).
- **VPS sigue igual**, se administra desde /admin/vps-plans y
  /admin/vps-regions como siempre.
- El menú de /admin y el dashboard principal ya no muestran enlaces a
  las 4 secciones retiradas.
- Las secciones "¿Qué es X y por qué elegir Terranode?" de VPS y
  TerraMail ahora se muestran dentro de un cuadro con icono, en vez de
  texto suelto.
- Las 200+ landings de ciudad (hosting-en-<ciudad> / hosting-in-<city>)
  ahora usan los mismos datos estáticos de Hosting, para que nunca se
  desincronicen entre sí.

## Para cambiar precios o texto en el futuro

Edita directamente el archivo del componente correspondiente:

| Página | Archivo a editar |
|---|---|
| Correo / TerraMail | src/components/TerraMailContent.astro |
| Servidores dedicados | src/components/DedicatedContent.astro |
| Hosting (y las landings de ciudad) | src/lib/staticPlans.ts |
| Microsoft 365 | src/components/M365Content.astro |

Pide el cambio puntual y se edita solo ese archivo — sin admin, sin
Supabase, sin riesgo de que quede desincronizado con lo que se ve en
la web.
