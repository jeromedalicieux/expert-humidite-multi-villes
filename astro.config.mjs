// @ts-check
import { defineConfig } from 'astro/config';
import netlify from '@astrojs/netlify';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  output: 'server', // Mode SSR pour détecter le domaine à chaque requête
  adapter: netlify(), // Adaptateur Netlify pour le déploiement
  vite: {
    plugins: [tailwindcss()]
  }
});