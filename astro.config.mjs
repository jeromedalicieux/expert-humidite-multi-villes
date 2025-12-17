// @ts-check
import { defineConfig, envField } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  output: 'static', // Mode static pour générer des builds HTML statiques par ville
  vite: {
    plugins: [tailwindcss()]
  },
  env: {
    schema: {
      CITY_SLUG: envField.string({
        context: 'server',
        access: 'public',
        default: 'bordeaux'
      })
    }
  }
});