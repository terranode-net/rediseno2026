import { createServerClient, type CookieOptionsWithName } from '@supabase/ssr';
import type { AstroCookies } from 'astro';

const url = import.meta.env.PUBLIC_SUPABASE_URL;
const anonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

const cookieOptions: CookieOptionsWithName = {
  path: '/',
  sameSite: 'lax',
  secure: true,
  httpOnly: true,
  maxAge: 60 * 60 * 24 * 7, // 7 días
};

/**
 * Cliente de Supabase para usar en middleware / páginas .astro server-side.
 * Lee la sesión de auth directamente del header "Cookie" de la request (AstroCookies
 * no tiene forma de listar todas las cookies, solo de leer una por nombre), y escribe
 * la sesión nueva vía Astro.cookies.set(), para que el login persista entre navegaciones (SSR).
 */
export function createSupabaseServerClient(cookies: AstroCookies, request: Request) {
  return createServerClient(url, anonKey, {
    cookieOptions,
    cookies: {
      getAll() {
        const header = request.headers.get('cookie') ?? '';
        return header
          .split(';')
          .map((pair) => pair.trim())
          .filter(Boolean)
          .map((pair) => {
            const idx = pair.indexOf('=');
            const name = idx === -1 ? pair : pair.slice(0, idx);
            const value = idx === -1 ? '' : decodeURIComponent(pair.slice(idx + 1));
            return { name, value };
          });
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value, options }) => {
          cookies.set(name, value, { ...cookieOptions, ...(options as any) });
        });
      },
    },
  });
}

/** Devuelve el usuario actual (o null) y si es admin, en un solo viaje. */
export async function getAdminSession(cookies: AstroCookies, request: Request) {
  const supabase = createSupabaseServerClient(cookies, request);
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return { supabase, user: null, isAdmin: false };

  const { data: adminRow } = await supabase
    .from('admin_users')
    .select('user_id')
    .eq('user_id', user.id)
    .maybeSingle();

  return { supabase, user, isAdmin: !!adminRow };
}
