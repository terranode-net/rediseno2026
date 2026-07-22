export interface BlogPost {
  id: number;
  slug: string;
  featured?: boolean;
  category: string;
  date: string;
  readTime: string;
  title: string;
  excerpt: string;
  tags: string[];
  author: string;
}

export const POSTS: BlogPost[] = [
  { id: 1, slug: 'plugins-nulled-wordpress', featured: true, category: 'WordPress', date: '2 Abr 2025', readTime: '5 min', title: '¿Qué Son los Plugins Activados, Nulled y de Código Original en WordPress?', excerpt: 'Si eres nuevo en WordPress o llevas un tiempo usándolo, probablemente te hayas topado con términos confusos como plugins nulled o activados. Te explicamos todo lo que necesitas saber.', tags: ['WordPress', 'Seguridad', 'Plugins'], author: 'Equipo Terranode' },
  { id: 2, slug: 'cuando-usar-rem-em-css', category: 'Programming', date: '27 Mar 2025', readTime: '4 min', title: '¿Cuándo Usar %, rem o em en CSS?', excerpt: 'Si estás trabajando en un sitio web WordPress y quieres mejorar la experiencia de tus visitantes, entender las unidades CSS es fundamental para un diseño responsivo perfecto.', tags: ['CSS', 'WordPress', 'Frontend'], author: 'Equipo Terranode' },
  { id: 3, slug: 'codigos-estados-http', category: 'Server', date: '13 Mar 2025', readTime: '7 min', title: 'Códigos de Estado HTTP: Qué Son, Por Qué Ocurren y Cómo Solucionarlos', excerpt: 'Los códigos de errores web son una parte fundamental del funcionamiento de cualquier sitio. Aprende a interpretar los más comunes como 404, 500, 301 y cómo resolverlos.', tags: ['HTTP', 'Servidor', 'Diagnóstico'], author: 'Equipo Terranode' },
  { id: 4, slug: 'linux-comandos-esenciales-vps', category: 'Linux', date: '5 Mar 2025', readTime: '6 min', title: '30 Comandos Linux Esenciales para Administrar tu VPS', excerpt: 'Aprende los comandos más importantes para administrar tu VPS desde la terminal: gestión de procesos, permisos, redes, usuarios y monitoreo del sistema.', tags: ['Linux', 'VPS', 'Terminal'], author: 'Equipo Terranode' },
  { id: 5, slug: 'nginx-vs-apache-diferencias', category: 'Nginx', date: '20 Feb 2025', readTime: '5 min', title: 'Nginx vs Apache: ¿Cuál es Mejor para tu Servidor en 2025?', excerpt: 'Comparativa completa entre los dos servidores web más populares del mundo. Rendimiento, configuración, casos de uso y cuál elegir para tu proyecto.', tags: ['Nginx', 'Apache', 'Performance'], author: 'Equipo Terranode' },
  { id: 6, slug: 'configurar-ssl-cpanel', category: 'cPanel', date: '10 Feb 2025', readTime: '3 min', title: "Cómo Configurar SSL Gratis en cPanel con Let's Encrypt", excerpt: "Guía paso a paso para instalar y configurar un certificado SSL gratuito en cPanel usando AutoSSL y Let's Encrypt. Protege tu sitio en menos de 5 minutos.", tags: ['SSL', 'cPanel', 'Seguridad'], author: 'Equipo Terranode' },
  { id: 7, slug: 'backup-automatico-vps', category: 'Backup', date: '28 Ene 2025', readTime: '6 min', title: 'Cómo Configurar Backups Automáticos en tu VPS con rsync', excerpt: 'Aprende a crear un sistema de respaldos automáticos con rsync y cron en Linux. Protege tus datos con backups incrementales eficientes.', tags: ['Backup', 'Linux', 'VPS'], author: 'Equipo Terranode' },
  { id: 8, slug: 'microsoft-365-beneficios-empresa', category: 'Technologies', date: '15 Ene 2025', readTime: '4 min', title: 'Por Qué tu Empresa Necesita Microsoft 365 en 2025', excerpt: 'Descubre cómo Microsoft 365 puede transformar la productividad de tu equipo con Teams, Exchange Online, OneDrive y las herramientas de Office en la nube.', tags: ['Microsoft 365', 'Productividad', 'Cloud'], author: 'Equipo Terranode' },
  { id: 9, slug: 'ddos-proteccion-explicada', category: 'Security', date: '3 Ene 2025', readTime: '5 min', title: '¿Qué es la Protección DDoS y Cómo Funciona en Terranode?', excerpt: 'Explicamos cómo funciona la mitigación DDoS de 160 Gbps en nuestra red, qué tipos de ataques detectamos y por qué tu servicio nunca se interrumpe durante un ataque.', tags: ['DDoS', 'Seguridad', 'Infraestructura'], author: 'Equipo Terranode' },
];

