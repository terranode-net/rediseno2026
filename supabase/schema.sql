-- ============================================================
-- Terranode — esquema de Supabase para el formulario de contacto
-- Ejecuta esto en: Supabase Dashboard → SQL Editor → New query
-- ============================================================

create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name text not null,
  email text not null,
  phone text,
  company text,
  service_interest text not null,
  message text not null,
  locale text not null check (locale in ('es', 'en')),
  source_page text,
  status text not null default 'new' check (status in ('new', 'contacted', 'won', 'lost'))
);

comment on table public.contacts is 'Leads enviados desde el formulario de contacto del sitio web (ES/EN).';

-- Índices útiles para el panel de administración interno
create index if not exists contacts_created_at_idx on public.contacts (created_at desc);
create index if not exists contacts_status_idx on public.contacts (status);

-- Row Level Security: obligatorio para exponer la tabla con la clave "anon/publishable"
alter table public.contacts enable row level security;

-- Permite que cualquier visitante (rol "anon", usado por la publishable key)
-- únicamente INSERTE filas — nunca lea, edite ni borre datos de otros.
drop policy if exists "Public can submit contact form" on public.contacts;
create policy "Public can submit contact form"
  on public.contacts
  for insert
  to anon
  with check (true);

-- Nadie puede leer la tabla con la clave pública (ni siquiera sus propias filas).
-- Para ver los leads, usa el Table Editor de Supabase con tu cuenta,
-- o crea un usuario autenticado interno y una policy "select" aparte.

-- ============================================================
-- Opcional: notificación automática por correo con un nuevo lead
-- usando Supabase Edge Functions + Resend/Postmark. Pregúntame si
-- quieres que te arme esa función cuando el sitio esté en producción.
-- ============================================================
