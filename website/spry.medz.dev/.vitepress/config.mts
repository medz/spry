import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Spry',
  titleTemplate: ':title · Spry',
  description:
    'Spry is a file-routing-first Dart framework for shipping server code across Dart, Node, Bun, Cloudflare, and Vercel.',
  cleanUrls: true,
  lastUpdated: true,
  sitemap: {
    hostname: 'https://spry.medz.dev',
  },
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/spry.svg' }],
    ['meta', { name: 'theme-color', content: '#0d1320' }],
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
  themeConfig: {
    siteTitle: 'Spry',
    logo: {
      src: '/spry.svg',
      alt: 'Spry',
    },
    search: {
      provider: 'local',
    },
    editLink: {
      pattern: 'https://github.com/medz/spry/edit/main/website/spry.medz.dev/:path',
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
