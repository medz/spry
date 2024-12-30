import { defineConfig } from "vitepress";
import tailwindcss from "@tailwindcss/vite";

const guide = {
  text: "Guide",
  items: [
    { text: "App Instance", link: "/guide/app" },
    { text: "Routing", link: "/guide/routing" },
    { text: "Handler", link: "/guide/handler" },
    { text: "Event Object", link: "/guide/event" },
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
      { text: "Guide", link: "/getting-started" },
      { text: "Server", link: "/server" },
      { text: "Migration", link: "/migration" },
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
      { text: "Deploy", link: "/deploy" },
      guide,
      { text: "Cross-Platform Server", link: "/server" },
      { text: "Migration Guide", link: "/migration" },
      {
        text: "API Reference",
        link: "https://pub.dev/documentation/spry/latest/spry/",
      },
      { text: "Changelog", link: "/changelog" },
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
  vite: {
    plugins: [tailwindcss()],
  },
});