export const CATEGORIES = ['Todos', 'WordPress', 'Linux', 'Server', 'Nginx', 'cPanel', 'Security', 'Backup', 'Technologies', 'Programming', 'VPS', 'Script', 'Infrastructure'];

export const CAT_COLORS: Record<string, string> = {
  WordPress: '#3B82F6', Linux: '#22C55E', Server: '#F59E0B', Nginx: '#10B981',
  cPanel: '#8B5CF6', Security: '#EF4444', Backup: '#06B6D4', Technologies: '#EC4899',
  Programming: '#F97316', VPS: '#3B82F6', Script: '#6366F1', Infrastructure: '#84CC16',
};

export const GRADIENTS: Record<string, string> = {
  WordPress: 'linear-gradient(135deg,#1e3a5f,#0f2640)',
  Linux: 'linear-gradient(135deg,#1a3322,#0d1f14)',
  Server: 'linear-gradient(135deg,#3d2a0a,#1f1505)',
  Nginx: 'linear-gradient(135deg,#0d3322,#071a12)',
  cPanel: 'linear-gradient(135deg,#2d1a4a,#160d24)',
  Security: 'linear-gradient(135deg,#3d1212,#1f0909)',
  Backup: 'linear-gradient(135deg,#0d2d3a,#061720)',
  Technologies: 'linear-gradient(135deg,#3a0d28,#1f0715)',
  Programming: 'linear-gradient(135deg,#3d1a0a,#1f0d05)',
  default: 'linear-gradient(135deg,#0f1e36,#070d1a)',
};

export interface PostSection {
  h: string;
  body: string;
}
export interface FullPost {
  category: string;
  date: string;
  readTime: string;
  title: string;
  author: string;
  authorRole: string;
  tags: string[];
  intro: string;
  sections: PostSection[];
  conclusion: string;
  related: { slug: string; title: string; cat: string }[];
}

