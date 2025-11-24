// src/utils/domain-detection.ts
import type { City } from '../types';

// Mapping domaine → ville
const DOMAIN_TO_CITY_MAP: Record<string, string> = {
  'expert-humidite-bordeaux.fr': 'bordeaux',
  'www.expert-humidite-bordeaux.fr': 'bordeaux',
  'expert-humidite-toulouse.fr': 'toulouse',
  'www.expert-humidite-toulouse.fr': 'toulouse',
  'expert-humidite-paris.fr': 'paris',
  'www.expert-humidite-paris.fr': 'paris',
  'expert-humidite-marseille.fr': 'marseille',
  'www.expert-humidite-marseille.fr': 'marseille',
  'expert-humidite-lyon.fr': 'lyon',
  'www.expert-humidite-lyon.fr': 'lyon',
  // ... Les 40 autres villes seront ajoutées

  // Domaines de développement
  'localhost': 'bordeaux',
  'localhost:4321': 'bordeaux',
};

/**
 * Détecte la ville à afficher en fonction du domaine
 * @param hostname - Le hostname de la requête (ex: "expert-humidite-bordeaux.fr")
 * @returns Le slug de la ville (ex: "bordeaux")
 */
export function detectCityFromDomain(hostname: string): string {
  // Normaliser le hostname (enlever le port si présent)
  const normalizedHost = hostname.split(':')[0].toLowerCase();

  // Chercher dans le mapping
  const citySlug = DOMAIN_TO_CITY_MAP[normalizedHost];

  if (citySlug) {
    return citySlug;
  }

  // Fallback : extraire de expert-humidite-[ville].fr
  const match = normalizedHost.match(/expert-humidite-([a-z-]+)\.(?:fr|netlify\.app)/);
  if (match) {
    return match[1];
  }

  // Domaine Netlify preview
  if (normalizedHost.includes('.netlify.app')) {
    // Par défaut, afficher Bordeaux pour les previews
    return 'bordeaux';
  }

  // Par défaut, Bordeaux
  return 'bordeaux';
}

/**
 * Charge les données d'une ville
 * @param citySlug - Le slug de la ville (ex: "bordeaux")
 * @returns Les données de la ville
 */
export async function loadCityData(citySlug: string): Promise<City> {
  try {
    // Importer dynamiquement les données de la ville
    const cityData = await import(`../data/${citySlug}.json`);
    return cityData.default;
  } catch (error) {
    console.error(`Impossible de charger les données pour ${citySlug}, fallback sur Bordeaux`, error);
    // Fallback sur Bordeaux si la ville n'existe pas
    const bordeauxData = await import('../data/bordeaux.json');
    return bordeauxData.default;
  }
}

/**
 * Génère le titre SEO pour une ville
 */
export function generateSEOTitle(city: City): string {
  return `Expert Humidité ${city.name} | Diagnostic & Expertise Professionnelle 💧`;
}

/**
 * Génère la description SEO pour une ville
 */
export function generateSEODescription(city: City): string {
  return `Expertise humidité à ${city.name} ✓ Diagnostic précis ✓ Rapport détaillé ✓ Expert indépendant ✓ Devis gratuit ☎ Intervention ${city.department}`;
}
