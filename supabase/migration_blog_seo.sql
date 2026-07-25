-- ============================================================================
-- MIGRACION: agrega columnas image y faqs a blog_posts
-- ----------------------------------------------------------------------------
-- Ejecuta esto UNA VEZ en el SQL Editor de Supabase. Es seguro volver a
-- correrlo (usa IF NOT EXISTS), no borra ni duplica nada.
-- ============================================================================

alter table public.blog_posts add column if not exists image text;
alter table public.blog_posts add column if not exists faqs jsonb not null default '[]'::jsonb;
