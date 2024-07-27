import { defineConfig } from "vitepress";

const guide = {
  text: "Guide",
  items: [
    { text: "App Instance", link: "/guide/app" },
    { text: "Routing", link: "/guide/routing" },
    { text: "Handler", link: "/guide/handler" },
    { text: "Event Object", link: "/guide/event" },
  ],
};

const utils = {
  text: "Utils",
  items: [
    { text: "Request", link: "/utils/request" },
    { text: "Advanced", link: "/utils/advanced" },
  ],
};

const adapters = {
  text: "Adapters",
  items: [
    { text: "dart:io", link: "/adapters/io" },
    { text: "Web", link: "/adapters/web" },
    { text: "Plain", link: "/adapters/plain" },
    { text: "Bun", link: "/adapters/bun" },
  ],
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
      utils,
      adapters,
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
      utils,
      {
        text: "Advanced",
        items: [
          { text: "Cookies", link: "/advanced/cookies" },
          { text: "WebSockets", link: "/advanced/ws" },
        ],
      },
      adapters,
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
