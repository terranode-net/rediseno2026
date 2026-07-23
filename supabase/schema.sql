-- ============================================================================
-- TERRANODE — Esquema completo de base de datos
-- Ejecutar en: Supabase Dashboard → SQL Editor → New query → Run
-- ============================================================================
-- Modelo de seguridad:
--   · Rol "anon"          → solo LECTURA de contenido público (precios, blog…)
--   · Rol "authenticated" → escritura SOLO si el usuario está en admin_users
--   · Datos sensibles (suscriptores, SMTP, facturación) → sin lectura pública
-- ============================================================================

-- ── 0. Tabla de administradores ─────────────────────────────────────────────
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);
comment on table public.admin_users is 'Usuarios con permiso de escritura en el panel de administración.';

-- Función auxiliar: ¿el usuario actual es admin?
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.admin_users where user_id = auth.uid());
$$;

-- ── 0.1 Contactos (formulario público, PRIVADA) ─────────────────────────────
create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  phone text,
  company text,
  service_interest text,
  message text,
  locale text,
  source_page text,
  created_at timestamptz not null default now()
);
create index if not exists contacts_created_idx on public.contacts (created_at desc);

-- ── 1. SEO por página ───────────────────────────────────────────────────────
create table if not exists public.site_seo (
  path text primary key,                -- ej: '/vps', '/hosting'
  title text,
  description text,
  keywords text,
  og_title text,
  og_description text,
  og_image text,
  updated_at timestamptz not null default now()
);

