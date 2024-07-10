import { defineConfig } from "vitepress";

export default defineConfig({
  title: "Spry",
  titleTemplate: "Spry: :title",
  description:
    "Spry is a lightweight, composable Dart web framework designed to work collaboratively with various runtime platforms.",
  head: [["link", { rel: "icon", type: "image/svg+xml", href: "/spry.svg" }]],
  sitemap: {
    hostname: "https://spry.fun",
  },
  cleanUrls: true,
  themeConfig: {
    logo: {
      src: "/spry.svg",
      alt: "Spry",
    },
    editLink: {
      pattern: "https://github.com/medz/spry/edit/main/docs/:path",
    },
    nav: [
      {
        text: "Guide",
        link: "/guide/what-is-spry",
        activeMatch: "^/guide/.*?",
      },
      {
        text: "Platforms",
        link: "/platforms/",
        activeMatch: "^/platforms/.*?",
      },
      {
        text: "Examples",
        link: "https://github.com/medz/spry/tree/main/examples",
      },
    ],
    sidebar: {
      "/guide": [
        { text: "What is Spry?", link: "/guide/what-is-spry" },
        {
          text: "Getting Started",
          link: "/guide/getting-started",
        },
      ],
    },
    socialLinks: [
      { icon: "github", link: "https://github.com/medz/spry" },
      {
        icon: "twitter",
        link: "https://twitter.com/shiweidu",
      },
    ],
    footer: {
      message: "Released under the MIT License.",
      copyright: `Copyright © ${new Date().getFullYear()} Seven Du`,
    },
  },
});
