import { defineConfig, DefaultTheme } from "vitepress";

const title = "Spry";
const slogan = "An middleware-style framework for Dart";
const description = `${title} is an HTTP middleware framework for Dart to make web applications and APIs more enjoyable to write.`;
const github = "odroe/spry";

const ecosystem: DefaultTheme.NavItemWithLink[] = [
  { text: "Router", link: "/ecosystem/router" },
  { text: "Filesystem Router", link: "/ecosystem/fsrouter" },
  { text: "Static", link: "/ecosystem/static" },
];

const navbar: DefaultTheme.NavItem[] = [
  { text: "Docs", link: "/docs/" },
  { text: "Ecosystem", items: ecosystem },
  { text: "API Reference", link: "https://pub.dev/documentation/spry/latest/" },
  { text: "Sponsor", link: "https://github.com/sponsors/odroe" },
];

const social: DefaultTheme.SocialLink[] = [
  { icon: "github", link: `https://github.com/${github}` },
  { icon: "twitter", link: "https://twitter.com/odroeinc" },
];

const getingStarted: DefaultTheme.NavItemWithLink[] = [
  { text: "Installation", link: "/docs/getting-started/installation" },
  { text: "Configuration", link: "/docs/getting-started/configuration" },
  { text: "Handler", link: "/docs/getting-started/handler" },
  { text: "Middleware", link: "/docs/getting-started/middleware" },
  { text: "Deployment", link: "/docs/getting-started/deployment" },
];

const fundamentals: DefaultTheme.NavItemWithLink[] = [
  { text: "Application", link: "/docs/fundamentals/application" },
  { text: "Context", link: "/docs/fundamentals/context" },
  { text: "Request", link: "/docs/fundamentals/request" },
  { text: "Response", link: "/docs/fundamentals/response" },
];

const techniques: DefaultTheme.NavItemWithLink[] = [
  { text: "Interceptor", link: "/docs/techniques/interceptor" },
  { text: "JSON", link: "/docs/techniques/json" },
  { text: "URL-Encoded", link: "/docs/techniques/url-encoded" },
  { text: "Multipart", link: "/docs/techniques/multipart" },
  { text: "Cookie", link: "/docs/techniques/cookie" },
  { text: "Session", link: "/docs/techniques/session" },
  { text: "Router", link: "/ecosystem/router" },
];

const docs: DefaultTheme.SidebarItem[] = [
  { text: "Getting Started", items: getingStarted },
  { text: "Fundamentals", items: fundamentals },
  { text: "Techniques", items: techniques },
];

const ecosystemGroup: DefaultTheme.SidebarItem[] = [
  { text: "Ecosystem", items: ecosystem },
];

const sidebar: DefaultTheme.Sidebar = {
  "/docs/": docs,
  "/ecosystem/": ecosystemGroup,
};

const themeConfig: DefaultTheme.Config = {
  //------------- Edit link -------------
  editLink: {
    pattern: `https://github.com/${github}/edit/main/docs/:path`,
    text: "Edit this page on GitHub",
  },

  //----------------- Logo ---------------
  // logo: "/logo.svg",

  //--------------- Footer ---------------
  footer: {
    copyright: `Copyright © 2014-${new Date().getFullYear()} Odroe Inc.`,
    message: "Released under the MIT license.",
  },

  //--------------- Navbar ---------------
  nav: navbar,

  //--------------- Sidebar ---------------
  sidebar,

  //---------------- Social ---------------
  socialLinks: social,
};

const config = defineConfig({
  //----------------- Base ---------------
  title,
  titleTemplate: `:title | ${title} - ${slogan}`,
  description,

  //----------------- Theme ---------------
  themeConfig,
});

export default config;
