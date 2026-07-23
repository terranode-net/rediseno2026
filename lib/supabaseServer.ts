import { createClient } from '@supabase/supabase-js';

// Cliente de solo lectura para renderizado en servidor (SSR).
// Usa la clave pública/anon: las políticas RLS garantizan que solo
// se pueda LEER contenido público, nunca escribir.
const url = import.meta.env.PUBLIC_SUPABASE_URL;
const anonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

export const supabaseServer = createClient(url, anonKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});
