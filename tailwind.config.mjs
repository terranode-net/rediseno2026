/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,ts,tsx,md,mdx}'],
  theme: {
    extend: {
      colors: {
        ink: {
          DEFAULT: '#080E1C',
          2: '#0F1B33',
          3: '#16234A',
        },
        surface: {
          DEFAULT: '#F6F8FC',
          muted: '#EEF2F8',
        },
        accent: {
          DEFAULT: '#2D12ED',
          hover: '#2410C4',
          soft: '#EEEAFE',
        },
        signal: {
          DEFAULT: '#3EC821',
          soft: '#E9FBE4',
        },
        slate: {
          50: '#F6F8FB',
          100: '#EDF1F7',
          200: '#DDE4EF',
          300: '#C3CEDF',
          400: '#8E9DB8',
          500: '#5B6B85',
          600: '#43526B',
          700: '#2E3B52',
          800: '#1B2740',
          900: '#0F1830',
        },
      },
      fontFamily: {
        display: ['"Instrument Sans"', 'system-ui', 'sans-serif'],
        body: ['"Metrophobic"', 'system-ui', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'ui-monospace', 'monospace'],
      },
      backgroundImage: {
        'grid-fade':
          'linear-gradient(180deg, rgba(45,18,237,0.08) 0%, rgba(8,14,28,0) 60%)',
        'noise': "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='120' height='120'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.035'/%3E%3C/svg%3E\")",
      },
      boxShadow: {
        card: '0 1px 2px rgba(15,24,48,0.06), 0 8px 24px -8px rgba(15,24,48,0.12)',
        'card-hover': '0 4px 12px rgba(15,24,48,0.08), 0 24px 48px -16px rgba(45,18,237,0.18)',
        glow: '0 0 0 1px rgba(45,18,237,0.15), 0 0 40px rgba(45,18,237,0.15)',
      },
      borderRadius: {
        xl2: '1.25rem',
      },
      maxWidth: {
        content: '1200px',
      },
    },
  },
  plugins: [],
};
