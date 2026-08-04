// ============================================================================
// Configuración visual de categorías del blog.
// ----------------------------------------------------------------------------
// Este archivo solía contener también artículos de ejemplo (POSTS, POSTS_DB)
// usados como contenido de respaldo cuando la base de datos no tenía datos
// todavía. Esos artículos de ejemplo ya no se usan: el blog vive 100% en la
// tabla `blog_posts` de Supabase (ver src/lib/db.ts → getBlogPosts /
// getBlogPost), así que se eliminaron para evitar que contenido de prueba
// vuelva a aparecer publicado por error.
//
// Lo único que queda aquí es la configuración de color/gradiente por
// categoría, que sí sigue en uso en BlogContent.astro y BlogPostContent.astro.
// ============================================================================

export const CAT_COLORS: Record<string, string> = {
  WordPress: '#3B82F6', Linux: '#22C55E', Server: '#F59E0B', Nginx: '#10B981',
  cPanel: '#8B5CF6', Security: '#EF4444', Backup: '#06B6D4', Technologies: '#EC4899',
  Programming: '#F97316', VPS: '#3B82F6', Script: '#6366F1', Infrastructure: '#84CC16',
};

export const GRADIENTS: Record<string, string> = {
  WordPress: 'linear-gradient(135deg,#1e3a5f,#0f2640)',
  Linux: 'linear-gradient(135deg,#1a3322,#0d1f14)',
  Server: 'linear-gradient(135deg,#3d2a0a,#1f1505)',
  Nginx: 'linear-gradient(135deg,#0d3322,#071a12)',
  cPanel: 'linear-gradient(135deg,#2d1a4a,#160d24)',
  Security: 'linear-gradient(135deg,#3d1212,#1f0909)',
  Backup: 'linear-gradient(135deg,#0d2d3a,#061720)',
  Technologies: 'linear-gradient(135deg,#3a0d28,#1f0715)',
  Programming: 'linear-gradient(135deg,#3d1a0a,#1f0d05)',
  default: 'linear-gradient(135deg,#0f1e36,#070d1a)',
};
