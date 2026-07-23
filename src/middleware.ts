import { defineMiddleware } from 'astro:middleware';
import { getAdminSession } from './lib/supabaseServerAuth';

export const onRequest = defineMiddleware(async (context, next) => {
  const { pathname } = context.url;

  if (!pathname.startsWith('/admin')) {
    return next();
  }

  // La propia página de login no requiere sesión.
  if (pathname === '/admin/login' || pathname === '/admin/login/') {
    return next();
  }

  const { user, isAdmin } = await getAdminSession(context.cookies, context.request);

  if (!user) {
    return context.redirect('/admin/login');
  }

  if (!isAdmin) {
    // Usuario válido en Supabase Auth pero sin fila en admin_users.
    return context.redirect('/admin/login?error=no_autorizado');
  }

  return next();
});
