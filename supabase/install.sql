-- ============================================================================
-- TERRANODE -- INSTALACION COMPLETA (esquema + datos iniciales)
-- ----------------------------------------------------------------------------
-- EJECUTA SOLO ESTE ARCHIVO. Contiene todo en el orden correcto.
--   Supabase -> SQL Editor -> New query -> pega TODO esto -> Run
-- Es idempotente: si lo vuelves a ejecutar no duplica ni borra nada.
-- ============================================================================

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
-- TERRANODE — Datos iniciales (seed)
-- Generado desde: vps-data.js, ded-data.js, mail-data.js, cities.js, seo.js
-- Ejecutar DESPUÉS de schema.sql
-- Es idempotente: puedes volver a ejecutarlo sin duplicar nada.
-- ============================================================================

-- ── Regiones VPS ──
insert into public.vps_regions (id,name,country,ping,status,sort_order) values ('houston','Houston, TX','us','15ms','online',0)
  on conflict (id) do update set name=excluded.name,country=excluded.country,ping=excluded.ping,status=excluded.status,sort_order=excluded.sort_order;
insert into public.vps_regions (id,name,country,ping,status,sort_order) values ('ashburn','Ashburn, VA','us','12ms','online',1)
  on conflict (id) do update set name=excluded.name,country=excluded.country,ping=excluded.ping,status=excluded.status,sort_order=excluded.sort_order;
insert into public.vps_regions (id,name,country,ping,status,sort_order) values ('losangeles','Los Ángeles, CA','us','8ms','online',2)
  on conflict (id) do update set name=excluded.name,country=excluded.country,ping=excluded.ping,status=excluded.status,sort_order=excluded.sort_order;
insert into public.vps_regions (id,name,country,ping,status,sort_order) values ('chicago','Chicago, IL','us','18ms','online',3)
  on conflict (id) do update set name=excluded.name,country=excluded.country,ping=excluded.ping,status=excluded.status,sort_order=excluded.sort_order;
insert into public.vps_regions (id,name,country,ping,status,sort_order) values ('guayaquil','Guayaquil, EC','ec','3ms','online',4)
  on conflict (id) do update set name=excluded.name,country=excluded.country,ping=excluded.ping,status=excluded.status,sort_order=excluded.sort_order;

-- ── Planes VPS ──
insert into public.vps_plans (id,name,cpu,ram,disk,bw,price,regions,stock,href,popular,sort_order) values ('tns01','TNS-01','1 vCPU','1 GB','25 GB NVMe','1 TB','$2.99','["ashburn", "losangeles", "chicago", "houston"]'::jsonb,'{"ashburn": "out", "losangeles": "out", "chicago": "out", "houston": "out"}'::jsonb,'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-01',false,0)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,ram=excluded.ram,disk=excluded.disk,bw=excluded.bw,price=excluded.price,regions=excluded.regions,stock=excluded.stock,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.vps_plans (id,name,cpu,ram,disk,bw,price,regions,stock,href,popular,sort_order) values ('tns02','TNS-02','1 vCPU','2 GB','30 GB NVMe','2 TB','$5.00','["ashburn", "losangeles", "chicago", "houston"]'::jsonb,'{"ashburn": "out", "losangeles": "out", "chicago": "out", "houston": "available"}'::jsonb,'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-02',false,1)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,ram=excluded.ram,disk=excluded.disk,bw=excluded.bw,price=excluded.price,regions=excluded.regions,stock=excluded.stock,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.vps_plans (id,name,cpu,ram,disk,bw,price,regions,stock,href,popular,sort_order) values ('tns03','TNS-03','2 vCPU','4 GB','40 GB NVMe','3 TB','$9.00','["ashburn", "losangeles", "chicago", "houston"]'::jsonb,'{"ashburn": "out", "losangeles": "out", "chicago": "out", "houston": "available"}'::jsonb,'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-03',true,2)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,ram=excluded.ram,disk=excluded.disk,bw=excluded.bw,price=excluded.price,regions=excluded.regions,stock=excluded.stock,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.vps_plans (id,name,cpu,ram,disk,bw,price,regions,stock,href,popular,sort_order) values ('tns04','TNS-04','4 vCPU','8 GB','80 GB NVMe','5 TB','$18.50','["ashburn", "losangeles", "chicago", "houston"]'::jsonb,'{"ashburn": "out", "losangeles": "out", "chicago": "out", "houston": "available"}'::jsonb,'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-04',false,3)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,ram=excluded.ram,disk=excluded.disk,bw=excluded.bw,price=excluded.price,regions=excluded.regions,stock=excluded.stock,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.vps_plans (id,name,cpu,ram,disk,bw,price,regions,stock,href,popular,sort_order) values ('tns05','TNS-05','6 vCPU','12 GB','120 GB NVMe','6 TB','$25.00','["houston", "ashburn", "losangeles", "chicago"]'::jsonb,'{"houston": "available", "ashburn": "out", "losangeles": "out", "chicago": "out"}'::jsonb,'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-05',false,4)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,ram=excluded.ram,disk=excluded.disk,bw=excluded.bw,price=excluded.price,regions=excluded.regions,stock=excluded.stock,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.vps_plans (id,name,cpu,ram,disk,bw,price,regions,stock,href,popular,sort_order) values ('tns06','TNS-06','8 vCPU','16 GB','150 GB NVMe','7 TB','$35.00','["houston", "ashburn", "losangeles", "chicago"]'::jsonb,'{"houston": "available", "ashburn": "out", "losangeles": "out", "chicago": "out"}'::jsonb,'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-06',false,5)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,ram=excluded.ram,disk=excluded.disk,bw=excluded.bw,price=excluded.price,regions=excluded.regions,stock=excluded.stock,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.vps_plans (id,name,cpu,ram,disk,bw,price,regions,stock,href,popular,sort_order) values ('tns07','TNS-07','16 vCPU','32 GB','320 GB NVMe','8 TB','$75.00','["houston", "ashburn", "losangeles", "chicago"]'::jsonb,'{"houston": "limited", "ashburn": "out", "losangeles": "out", "chicago": "out"}'::jsonb,'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-07',false,6)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,ram=excluded.ram,disk=excluded.disk,bw=excluded.bw,price=excluded.price,regions=excluded.regions,stock=excluded.stock,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.vps_plans (id,name,cpu,ram,disk,bw,price,regions,stock,href,popular,sort_order) values ('tns08','TNS-08','22 vCPU','64 GB','1024 GB NVMe','10 TB','$155.00','["ashburn", "losangeles", "houston", "chicago"]'::jsonb,'{"ashburn": "limited", "losangeles": "limited", "houston": "limited", "chicago": "out"}'::jsonb,'https://my.terranode.net/store/ashburn-intel-kvm-vps/va-tns-08',false,7)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,ram=excluded.ram,disk=excluded.disk,bw=excluded.bw,price=excluded.price,regions=excluded.regions,stock=excluded.stock,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;

