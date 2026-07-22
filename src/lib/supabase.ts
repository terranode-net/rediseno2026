import { createClient } from '@supabase/supabase-js';

// Estas variables deben configurarse en Vercel (Project Settings → Environment Variables)
// y en un archivo .env local para desarrollo. Ver .env.example.
const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface ContactSubmission {
  name: string;
  email: string;
  phone?: string;
  company?: string;
  service_interest: string;
  message: string;
  locale: 'es' | 'en';
  source_page: string;
}
