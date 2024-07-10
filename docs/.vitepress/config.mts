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
        items: [
          { text: "App", link: "/guide/app" },
          { text: "Routing", link: "/guide/routing" },
          { text: "Handler", link: "/guide/handler" },
          { text: "Event", link: "/guide/event" },
          { text: "WebSocket", link: "/guide/websocket/introduction" },
        ],
      },
      {
        text: "Platforms",
        items: [
          { text: "Plain", link: "/platforms/plain" },
          { text: "IO (dart:io)", link: "/platforms/io" },
        ],
      },
      {
        text: "Examples",
        link: "https://github.com/medz/spry/tree/main/examples",
      },
    ],
    sidebar: [
      { text: "What is Spry?", link: "/what-is-spry" },
      {
        text: "Getting Started",
        link: "/getting-started",
      },
      {
        text: "Basics",
        items: [
          { text: "App", link: "/guide/app" },
          { text: "Routing", link: "/guide/routing" },
          { text: "Handler", link: "/guide/handler" },
          { text: "Event", link: "/guide/event" },
        ],
      },
      {
        text: "WebSocket",
        items: [
          { text: "Introduction", link: "/guide/websocket/introduction" },
          { text: "Hooks", link: "/guide/websocket/hooks" },
          { text: "Peer", link: "/guide/websocket/peer" },
          { text: "Message", link: "/guide/websocket/message" },
        ],
      },
      {
        text: "Advanced",
        items: [{ text: "Cookies", link: "/advanced/cookies" }],
      },
      {
        text: "Platforms",
        items: [
          {
            text: "Create a new platform",
            link: "/platforms/create",
          },
          { text: "Plain", link: "/platforms/plain" },
          { text: "IO (dart:io)", link: "/platforms/io" },
        ],
      },
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