export const POSTS_DB: Record<string, FullPost> = {
  'plugins-nulled-wordpress': {
    category: 'WordPress', date: '2 Abril 2025', readTime: '5 min',
    title: '¿Qué Son los Plugins Activados, Nulled y de Código Original en WordPress?',
    author: 'Equipo Terranode', authorRole: 'Editorial',
    tags: ['WordPress', 'Seguridad', 'Plugins'],
    intro: 'Si eres nuevo en WordPress o llevas tiempo usándolo, probablemente te hayas topado con términos confusos al buscar plugins premium como Elementor, WooCommerce o WPML. Esta guía te explica todo.',
    sections: [
      { h: '¿Qué es un plugin de código original?', body: 'Un plugin de código original es aquel que adquieres directamente del desarrollador o en su marketplace oficial. Obtienes la licencia, actualizaciones automáticas, soporte técnico y la garantía de que el código no ha sido modificado. Ejemplos: Elementor Pro desde elementor.com, WooCommerce Extensions desde woocommerce.com, WPML desde wpml.org.' },
      { h: "¿Qué es un plugin nulled?", body: 'Un plugin nulled (o anulado) es una versión pirateada de un plugin premium. El código de validación de licencia ha sido eliminado o modificado para que funcione sin pagar. Se distribuyen en sitios no oficiales, foros o grupos de Telegram. Aunque parezca una opción económica, conlleva riesgos graves.' },
      { h: "¿Qué es un plugin 'activado'?", body: "El término 'activado' es un eufemismo que se usa en comunidades de habla hispana para referirse exactamente a los plugins nulled. No existe diferencia técnica entre ambos — es simplemente software pirateado con otro nombre para parecer menos sospechoso." },
      { h: 'Riesgos reales de usar plugins nulled', body: 'Los riesgos van desde infecciones de malware y backdoors ocultos que comprometen tu servidor, hasta el robo de datos de tus clientes, pérdida de posicionamiento SEO por Google al detectar código malicioso, y la imposibilidad de actualizar el plugin (quedando expuesto a vulnerabilidades conocidas). Muchos servidores se hackean cada mes por esta causa.' },
      { h: '¿Vale la pena el ahorro?', body: 'Piénsalo así: un plugin premium puede costar $50-100/año. Un hackeo puede costarte horas de trabajo, pérdida de datos, penalizaciones SEO y la confianza de tus clientes. La matemática es clara. Si no puedes pagar un plugin, busca alternativas gratuitas en el repositorio oficial de WordPress.org — hay miles de calidad.' },
    ],
    conclusion: 'La recomendación es siempre clara: usa software original. Si tienes un sitio en nuestro hosting, nuestro sistema Imunify360 detecta y bloquea código malicioso automáticamente, pero la mejor defensa es no instalar software comprometido desde el inicio.',
    related: [
      { slug: 'configurar-ssl-cpanel', title: 'Cómo Configurar SSL Gratis en cPanel', cat: 'cPanel' },
      { slug: 'codigos-estados-http', title: 'Códigos de Estado HTTP explicados', cat: 'Server' },
      { slug: 'linux-comandos-esenciales-vps', title: '30 Comandos Linux para tu VPS', cat: 'Linux' },
    ],
  },
  'cuando-usar-rem-em-css': {
    category: 'Programming', date: '27 Mar 2025', readTime: '4 min',
    title: '¿Cuándo Usar %, rem o em en CSS?',
    author: 'Equipo Terranode', authorRole: 'Editorial',
    tags: ['CSS', 'WordPress', 'Frontend'],
    intro: 'Una de las preguntas más frecuentes al trabajar con CSS es qué unidad de medida usar. La respuesta correcta depende del contexto, y entenderlo marca la diferencia entre un diseño responsivo perfecto y uno que se rompe en ciertos dispositivos.',
    sections: [
      { h: 'La unidad % (porcentaje)', body: 'El porcentaje es relativo al elemento padre. Si un contenedor mide 500px y defines un hijo con width: 50%, ese hijo tendrá 250px. Es ideal para layouts fluidos: anchuras de columnas, imágenes responsivas y contenedores que deben adaptarse al espacio disponible.' },
      { h: 'La unidad rem (root em)', body: 'rem es relativo al tamaño de fuente del elemento raíz (html), que por defecto en los navegadores es 16px. Entonces 1rem = 16px, 2rem = 32px. Es la unidad más recomendada para tipografía y espaciado, porque respeta la configuración de accesibilidad del usuario en el navegador.' },
      { h: 'La unidad em', body: "em es relativo al tamaño de fuente del elemento padre inmediato. Esto puede generar 'efecto cascada' si se anidan múltiples elementos con em. Es útil para componentes self-contained donde quieres que todo escale proporcionalmente al texto del componente." },
      { h: 'Guía rápida de cuándo usar cada una', body: 'Usa % para: anchos de layout, imágenes responsivas, columnas de grid. Usa rem para: font-size, padding, margin, espaciado global — todo lo que debe ser consistente en toda la página. Usa em para: padding/margin relativo al texto del propio componente (botones, etiquetas). Evita mezclarlos sin razón clara.' },
    ],
    conclusion: 'La clave es la consistencia: elige rem para la mayoría de los casos de espaciado y tipografía, % para layouts, y reserva em para componentes específicos. Tu CSS será más predecible y fácil de mantener.',
    related: [
      { slug: 'plugins-nulled-wordpress', title: 'Plugins nulled en WordPress: los riesgos', cat: 'WordPress' },
      { slug: 'codigos-estados-http', title: 'Códigos HTTP explicados', cat: 'Server' },
    ],
  },
};

export const DEFAULT_POST_TEMPLATE = (post: BlogPost): FullPost => ({
  category: post.category, date: post.date, readTime: post.readTime,
  title: post.title, author: post.author, authorRole: 'Editorial', tags: post.tags,
  intro: post.excerpt,
  sections: [
    { h: 'Sobre este artículo', body: 'El contenido completo de este artículo estará disponible próximamente. Mientras tanto, explora los demás artículos de nuestro blog o contacta a nuestro equipo si tienes preguntas específicas.' },
  ],
  conclusion: 'Visita nuestro blog frecuentemente para encontrar nuevo contenido sobre hosting, VPS, seguridad web y desarrollo.',
  related: POSTS.filter((p) => p.slug !== post.slug).slice(0, 3).map((p) => ({ slug: p.slug, title: p.title, cat: p.category })),
});

export function getFullPost(slug: string): FullPost {
  if (POSTS_DB[slug]) return POSTS_DB[slug];
  const post = POSTS.find((p) => p.slug === slug);
  if (post) return DEFAULT_POST_TEMPLATE(post);
  return DEFAULT_POST_TEMPLATE(POSTS[0]);
}
