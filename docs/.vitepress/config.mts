import { defineConfig } from "vitepress";

const guide = {
  text: "Guide",
  items: [{ text: "App Instance", link: "/guide/app" }],
};

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
      guide,
      {
        text: "Examples",
        link: "https://github.com/medz/spry/tree/main/example",
      },
    ],
    sidebar: [
      { text: "What is Spry?", link: "/what-is-spry" },
      {
        text: "Getting Started",
        link: "/getting-started",
      },
      guide,
    ],
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