-- ── Servidores Dedicados ──
insert into public.dedicated_plans (id,name,cpu,cores,ram,disk,net,ip,price,period,tagline,href,popular,sort_order) values ('e3','Intel Xeon E3-1230 V5','Intel Xeon E3-1230 V5 @ 3.4 GHz','4 Cores / 8 Threads','32 GB DDR4','1 TB SSD','1 Gbps Ilimitado','IPv4 + IPv6','$50.00','/mes','Ideal para proyectos personales','https://my.terranode.net/store/dedicated-servers',false,0)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,cores=excluded.cores,ram=excluded.ram,disk=excluded.disk,net=excluded.net,ip=excluded.ip,price=excluded.price,period=excluded.period,tagline=excluded.tagline,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.dedicated_plans (id,name,cpu,cores,ram,disk,net,ip,price,period,tagline,href,popular,sort_order) values ('e5','Intel Xeon Dual E5-2680 V4','Intel Xeon Dual E5-2680 V4 @ 2.4 GHz','28 Cores / 56 Threads','128 GB DDR4','1 TB SSD','1 Gbps Ilimitado','IPv4 + IPv6','$94.99','/mes','Para proyectos en crecimiento','https://my.terranode.net/store/dedicated-servers',true,1)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,cores=excluded.cores,ram=excluded.ram,disk=excluded.disk,net=excluded.net,ip=excluded.ip,price=excluded.price,period=excluded.period,tagline=excluded.tagline,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.dedicated_plans (id,name,cpu,cores,ram,disk,net,ip,price,period,tagline,href,popular,sort_order) values ('gold','Intel Xeon Dual Gold 6138','Intel Xeon Dual Gold 6138 @ 2.0 GHz','40 Cores / 80 Threads','256 GB DDR4','2 TB U.2 NVMe','10 Gbps (330 TB)','IPv4 + IPv6','$149.99','/mes','Para proyectos escalables y empresariales','https://my.terranode.net/store/dedicated-servers',false,2)
  on conflict (id) do update set name=excluded.name,cpu=excluded.cpu,cores=excluded.cores,ram=excluded.ram,disk=excluded.disk,net=excluded.net,ip=excluded.ip,price=excluded.price,period=excluded.period,tagline=excluded.tagline,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;

-- ── Planes de Correo (TerraMail) ──
insert into public.mail_plans (id,name,users,storage,price,period,monthly,tagline,feats,href,popular,sort_order) values ('starter','Starter',1,'10 GB','$50','/año','≈ $2.08/mes','Para profesionales independientes','["Buzón de 10 GB", "Webmail Terramail Suite", "Sincronización móvil (ActiveSync)", "Acceso POP3 / IMAP / SMTP", "Antivirus en tiempo real", "Antispam avanzado", "SSL/TLS cifrado", "Soporte 24/7"]'::jsonb,'https://my.terranode.net/store/corporate-email',false,0)
  on conflict (id) do update set name=excluded.name,users=excluded.users,storage=excluded.storage,price=excluded.price,period=excluded.period,monthly=excluded.monthly,tagline=excluded.tagline,feats=excluded.feats,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.mail_plans (id,name,users,storage,price,period,monthly,tagline,feats,href,popular,sort_order) values ('business','Business',5,'30 GB','$69.99','/año','≈ $5.83/mes','Para equipos y empresas en crecimiento','["Buzón de 30 GB", "Webmail Terramail Suite", "Sincronización móvil (ActiveSync)", "Acceso POP3 / IMAP / SMTP", "Antivirus en tiempo real", "Antispam avanzado", "SSL/TLS cifrado", "Calendario y contactos compartidos", "Soporte prioritario 24/7"]'::jsonb,'https://my.terranode.net/store/corporate-email',true,1)
  on conflict (id) do update set name=excluded.name,users=excluded.users,storage=excluded.storage,price=excluded.price,period=excluded.period,monthly=excluded.monthly,tagline=excluded.tagline,feats=excluded.feats,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;
insert into public.mail_plans (id,name,users,storage,price,period,monthly,tagline,feats,href,popular,sort_order) values ('custom','Empresarial',0,'Custom','Custom','','Contacta al equipo de ventas','Solución a medida para grandes empresas','["Almacenamiento ilimitado", "Administración centralizada", "Soporte dedicado", "SLA empresarial"]'::jsonb,'/contacto',false,2)
  on conflict (id) do update set name=excluded.name,users=excluded.users,storage=excluded.storage,price=excluded.price,period=excluded.period,monthly=excluded.monthly,tagline=excluded.tagline,feats=excluded.feats,href=excluded.href,popular=excluded.popular,sort_order=excluded.sort_order;