-- ── 2. Regiones VPS ─────────────────────────────────────────────────────────
create table if not exists public.vps_regions (
  id text primary key,                  -- ej: 'ashburn'
  name text not null,
  country text not null,                -- código ISO: 'us', 'ec'
  ping text,
  status text not null default 'online',
  sort_order int not null default 0,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- ── 3. Planes VPS ───────────────────────────────────────────────────────────
create table if not exists public.vps_plans (
  id text primary key,                  -- ej: 'tns01'
  name text not null,
  cpu text, ram text, disk text, bw text,
  price text not null,
  regions jsonb not null default '[]'::jsonb,   -- ["ashburn","chicago"]
  stock   jsonb not null default '{}'::jsonb,   -- {"ashburn":"available"}
  href text,
  popular boolean not null default false,
  sort_order int not null default 0,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- ── 4. Planes de Servidores Dedicados ───────────────────────────────────────
create table if not exists public.dedicated_plans (
  id text primary key,
  name text not null,
  cpu text, cores text, ram text, disk text, net text, ip text,
  price text not null,
  period text not null default '/mes',
  tagline text,
  href text,
  popular boolean not null default false,
  sort_order int not null default 0,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- ── 5. Planes de Correo (TerraMail) ─────────────────────────────────────────
create table if not exists public.mail_plans (
  id text primary key,
  name text not null,
  users int not null default 1,
  storage text,
  price text not null,
  period text,
  monthly text,
  tagline text,
  feats jsonb not null default '[]'::jsonb,
  href text,
  popular boolean not null default false,
  sort_order int not null default 0,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- ── 6. Planes de Web Hosting ────────────────────────────────────────────────
create table if not exists public.hosting_plans (
  id text primary key,
  name text not null,
  price text not null,
  period text,
  tagline text,
  feats jsonb not null default '[]'::jsonb,
  href text,
  popular boolean not null default false,
  sort_order int not null default 0,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- ── 7. Planes de Microsoft 365 ──────────────────────────────────────────────
create table if not exists public.m365_plans (
  id text primary key,
  name text not null,
  badge text,
  price text not null,
  period text,
  tagline text,
  feats jsonb not null default '[]'::jsonb,
  href text,
  popular boolean not null default false,
  sort_order int not null default 0,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- ── 8. Blog ─────────────────────────────────────────────────────────────────
create table if not exists public.blog_posts (
  slug text primary key,
  locale text not null default 'es',
  category text,
  title text not null,
  excerpt text,
  published_at date,
  read_time text,
  author text default 'Equipo Terranode',
  tags jsonb not null default '[]'::jsonb,
  intro text,
  sections jsonb not null default '[]'::jsonb,   -- [{h,body}]
  conclusion text,
  featured boolean not null default false,
  published boolean not null default true,
  seo_title text,
  seo_description text,
  sort_order int not null default 0,
  updated_at timestamptz not null default now()
);
create index if not exists blog_posts_published_idx on public.blog_posts (published, published_at desc);

-- ── 9. Proveedores de hosting (para el Hosting Detector) ────────────────────
create table if not exists public.hosting_providers (
  id text primary key,
  name text not null,
  flag text,
  color text,
  ns_patterns jsonb not null default '[]'::jsonb,
  asns jsonb not null default '[]'::jsonb,
  description text,
  competitor boolean not null default false,
  score int,
  sort_order int not null default 0,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- ── 10. Ciudades (SEO local) ────────────────────────────────────────────────
create table if not exists public.cities (
  slug text primary key,
  name text not null,
  province text,
  country text not null default 'Ecuador',
  active boolean not null default true,
  sort_order int not null default 0,
  updated_at timestamptz not null default now()
);

-- ── 11. Ajustes de marca (fila única) ───────────────────────────────────────
create table if not exists public.brand_settings (
  id int primary key default 1,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint brand_singleton check (id = 1)
);

-- ── 12. Configuración SMTP (fila única, PRIVADA) ────────────────────────────
create table if not exists public.smtp_config (
  id int primary key default 1,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint smtp_singleton check (id = 1)
);

-- ── 13. Ajustes de facturación (fila única, PRIVADA) ────────────────────────
create table if not exists public.billing_settings (
  id int primary key default 1,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint billing_singleton check (id = 1)
);

-- ── 14. Suscriptores del newsletter (PRIVADA) ───────────────────────────────
create table if not exists public.subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  locale text default 'es',
  source text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists subscribers_created_idx on public.subscribers (created_at desc);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table public.admin_users        enable row level security;
alter table public.contacts           enable row level security;
alter table public.site_seo           enable row level security;
alter table public.vps_regions        enable row level security;
alter table public.vps_plans          enable row level security;
alter table public.dedicated_plans    enable row level security;
alter table public.mail_plans         enable row level security;
alter table public.hosting_plans      enable row level security;
alter table public.m365_plans         enable row level security;
alter table public.blog_posts         enable row level security;
alter table public.hosting_providers  enable row level security;
alter table public.cities             enable row level security;
alter table public.brand_settings     enable row level security;
alter table public.smtp_config        enable row level security;
alter table public.billing_settings   enable row level security;
alter table public.subscribers        enable row level security;

-- ── Tablas de contenido público: lectura para todos, escritura solo admin ──
do $$
declare t text;
begin
  foreach t in array array[
    'site_seo','vps_regions','vps_plans','dedicated_plans','mail_plans',
    'hosting_plans','m365_plans','blog_posts','hosting_providers','cities',
    'brand_settings'
  ]
  loop
    execute format('drop policy if exists "public read" on public.%I', t);
    execute format('create policy "public read" on public.%I for select to anon, authenticated using (true)', t);

    execute format('drop policy if exists "admin write" on public.%I', t);
    execute format('create policy "admin write" on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

-- ── Tablas privadas: solo admin (sin lectura pública) ──────────────────────
do $$
declare t text;
begin
  foreach t in array array['smtp_config','billing_settings','subscribers','admin_users','contacts']
  loop
    execute format('drop policy if exists "admin only" on public.%I', t);
    execute format('create policy "admin only" on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

-- El público SÍ puede suscribirse al newsletter (insertar), pero no leer la lista
drop policy if exists "public subscribe" on public.subscribers;
create policy "public subscribe" on public.subscribers
  for insert to anon with check (true);

-- El público SÍ puede enviar el formulario de contacto (insertar), pero no leer los leads
drop policy if exists "public contact" on public.contacts;
create policy "public contact" on public.contacts
  for insert to anon with check (true);

-- ── Trigger para updated_at ────────────────────────────────────────────────
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

do $$
declare t text;
begin
  foreach t in array array[
    'site_seo','vps_regions','vps_plans','dedicated_plans','mail_plans',
    'hosting_plans','m365_plans','blog_posts','hosting_providers','cities',
    'brand_settings','smtp_config','billing_settings'
  ]
  loop
    execute format('drop trigger if exists touch_%I on public.%I', t, t);
    execute format('create trigger touch_%I before update on public.%I for each row execute function public.touch_updated_at()', t, t);
  end loop;
end $$;

-- ============================================================================
-- PASO FINAL — CONVIÉRTETE EN ADMIN
-- ============================================================================
-- 1. Ve a Authentication → Users → "Add user" y crea tu usuario con email+contraseña
-- 2. Copia el UUID que aparece y ejecuta (reemplazando los valores):
--
--    insert into public.admin_users (user_id, email)
--    values ('PEGA-AQUI-TU-UUID', 'tu@correo.com');
--
-- Sin este paso NO podrás guardar cambios desde el panel.
-- ============================================================================
