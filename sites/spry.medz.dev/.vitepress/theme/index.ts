import { h } from 'vue';
import type { Theme } from 'vitepress';
import DefaultTheme from 'vitepress/theme';
import HomeHeroVisual from './components/HomeHeroVisual.vue';
import './style.css';

export default {
  extends: DefaultTheme,
  Layout: () =>
    h(DefaultTheme.Layout, null, {
      'home-hero-image': () => h(HomeHeroVisual),
    }),
} satisfies Theme;