-- ── Ciudades para SEO local (524) ──
insert into public.cities (slug,name,province,country,active,sort_order) values ('cuenca','Cuenca','Azuay','Ecuador',true,0)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('machala','Machala','El Oro','Ecuador',true,1)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('manta','Manta','Manabí','Ecuador',true,2)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ambato','Ambato','Tungurahua','Ecuador',true,3)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('loja','Loja','Loja','Ecuador',true,4)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santo-domingo','Santo Domingo','Sto. Domingo','Ecuador',true,5)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('portoviejo','Portoviejo','Manabí','Ecuador',true,6)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('riobamba','Riobamba','Chimborazo','Ecuador',true,7)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sinaloa','Sinaloa','','México',true,8)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('rocafuerte','Rocafuerte','','Ecuador',true,9)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('daule','Daule','','Ecuador',true,10)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('quito','Quito','','Ecuador',true,11)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('muisne','Muisne','','Ecuador',true,12)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('galapagos','Galapagos','','Ecuador',true,13)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tulcan','Tulcán','','Ecuador',true,14)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guayaquil','Guayaquil','','Ecuador',true,15)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('macas','Macas','','Ecuador',true,16)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('manabi','Manabí','','Ecuador',true,17)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mompiche','Mompiche','','Ecuador',true,18)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('atacames','Atacames','','Ecuador',true,19)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('esmeraldas','Esmeraldas','','Ecuador',true,20)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('salinas','Salinas','','Ecuador',true,21)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ibarra','Ibarra','','Ecuador',true,22)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tena','Tena','','Ecuador',true,23)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('jipijapa','Jipijapa','','Ecuador',true,24)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zamora-chinchipe','Zamora Chinchipe','','Ecuador',true,25)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('bahia-de-caraquez','Bahía de Caraquez','','Ecuador',true,26)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santo-domingo-de-los-tsachilas','Santo Domingo de los Tsachilas','','Ecuador',true,27)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('babahoyo','Babahoyo','','Ecuador',true,28)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('quevedo','Quevedo','','Ecuador',true,29)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sangolqui','Sangolquí','','Ecuador',true,30)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('milagro','Milagro','','Ecuador',true,31)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chone','Chone','','Ecuador',true,32)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('latacunga','Latacunga','','Ecuador',true,33)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pasaje','Pasaje','','Ecuador',true,34)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santa-rosa','Santa Rosa','','Ecuador',true,35)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('huaquillas','Huaquillas','','Ecuador',true,36)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-libertad','La Libertad','','Ecuador',true,37)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-aurora','La Aurora','','Ecuador',true,38)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('samborondon','Samborond�n','','Ecuador',true,39)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ventanas','Ventanas','','Ecuador',true,40)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-carmen','El Carmen','','Ecuador',true,41)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('montecristi','Montecristi','','Ecuador',true,42)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('otavalo','Otavalo','','Ecuador',true,43)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cayambe','Cayambe','','Ecuador',true,44)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puyo','Puyo','','Ecuador',true,45)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('nueva-loja','Nueva Loja','','Ecuador',true,46)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-coca','El Coca','','Ecuador',true,47)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('azogues','Azogues','','Ecuador',true,48)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santa-elena','Santa Elena','','Ecuador',true,49)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('balzar','Balzar','','Ecuador',true,50)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('naranjal','Naranjal','','Ecuador',true,51)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-triunfo','El Triunfo','','Ecuador',true,52)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pedro-carbo','Pedro Carbo','','Ecuador',true,53)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pelileo','Pelileo','','Ecuador',true,54)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('quero','Quero','','Ecuador',true,55)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('banos-de-agua-santa','Baños de Agua Santa','','Ecuador',true,56)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('gualaceo','Gualaceo','','Ecuador',true,57)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('paute','Paute','','Ecuador',true,58)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sigsig','Sigsig','','Ecuador',true,59)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('giron','Girón','','Ecuador',true,60)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santa-isabel','Santa Isabel','','Ecuador',true,61)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('catamayo','Catamayo','','Ecuador',true,62)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cariamanga','Cariamanga','','Ecuador',true,63)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('macara','Macará','','Ecuador',true,64)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pinas','Piñas','','Ecuador',true,65)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zaruma','Zaruma','','Ecuador',true,66)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('arenillas','Arenillas','','Ecuador',true,67)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('atuntaqui','Atuntaqui','','Ecuador',true,68)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cotacachi','Cotacachi','','Ecuador',true,69)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-gabriel','San Gabriel','','Ecuador',true,70)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mira','Mira','','Ecuador',true,71)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('calceta','Calceta','','Ecuador',true,72)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-recreo','El Recreo','','Ecuador',true,73)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santa-ana','Santa Ana','','Ecuador',true,74)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pajan','Paján','','Ecuador',true,75)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pedernales','Pedernales','','Ecuador',true,76)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('jama','Jama','','Ecuador',true,77)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('canoa','Canoa','','Ecuador',true,78)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-lopez','Puerto López','','Ecuador',true,79)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('jaramijo','Jaramijó','','Ecuador',true,80)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-vicente','San Vicente','','Ecuador',true,81)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tosagua','Tosagua','','Ecuador',true,82)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('vinces','Vinces','','Ecuador',true,83)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('buena-fe','Buena Fe','','Ecuador',true,84)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-empalme','El Empalme','','Ecuador',true,85)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('valencia','Valencia','','Ecuador',true,86)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('montalvo','Montalvo','','Ecuador',true,87)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puebloviejo','Puebloviejo','','Ecuador',true,88)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('catarama','Catarama','','Ecuador',true,89)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guaranda','Guaranda','','Ecuador',true,90)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-miguel-de-bolivar','San Miguel de Bolívar','','Ecuador',true,91)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chimbo','Chimbo','','Ecuador',true,92)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('alausi','Alausí','','Ecuador',true,93)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guano','Guano','','Ecuador',true,94)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chambo','Chambo','','Ecuador',true,95)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cumanda','Cumandá','','Ecuador',true,96)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pallatanga','Pallatanga','','Ecuador',true,97)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pujili','Pujilí','','Ecuador',true,98)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('salcedo','Salcedo','','Ecuador',true,99)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('saquisili','Saquisilí','','Ecuador',true,100)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-mana','La Maná','','Ecuador',true,101)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pangua','Pangua','','Ecuador',true,102)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('machachi','Machachi','','Ecuador',true,103)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tabacundo','Tabacundo','','Ecuador',true,104)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('valle-de-los-chillos','Valle de los Chillos','','Ecuador',true,105)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-ayora','Puerto Ayora','','Ecuador',true,106)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-baquerizo-moreno','Puerto Baquerizo Moreno','','Ecuador',true,107)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('villamil-playas','Villamil Playas','','Ecuador',true,108)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('general-villamil','General Villamil','','Ecuador',true,109)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('yaguachi','Yaguachi','','Ecuador',true,110)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('jujan','Juján','','Ecuador',true,111)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('simon-bolivar','Simón Bolívar','','Ecuador',true,112)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('marcelino-mariduena','Marcelino Maridueña','','Ecuador',true,113)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('naranjito','Naranjito','','Ecuador',true,114)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('bucay','Bucay','','Ecuador',true,115)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-troncal','La Troncal','','Ecuador',true,116)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('canar','Cañar','','Ecuador',true,117)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('biblian','Biblián','','Ecuador',true,118)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('shushufindi','Shushufindi','','Ecuador',true,119)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('joya-de-los-sachas','Joya de los Sachas','','Ecuador',true,120)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('loreto','Loreto','','Ecuador',true,121)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('archidona','Archidona','','Ecuador',true,122)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('baeza','Baeza','','Ecuador',true,123)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-chaco','El Chaco','','Ecuador',true,124)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('gualaquiza','Gualaquiza','','Ecuador',true,125)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('limon-indanza','Limón Indanza','','Ecuador',true,126)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sucua','Sucúa','','Ecuador',true,127)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('bogota','Bogotá','','Colombia',true,128)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cali','Cali','','Colombia',true,129)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('bucaramanga','Bucaramanga','','Colombia',true,130)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-de-mexico','Ciudad de México','','México',true,131)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('monterrey','Monterrey','','México',true,132)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guadalajara','Guadalajara','','México',true,133)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puebla','Puebla','','México',true,134)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('toluca','Toluca','','México',true,135)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tijuana','Tijuana','','México',true,136)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('leon','León','','México',true,137)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('queretaro','Querétaro','','México',true,138)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-juarez','Ciudad Juárez','','México',true,139)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-luis-potosi','San Luis Potosí','','México',true,140)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('merida','Mérida','','México',true,141)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('aguascalientes','Aguascalientes','','México',true,142)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('hermosillo','Hermosillo','','México',true,143)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mexicali','Mexicali','','México',true,144)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('saltillo','Saltillo','','México',true,145)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('culiacan','Culiacán','','México',true,146)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cancun','Cancún','','México',true,147)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chihuahua','Chihuahua','','México',true,148)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('morelia','Morelia','','México',true,149)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('veracruz','Veracruz','','México',true,150)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('torreon','Torreón','','México',true,151)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('villahermosa','Villahermosa','','México',true,152)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cuernavaca','Cuernavaca','','México',true,153)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('durango','Durango','','México',true,154)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('reynosa','Reynosa','','México',true,155)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mazatlan','Mazatlán','','México',true,156)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('irapuato','Irapuato','','México',true,157)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tuxtla-gutierrez','Tuxtla Gutiérrez','','México',true,158)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('xalapa','Xalapa','','México',true,159)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pachuca','Pachuca','','México',true,160)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tampico','Tampico','','México',true,161)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('celaya','Celaya','','México',true,162)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tepic','Tepic','','México',true,163)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('matamoros','Matamoros','','México',true,164)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('oaxaca','Oaxaca','','México',true,165)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('nuevo-laredo','Nuevo Laredo','','México',true,166)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-vallarta','Puerto Vallarta','','México',true,167)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ensenada','Ensenada','','México',true,168)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('los-mochis','Los Mochis','','México',true,169)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-obregon','Ciudad Obregón','','México',true,170)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('coatzacoalcos','Coatzacoalcos','','México',true,171)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('campeche','Campeche','','México',true,172)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zacatecas','Zacatecas','','México',true,173)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('colima','Colima','','México',true,174)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chilpancingo','Chilpancingo','','México',true,175)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cuautla','Cuautla','','México',true,176)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('playa-del-carmen','Playa del Carmen','','México',true,177)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-victoria','Ciudad Victoria','','México',true,178)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tapachula','Tapachula','','México',true,179)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('manzanillo','Manzanillo','','México',true,180)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('naucalpan','Naucalpan','','México',true,181)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tlalnepantla','Tlalnepantla','','México',true,182)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ecatepec','Ecatepec','','México',true,183)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zapopan','Zapopan','','México',true,184)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guadalupe','Guadalupe','','México',true,185)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('apodaca','Apodaca','','México',true,186)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-nicolas','San Nicolás','','México',true,187)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('metepec','Metepec','','México',true,188)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-juan-del-rio','San Juan del Río','','México',true,189)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tulancingo','Tulancingo','','México',true,190)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tehuacan','Tehuacán','','México',true,191)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('monclova','Monclova','','México',true,192)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('piedras-negras','Piedras Negras','','México',true,193)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('nogales','Nogales','','México',true,194)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-luis-rio-colorado','San Luis Río Colorado','','México',true,195)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('gomez-palacio','Gómez Palacio','','México',true,196)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('uruapan','Uruapan','','México',true,197)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zamora','Zamora','','México',true,198)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('salamanca','Salamanca','','México',true,199)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guanajuato','Guanajuato','','México',true,200)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-miguel-de-allende','San Miguel de Allende','','México',true,201)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cordoba','Córdoba','','México',true,202)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('orizaba','Orizaba','','México',true,203)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('poza-rica','Poza Rica','','México',true,204)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('minatitlan','Minatitlán','','México',true,205)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('acapulco','Acapulco','','México',true,206)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-cristobal-de-las-casas','San Cristóbal de las Casas','','México',true,207)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('comitan','Comitán','','México',true,208)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chetumal','Chetumal','','México',true,209)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cozumel','Cozumel','','México',true,210)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cabo-san-lucas','Cabo San Lucas','','México',true,211)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-paz','La Paz','','México',true,212)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-jose-del-cabo','San José del Cabo','','México',true,213)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guaymas','Guaymas','','México',true,214)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('navojoa','Navojoa','','México',true,215)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('delicias','Delicias','','México',true,216)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('parral','Parral','','México',true,217)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cuauhtemoc','Cuauhtémoc','','México',true,218)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('fresnillo','Fresnillo','','México',true,219)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('jerez','Jerez','','México',true,220)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('lagos-de-moreno','Lagos de Moreno','','México',true,221)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tepatitlan','Tepatitlán','','México',true,222)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-guzman','Ciudad Guzmán','','México',true,223)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-pedro-garza-garcia','San Pedro Garza García','','México',true,224)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santa-catarina','Santa Catarina','','México',true,225)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('escobedo','Escobedo','','México',true,226)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('garcia','García','','México',true,227)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chimalhuacan','Chimalhuacán','','México',true,228)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chalco','Chalco','','México',true,229)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('texcoco','Texcoco','','México',true,230)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tultitlan','Tultitlán','','México',true,231)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cuautitlan-izcalli','Cuautitlán Izcalli','','México',true,232)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('huixquilucan','Huixquilucan','','México',true,233)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('atlixco','Atlixco','','México',true,234)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-pedro-cholula','San Pedro Cholula','','México',true,235)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-andres-cholula','San Andrés Cholula','','México',true,236)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('teziutlan','Teziutlán','','México',true,237)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tlaxcala','Tlaxcala','','México',true,238)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('apizaco','Apizaco','','México',true,239)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('huamantla','Huamantla','','México',true,240)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tula','Tula','','México',true,241)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-del-carmen','Ciudad del Carmen','','México',true,242)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('salina-cruz','Salina Cruz','','México',true,243)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('juchitan','Juchitán','','México',true,244)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tehuantepec','Tehuantepec','','México',true,245)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tuxpan','Tuxpan','','México',true,246)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('martinez-de-la-torre','Martínez de la Torre','','México',true,247)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('acayucan','Acayucan','','México',true,248)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('papantla','Papantla','','México',true,249)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('silao','Silao','','México',true,250)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-miguel-el-alto','San Miguel el Alto','','México',true,251)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('arandas','Arandas','','México',true,252)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ameca','Ameca','','México',true,253)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-escondido','Puerto Escondido','','México',true,254)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('huatulco','Huatulco','','México',true,255)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('iguala','Iguala','','México',true,256)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('taxco','Taxco','','México',true,257)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zihuatanejo','Zihuatanejo','','México',true,258)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('lazaro-cardenas','Lázaro Cárdenas','','México',true,259)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('apatzingan','Apatzingán','','México',true,260)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zitacuaro','Zitácuaro','','México',true,261)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-piedad','La Piedad','','México',true,262)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sahuayo','Sahuayo','','México',true,263)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('matehuala','Matehuala','','México',true,264)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-valles','Ciudad Valles','','México',true,265)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('rio-verde','Río Verde','','México',true,266)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-mante','Ciudad Mante','','México',true,267)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('altamira','Altamira','','México',true,268)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sabinas','Sabinas','','México',true,269)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('monclova','Monclova','','México',true,270)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('acuna','Acuña','','México',true,271)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('parras-de-la-fuente','Parras de la Fuente','','México',true,272)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-buenaventura','San Buenaventura','','México',true,273)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('allende','Allende','','México',true,274)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('montemorelos','Montemorelos','','México',true,275)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('linares','Linares','','México',true,276)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cadereyta','Cadereyta','','México',true,277)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santiago','Santiago','','México',true,278)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('rosarito','Rosarito','','México',true,279)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tecate','Tecate','','México',true,280)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-quintin','San Quintín','','México',true,281)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-constitucion','Ciudad Constitución','','México',true,282)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guerrero-negro','Guerrero Negro','','México',true,283)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-penasco','Puerto Peñasco','','México',true,284)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cananea','Cananea','','México',true,285)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('agua-prieta','Agua Prieta','','México',true,286)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('empalme','Empalme','','México',true,287)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('caborca','Caborca','','México',true,288)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-fuerte','El Fuerte','','México',true,289)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guamuchil','Guamúchil','','México',true,290)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guasave','Guasave','','México',true,291)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('rosario','Rosario','','México',true,292)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santiago-de-queretaro','Santiago de Querétaro','','México',true,293)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-marques','El Marqués','','México',true,294)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tequisquiapan','Tequisquiapan','','México',true,295)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('corregidora','Corregidora','','México',true,296)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ixmiquilpan','Ixmiquilpan','','México',true,297)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tepeji-del-rio','Tepeji del Río','','México',true,298)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('actopan','Actopan','','México',true,299)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mineral-del-monte','Mineral del Monte','','México',true,300)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('izucar-de-matamoros','Izúcar de Matamoros','','México',true,301)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('huauchinango','Huauchinango','','México',true,302)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zacatlan','Zacatlán','','México',true,303)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tepeaca','Tepeaca','','México',true,304)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tlacotalpan','Tlacotalpan','','México',true,305)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-andres-tuxtla','San Andrés Tuxtla','','México',true,306)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tierra-blanca','Tierra Blanca','','México',true,307)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cosamaloapan','Cosamaloapan','','México',true,308)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('valladolid','Valladolid','','México',true,309)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tizimin','Tizimín','','México',true,310)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('progreso','Progreso','','México',true,311)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tekax','Tekax','','México',true,312)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('motul','Motul','','México',true,313)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tulum','Tulum','','México',true,314)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('felipe-carrillo-puerto','Felipe Carrillo Puerto','','México',true,315)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('isla-mujeres','Isla Mujeres','','México',true,316)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tenosique','Tenosique','','México',true,317)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('paraiso','Paraíso','','México',true,318)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('comalcalco','Comalcalco','','México',true,319)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cardenas','Cárdenas','','México',true,320)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('palenque','Palenque','','México',true,321)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ocosingo','Ocosingo','','México',true,322)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tonala','Tonalá','','México',true,323)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cintalapa','Cintalapa','','México',true,324)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('valle-de-bravo','Valle de Bravo','','México',true,325)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ixtapan-de-la-sal','Ixtapan de la Sal','','México',true,326)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tenancingo','Tenancingo','','México',true,327)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('teotihuacan','Teotihuacán','','México',true,328)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-salto','El Salto','','México',true,329)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('medellin','Medellín','','Colombia',true,330)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('barranquilla','Barranquilla','','Colombia',true,331)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cartagena','Cartagena','','Colombia',true,332)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pereira','Pereira','','Colombia',true,333)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santa-marta','Santa Marta','','Colombia',true,334)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ibague','Ibagué','','Colombia',true,335)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('manizales','Manizales','','Colombia',true,336)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cucuta','Cúcuta','','Colombia',true,337)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pasto','Pasto','','Colombia',true,338)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('monteria','Montería','','Colombia',true,339)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('neiva','Neiva','','Colombia',true,340)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('villavicencio','Villavicencio','','Colombia',true,341)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('armenia','Armenia','','Colombia',true,342)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('valledupar','Valledupar','','Colombia',true,343)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('popayan','Popayán','','Colombia',true,344)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sincelejo','Sincelejo','','Colombia',true,345)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tunja','Tunja','','Colombia',true,346)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('riohacha','Riohacha','','Colombia',true,347)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('buenaventura','Buenaventura','','Colombia',true,348)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('envigado','Envigado','','Colombia',true,349)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('itagui','Itagüí','','Colombia',true,350)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('bello','Bello','','Colombia',true,351)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('soledad','Soledad','','Colombia',true,352)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('palmira','Palmira','','Colombia',true,353)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tulua','Tuluá','','Colombia',true,354)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cartago','Cartago','','Colombia',true,355)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('buga','Buga','','Colombia',true,356)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('jamundi','Jamundí','','Colombia',true,357)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('yumbo','Yumbo','','Colombia',true,358)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('soacha','Soacha','','Colombia',true,359)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chia','Chía','','Colombia',true,360)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('facatativa','Facatativá','','Colombia',true,361)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zipaquira','Zipaquirá','','Colombia',true,362)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('fusagasuga','Fusagasugá','','Colombia',true,363)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mosquera','Mosquera','','Colombia',true,364)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('funza','Funza','','Colombia',true,365)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('madrid','Madrid','','Colombia',true,366)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('girardot','Girardot','','Colombia',true,367)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('barrancabermeja','Barrancabermeja','','Colombia',true,368)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('floridablanca','Floridablanca','','Colombia',true,369)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('piedecuesta','Piedecuesta','','Colombia',true,370)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ipiales','Ipiales','','Colombia',true,371)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tumaco','Tumaco','','Colombia',true,372)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('quibdo','Quibdó','','Colombia',true,373)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('apartado','Apartadó','','Colombia',true,374)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('turbo','Turbo','','Colombia',true,375)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('rionegro','Rionegro','','Colombia',true,376)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('caucasia','Caucasia','','Colombia',true,377)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sogamoso','Sogamoso','','Colombia',true,378)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('duitama','Duitama','','Colombia',true,379)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('paipa','Paipa','','Colombia',true,380)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('aguachica','Aguachica','','Colombia',true,381)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('maicao','Maicao','','Colombia',true,382)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('magangue','Magangué','','Colombia',true,383)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-andres','San Andrés','','Colombia',true,384)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('florencia','Florencia','','Colombia',true,385)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mocoa','Mocoa','','Colombia',true,386)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('yopal','Yopal','','Colombia',true,387)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('arauca','Arauca','','Colombia',true,388)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-jose-del-guaviare','San José del Guaviare','','Colombia',true,389)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('leticia','Leticia','','Colombia',true,390)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-carreno','Puerto Carreño','','Colombia',true,391)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('inirida','Inírida','','Colombia',true,392)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mitu','Mitú','','Colombia',true,393)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pitalito','Pitalito','','Colombia',true,394)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('garzon','Garzón','','Colombia',true,395)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chiquinquira','Chiquinquirá','','Colombia',true,396)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-dorada','La Dorada','','Colombia',true,397)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('espinal','Espinal','','Colombia',true,398)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('honda','Honda','','Colombia',true,399)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mariquita','Mariquita','','Colombia',true,400)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sabaneta','Sabaneta','','Colombia',true,401)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('caldas','Caldas','','Colombia',true,402)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('marinilla','Marinilla','','Colombia',true,403)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guarne','Guarne','','Colombia',true,404)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('copacabana','Copacabana','','Colombia',true,405)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('carmen-de-viboral','Carmen de Viboral','','Colombia',true,406)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('candelaria','Candelaria','','Colombia',true,407)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-cerrito','El Cerrito','','Colombia',true,408)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sevilla','Sevilla','','Colombia',true,409)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('caicedonia','Caicedonia','','Colombia',true,410)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santander-de-quilichao','Santander de Quilichao','','Colombia',true,411)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-tejada','Puerto Tejada','','Colombia',true,412)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('villa-del-rosario','Villa del Rosario','','Colombia',true,413)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ocana','Ocaña','','Colombia',true,414)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pamplona','Pamplona','','Colombia',true,415)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('dosquebradas','Dosquebradas','','Colombia',true,416)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santa-rosa-de-cabal','Santa Rosa de Cabal','','Colombia',true,417)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chinchina','Chinchiná','','Colombia',true,418)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('calarca','Calarcá','','Colombia',true,419)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('montenegro','Montenegro','','Colombia',true,420)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('quimbaya','Quimbaya','','Colombia',true,421)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('acacias','Acacías','','Colombia',true,422)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('granada','Granada','','Colombia',true,423)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-gaitan','Puerto Gaitán','','Colombia',true,424)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sahagun','Sahagún','','Colombia',true,425)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('lorica','Lorica','','Colombia',true,426)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cerete','Cereté','','Colombia',true,427)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('planeta-rica','Planeta Rica','','Colombia',true,428)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('montelibano','Montelíbano','','Colombia',true,429)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tierralta','Tierralta','','Colombia',true,430)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('arjona','Arjona','','Colombia',true,431)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-carmen-de-bolivar','El Carmen de Bolívar','','Colombia',true,432)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('turbaco','Turbaco','','Colombia',true,433)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('mompox','Mompox','','Colombia',true,434)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('corozal','Corozal','','Colombia',true,435)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-marcos','San Marcos','','Colombia',true,436)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sampues','Sampués','','Colombia',true,437)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cienaga','Ciénaga','','Colombia',true,438)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('fundacion','Fundación','','Colombia',true,439)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-banco','El Banco','','Colombia',true,440)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pivijay','Pivijay','','Colombia',true,441)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('plato','Plato','','Colombia',true,442)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sabanalarga','Sabanalarga','','Colombia',true,443)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('malambo','Malambo','','Colombia',true,444)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('galapa','Galapa','','Colombia',true,445)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-colombia','Puerto Colombia','','Colombia',true,446)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('baranoa','Baranoa','','Colombia',true,447)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('codazzi','Codazzi','','Colombia',true,448)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-jagua-de-ibirico','La Jagua de Ibirico','','Colombia',true,449)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('bosconia','Bosconia','','Colombia',true,450)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('curumani','Curumaní','','Colombia',true,451)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-juan-del-cesar','San Juan del Cesar','','Colombia',true,452)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('fonseca','Fonseca','','Colombia',true,453)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('villanueva','Villanueva','','Colombia',true,454)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-paso','El Paso','','Colombia',true,455)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-gil','San Gil','','Colombia',true,456)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('socorro','Socorro','','Colombia',true,457)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('barbosa','Barbosa','','Colombia',true,458)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('velez','Vélez','','Colombia',true,459)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('malaga','Málaga','','Colombia',true,460)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sabana-de-torres','Sabana de Torres','','Colombia',true,461)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-wilches','Puerto Wilches','','Colombia',true,462)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tibu','Tibú','','Colombia',true,463)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('abrego','Ábrego','','Colombia',true,464)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chinacota','Chinácota','','Colombia',true,465)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('los-patios','Los Patios','','Colombia',true,466)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('saravena','Saravena','','Colombia',true,467)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tame','Tame','','Colombia',true,468)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('villanueva','Villanueva','','Colombia',true,469)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('paz-de-ariporo','Paz de Ariporo','','Colombia',true,470)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tauramena','Tauramena','','Colombia',true,471)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('aguazul','Aguazul','','Colombia',true,472)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-asis','Puerto Asís','','Colombia',true,473)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('orito','Orito','','Colombia',true,474)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sibundoy','Sibundoy','','Colombia',true,475)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ipiales','Ipiales','','Colombia',true,476)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tuquerres','Túquerres','','Colombia',true,477)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-union','La Unión','','Colombia',true,478)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('barbacoas','Barbacoas','','Colombia',true,479)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('el-charco','El Charco','','Colombia',true,480)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guapi','Guapi','','Colombia',true,481)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('miranda','Miranda','','Colombia',true,482)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('caloto','Caloto','','Colombia',true,483)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-rico','Puerto Rico','','Colombia',true,484)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-boyaca','Puerto Boyacá','','Colombia',true,485)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-salgar','Puerto Salgar','','Colombia',true,486)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('guaduas','Guaduas','','Colombia',true,487)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('villeta','Villeta','','Colombia',true,488)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-vega','La Vega','','Colombia',true,489)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cajica','Cajicá','','Colombia',true,490)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sopo','Sopó','','Colombia',true,491)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('tocancipa','Tocancipá','','Colombia',true,492)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('cota','Cota','','Colombia',true,493)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sibate','Sibaté','','Colombia',true,494)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('caqueza','Cáqueza','','Colombia',true,495)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ubate','Ubaté','','Colombia',true,496)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('choconta','Chocontá','','Colombia',true,497)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('puerto-berrio','Puerto Berrío','','Colombia',true,498)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-ceja','La Ceja','','Colombia',true,499)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santa-fe-de-antioquia','Santa Fe de Antioquia','','Colombia',true,500)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('amaga','Amagá','','Colombia',true,501)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('andes','Andes','','Colombia',true,502)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ciudad-bolivar','Ciudad Bolívar','','Colombia',true,503)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('yarumal','Yarumal','','Colombia',true,504)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('segovia','Segovia','','Colombia',true,505)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('remedios','Remedios','','Colombia',true,506)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('san-pedro-de-los-milagros','San Pedro de los Milagros','','Colombia',true,507)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('sonson','Sonsón','','Colombia',true,508)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('santuario','Santuario','','Colombia',true,509)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('pradera','Pradera','','Colombia',true,510)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('florida','Florida','','Colombia',true,511)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('zarzal','Zarzal','','Colombia',true,512)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('ansermanuevo','Ansermanuevo','','Colombia',true,513)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('roldanillo','Roldanillo','','Colombia',true,514)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('belen-de-umbria','Belén de Umbría','','Colombia',true,515)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('la-virginia','La Virginia','','Colombia',true,516)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('anserma','Anserma','','Colombia',true,517)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('aguadas','Aguadas','','Colombia',true,518)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('supia','Supía','','Colombia',true,519)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('riosucio','Riosucio','','Colombia',true,520)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('libano','Líbano','','Colombia',true,521)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('chaparral','Chaparral','','Colombia',true,522)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;
insert into public.cities (slug,name,province,country,active,sort_order) values ('melgar','Melgar','','Colombia',true,523)
  on conflict (slug) do update set name=excluded.name,province=excluded.province,country=excluded.country,active=excluded.active,sort_order=excluded.sort_order;

