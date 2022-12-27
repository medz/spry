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
  },
}

