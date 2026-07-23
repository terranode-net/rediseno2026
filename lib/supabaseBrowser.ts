import { createBrowserClient } from '@supabase/ssr';

const url = import.meta.env.PUBLIC_SUPABASE_URL;
const anonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

/**
 * Cliente de Supabase para el navegador, usado SOLO dentro del panel /admin.
 * Comparte sesión (vía cookies) con el middleware del servidor, así que
 * las escrituras van autenticadas y pasan las políticas RLS "admin write".
 */
export const supabaseBrowser = createBrowserClient(url, anonKey);
