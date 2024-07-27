---
layout: home
title: A lightweight and composable web framework.
hero:
  name: ⚡️ Spry
  text: A lightweight and composable web framework
  tagline: Performance · Powerful · Joyful
  image: /code.png
  actions:
    - text: What is Spry?
      link: /what-is-spry
    - theme: alt
      text: Getting Started
      link: /getting-started
    - theme: alt
      text: View on GitHub
      link: https://github.com/medz/spry
features:
  - icon: 🛸
    title: Runtime Agnostic
    details: Your code is implemented through the platform and can be compiled into any runtime for your application.
  - icon: ✨
    title: Small & Tree-shakable
    details: Spry core is super lightweight & tree-shakable, Only the extensions you use will be included in the final bundle.
  - icon: 🧩
    title: Composable
    details: Extend your application and add capabilities, Your codebase will scale with your project.
  - icon: 🌲
    title: Fast Router
    details: Super fast route matching using <a href="https://github.com/medz/routingkit" style="color:#4d00fe;" align="right">RoutingKit</a>.
  - icon: 🤖
    title: Made for Humans
    details: Elegant minimal API implementation and editing interface abstraction.
  - icon: 🎉
    title: Responsible
    details: Your handlers can intuitively return content without building complex Response objects.
---

<script setup>
import { VPTeamPageTitle, VPTeamMembers } from 'vitepress/theme';

const members = [
  {
    avatar: 'https://www.github.com/medz.png',
    name: 'Seven Du',
    title: 'Coder · Designer · Creator',
    org: "Odroe",
    orgLink: "https://github.com/odroe",
    sponsor: "https://github.com/sponsors/medz",
    links: [
      { icon: 'github', link: 'https://github.com/medz' },
      { icon: 'twitter', link: 'https://twitter.com/shiweidu' }
    ]
  },
  {
    avatar: 'https://www.github.com/skillLan.png',
    name: 'Tian Lan',
    org: "Odroe",
    orgLink: "https://github.com/odroe",
    title: 'Account Manager · IOS Engineer',
    links: [
      { icon: 'github', link: 'https://github.com/skillLan' },
    ]
  },
];
</script>

<VPTeamPageTitle>
  <template #title>
    Our Team
  </template>
</VPTeamPageTitle>

<VPTeamMembers size="small" :members="members" />

<VPTeamPageTitle>
  <template #title>
    Made by community
  </template>
  <template #lead>
    Say hello to our awesome contributors.
  </template>
</VPTeamPageTitle>

<a href="https://github.com/medz/spry/graphs/contributors" >
  <img src="https://contrib.rocks/image?repo=medz/spry" style="margin: 0 auto;" />
</a>
