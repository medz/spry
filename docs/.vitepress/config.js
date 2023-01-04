export default {
  lang: 'en-US',
  title: 'Spry',
  description: 'Spry is an HTTP middleware framework for Dart to make web applications and APIs more enjoyable to write.',

  head: [['meta', { name: 'theme-color', content: '#5E6CE7' }]],

  themeConfig: {
    // Edit link
    editLink: {
      pattern: 'https://github.com/odroe/spry/edit/main/docs/:path',
      text: 'Edit this page on GitHub',
    },

    // Footer
    footer: {
      copyright: `Copyright © 2014-${new Date().getFullYear()} Odroe Inc.`,
      message: 'Released under the MIT license.',
    },

    // Nav bar
    nav: [
      { text: 'Guides', link: '/guides/introduction' },
      {
        text: 'Ecosystem',
        items: [
          { text: 'Router', link: '/ecosystem/router' },
          { text: 'Interceptor', link: '/ecosystem/interceptor' },
          { text: 'JSON', link: '/ecosystem/json' },
          { text: 'Session', link: '/ecosystem/session' },
          { text: 'Static', link: '/ecosystem/static' },
        ],
      },
      {
        text: 'API Reference',
        items: [
          { text: 'Spry framework', link: 'https://pub.dev/documentation/spry/latest/' },
          { text: 'Spry Router', link: 'https://pub.dev/documentation/spry_router/latest/' },
          { text: 'Spry Interceptor', link: 'https://pub.dev/documentation/spry_interceptor/latest/' },
          { text: 'Spry JSON', link: 'https://pub.dev/documentation/spry_json/latest/' },
          { text: 'Sory Session', link: 'https://pub.dev/documentation/spry_session/latest/' },
        ],
      },
    ],

    // Sidebar
    sidebar: [
      {
        text: 'Guides',
        items: [
          { text: 'Waht is Spry?', link: '/guides/introduction' },
          { text: 'Getting Started', link: '/guides/getting-started' },
          { text: 'Application', link: '/guides/application' },
          { text: 'Context', link: '/guides/context' },
          { text: 'Middleware', link: '/guides/middleware' },
          { text: 'Request', link: '/guides/request' },
          { text: 'Response', link: '/guides/response' },
        ],
      },
      {
        text: 'Ecosystem',
        items: [
          { text: 'Router', link: '/ecosystem/router' },
          { text: 'Interceptor', link: '/ecosystem/interceptor' },
          { text: 'JSON', link: '/ecosystem/json' },
          { text: 'Session', link: '/ecosystem/session' },
          { text: 'Static', link: '/ecosystem/static' },
        ],
      },
    ],
  },
}