-- ── SEO por página ──
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/','Terranode | Hosting, VPS y Servidores en Ecuador','Infraestructura cloud de alto rendimiento en Ecuador. Hosting LiteSpeed, VPS NVMe, Servidores Dedicados, Microsoft 365 y Desarrollo Web. DDoS 160 Gbps. Soporte 24/7.','hosting ecuador, vps ecuador, servidores ecuador, cloud ecuador, terranode','Terranode | Hosting, VPS y Servidores en Ecuador','Infraestructura cloud de alto rendimiento con DDoS 160 Gbps, NVMe y soporte técnico 24/7.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/nosotros','Nosotros | Terranode Ecuador','Conoce al equipo detrás de Terranode. Desde 2016 brindando soluciones cloud de calidad en Ecuador con datacenter propio en Guayaquil y presencia en USA.','terranode nosotros, hosting ecuador empresa, quienes somos terranode','Nosotros | Terranode Ecuador','Desde 2016 brindando soluciones cloud de calidad en Ecuador.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/hosting','Hosting Web en Ecuador | LiteSpeed + cPanel | Terranode','Hosting web profesional en Ecuador con LiteSpeed, CloudLinux y cPanel. Desde $40/año. SSL gratis, backups diarios, DDoS 160 Gbps y soporte 24/7.','hosting ecuador, hosting web ecuador, cpanel ecuador, litespeed hosting, alojamiento web ecuador','Hosting Web en Ecuador | LiteSpeed + cPanel','Hosting profesional desde $40/año con LiteSpeed, SSL gratis y soporte 24/7.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/vps','VPS Server NVMe Ecuador | KVM | Terranode','Servidores VPS con virtualización KVM, NVMe DDR4 y deploy en 60 segundos. Desde $2.99/mes. Root access completo, 10 Gbps y protección DDoS. Ecuador y USA.','vps ecuador, vps nvme, servidor virtual ecuador, kvm vps, vps barato ecuador','VPS Server NVMe Ecuador | Desde $2.99/mes','VPS KVM con NVMe DDR4 y deploy en 60 segundos. Root access completo.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/servidores-dedicados','Servidores Dedicados Ecuador | Intel Xeon | Terranode','Servidores dedicados con procesadores Intel Xeon, RAM DDR4 ECC y NVMe. Desde $47.99/mes. Hardware exclusivo, IPMI remoto, DDoS 160 Gbps. Ecuador y USA.','servidores dedicados ecuador, servidor dedicado, bare metal ecuador, intel xeon ecuador','Servidores Dedicados Ecuador | Intel Xeon desde $47.99/mes','Hardware exclusivo con Intel Xeon, NVMe y puerto 10 Gbps.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/email','TerraMail | Correo Corporativo Ecuador | Terranode','Correo corporativo profesional con tu dominio. Antispam avanzado, webmail OX App Suite, sincronización móvil y SSL. Desde $24.99/año. Ecuador.','correo corporativo ecuador, email empresarial ecuador, terramail, correo con dominio propio','TerraMail | Correo Corporativo con tu Dominio','Email profesional con antispam, webmail moderno y soporte 24/7. Desde $24.99/año.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/m365','Microsoft 365 Ecuador | Partner Oficial | Terranode','Venta y soporte de Microsoft 365 en Ecuador. Exchange Online, Business Basic y Standard. Migración gratuita, factura local y soporte 24/7 en español. Partner certificado.','microsoft 365 ecuador, office 365 ecuador, teams ecuador, exchange online ecuador, m365 partner','Microsoft 365 Ecuador | Partner Oficial Microsoft','M365 con soporte local en español, migración gratis y factura ecuatoriana.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/desarrollo-web','Desarrollo Web y Tiendas Online Ecuador | WordPress | Terranode','Diseño web profesional y e-commerce con WordPress y WooCommerce en Ecuador. Landing pages, sitios corporativos y tiendas online. SEO incluido. Desde $350.','desarrollo web ecuador, diseño web ecuador, tienda online ecuador, wordpress ecuador, woocommerce ecuador','Desarrollo Web y E-Commerce Ecuador | WordPress','Sitios web y tiendas online con WordPress. Diseño profesional, SEO y hosting incluido.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/desarrollo-sistemas','Desarrollo de Software a Medida Ecuador | React + Node.js | Terranode','Desarrollo de sistemas web, ERPs, CRMs y automatización de procesos en Ecuador. React, Node.js, PostgreSQL. Integración con SRI Ecuador, APIs y pasarelas de pago.','desarrollo software ecuador, sistema a medida ecuador, erp ecuador, crm ecuador, automatización procesos ecuador','Desarrollo de Software a Medida Ecuador | React + Node.js','Sistemas web, ERPs, CRMs y automatización de procesos. Integración SRI Ecuador.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/blog','Blog Terranode | Tutoriales Hosting, Linux y WordPress','Guías técnicas, tutoriales y artículos sobre hosting, Linux, WordPress, VPS, seguridad web y desarrollo. Aprende con el equipo de Terranode Ecuador.','blog hosting ecuador, tutoriales linux, wordpress hosting, vps tutorial, blog terranode','Blog Terranode | Tutoriales y Guías Técnicas','Guías sobre hosting, Linux, WordPress, VPS y seguridad web.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;
insert into public.site_seo (path,title,description,keywords,og_title,og_description) values ('/contacto','Contacto | Terranode Ecuador | Soporte 24/7','Contáctanos por WhatsApp, email, ticket o Discord. Soporte técnico 24/7 para hosting, VPS, servidores y desarrollo web en Ecuador. Respuesta en menos de 1 hora.','contacto terranode, soporte hosting ecuador, whatsapp terranode, ticket soporte','Contacto | Terranode Ecuador','Soporte 24/7 por WhatsApp, email y ticket. Respuesta en menos de 1 hora.')
  on conflict (path) do update set title=excluded.title,description=excluded.description,keywords=excluded.keywords,og_title=excluded.og_title,og_description=excluded.og_description;

