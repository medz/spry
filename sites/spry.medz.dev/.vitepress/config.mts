import { defineConfig } from 'vitepress';

const siteUrl = 'https://spry.medz.dev';
const siteName = 'Spry';
const defaultDescription =
  'Next-generation Dart server framework. Build modern servers and deploy them to the runtime you prefer.';
const socialImage = `${siteUrl}/og-card.svg`;

function resolveCanonicalPath(relativePath: string) {
  if (relativePath === 'index.md') {
    return '/';
  }

  return `/${relativePath}`
    .replace(/\/index\.md$/, '/')
    .replace(/\.md$/, '')
    .replace(/\/+/g, '/');
}

export default defineConfig({
  lang: 'en-US',
  title: siteName,
  titleTemplate: ':title · Spry',
  description: defaultDescription,
  cleanUrls: true,
  lastUpdated: true,
  sitemap: {
    hostname: siteUrl,
  },
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/spry.svg' }],
    ['meta', { name: 'application-name', content: siteName }],
    ['meta', { name: 'author', content: 'Seven Du' }],
    [
      'meta',
      {
        name: 'keywords',
        content:
          'Spry, Dart, server framework, backend, file routing, cross-runtime, Node.js, Bun, Cloudflare Workers, Vercel',
      },
    ],
    ['meta', { name: 'robots', content: 'index, follow' }],
    ['meta', { name: 'theme-color', media: '(prefers-color-scheme: light)', content: '#f5f2ea' }],
    ['meta', { name: 'theme-color', media: '(prefers-color-scheme: dark)', content: '#0e141d' }],
    ['meta', { property: 'og:site_name', content: siteName }],
    ['meta', { property: 'og:locale', content: 'en_US' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:image', content: socialImage }],
    ['meta', { property: 'og:image:type', content: 'image/svg+xml' }],
    ['meta', { property: 'og:image:width', content: '1200' }],
    ['meta', { property: 'og:image:height', content: '630' }],
    ['meta', { property: 'og:image:alt', content: 'Spry documentation' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:site', content: '@shiweidu' }],
    ['meta', { name: 'twitter:creator', content: '@shiweidu' }],
    ['meta', { name: 'twitter:image', content: socialImage }],
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    [
      'link',
      {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap',
      },
    ],
  ],
  transformHead({ pageData, title, description }) {
    const canonicalUrl = `${siteUrl}${resolveCanonicalPath(pageData.relativePath)}`;
    const pageDescription = description || defaultDescription;

    return [
      ['link', { rel: 'canonical', href: canonicalUrl }],
      ['meta', { property: 'og:title', content: title }],
      ['meta', { property: 'og:description', content: pageDescription }],
      ['meta', { property: 'og:url', content: canonicalUrl }],
      ['meta', { name: 'twitter:title', content: title }],
      ['meta', { name: 'twitter:description', content: pageDescription }],
    ];
  },
  themeConfig: {
    siteTitle: siteName,
    logo: {
      src: '/spry.svg',
      alt: 'Spry',
    },
    search: {
      provider: 'local',
    },
    editLink: {
      pattern: 'https://github.com/medz/spry/edit/main/sites/spry.medz.dev/:path',
      text: 'Edit this page on GitHub',
    },
    nav: [
      { text: 'Docs', link: '/getting-started' },
      { text: 'Runtime', link: '/server' },
      { text: 'Config', link: '/config' },
      { text: 'Deploy', link: '/deploy/' },
      { text: 'Migration', link: '/migration' },
    ],
    sidebar: [
      {
        text: 'Overview',
        items: [
          { text: 'What is Spry', link: '/what-is-spry' },
          { text: 'Getting Started', link: '/getting-started' },
        ],
      },
      {
        text: 'Guide',
        items: [
          { text: 'Project Structure', link: '/guide/app' },
          { text: 'File Routing', link: '/guide/routing' },
          { text: 'Middleware and Errors', link: '/guide/handler' },
          { text: 'Assets', link: '/guide/assets' },
          { text: 'Lifecycle', link: '/guide/lifecycle' },
          { text: 'Request Context', link: '/guide/event' },
        ],
      },
      {
        text: 'Runtime',
        items: [
          { text: 'Cross-Platform Server', link: '/server' },
          { text: 'Configuration', link: '/config' },
        ],
      },
      {
        text: 'Deploy',
        items: [
          { text: 'Overview', link: '/deploy/' },
          { text: 'Dart VM', link: '/deploy/dart' },
          { text: 'Node.js', link: '/deploy/node' },
          { text: 'Bun', link: '/deploy/bun' },
          { text: 'Cloudflare Workers', link: '/deploy/cloudflare' },
          { text: 'Vercel', link: '/deploy/vercel' },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'Migration Guide', link: '/migration' },
          {
            text: 'API Reference',
            link: 'https://pub.dev/documentation/spry/latest/spry/',
          },
          { text: 'Changelog', link: '/changelog' },
        ],
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/medz/spry' },
      { icon: 'x', link: 'https://twitter.com/shiweidu' },
    ],
    outline: {
      level: [2, 3],
      label: 'On this page',
    },
    footer: {
      message: 'Released under the MIT License.',
      copyright: `Copyright © ${new Date().getFullYear()} Seven Du`,
    },
  },
});