-- ── Ajustes de marca / SMTP / facturación (filas únicas) ──
insert into public.brand_settings (id,data) values (1,'{"siteName": "Terranode", "legalNameEC": "Terranode S.A.S", "legalNameUS": "Terranode LLC", "email": "info@terranode.net", "phone": "+593 99 819 7150", "whatsappSupport": "https://wa.link/nooz4l", "whatsappSales": "https://wa.link/03c1ug", "discord": "https://discord.com/invite/VAAQ6rDXRE", "clientPortal": "https://my.terranode.net", "ticketUrl": "https://my.terranode.net/submitticket", "address": "Guayaquil, Ecuador"}'::jsonb)
  on conflict (id) do nothing;
insert into public.smtp_config (id,data) values (1,'{}'::jsonb) on conflict (id) do nothing;
insert into public.billing_settings (id,data) values (1,'{}'::jsonb) on conflict (id) do nothing;

-- ============================================================================
-- FIN DEL SEED
-- ============================================================================

-- ============================================================================
-- PASO FINAL -- CONVIERTETE EN ADMINISTRADOR
-- ============================================================================
-- 1. Ve a Authentication -> Users -> "Add user" -> crea tu usuario (email + contrasena)
--    Marca "Auto Confirm User" para no tener que confirmar por correo.
-- 2. Copia el UUID del usuario creado y ejecuta esta consulta reemplazando los valores:
--
--    insert into public.admin_users (user_id, email)
--    values ('PEGA-AQUI-EL-UUID', 'tu@correo.com');
--
-- Sin este paso podras ENTRAR al panel pero NO podras guardar cambios.
-- ============================================================================
