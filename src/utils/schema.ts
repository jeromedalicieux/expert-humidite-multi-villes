// src/utils/schema.ts
import type { City } from '../types';

export interface FAQ {
  question: string;
  answer: string;
}

export function generateLocalBusinessSchema(city: City, canonicalURL: string) {
  return {
    "@context": "https://schema.org",
    "@type": "LocalBusiness",
    "name": `Expert Humidité ${city.name}`,
    "description": `Expert en diagnostic et traitement de l'humidité à ${city.name}. Expertise professionnelle des problèmes d'humidité, remontées capillaires, infiltrations, moisissures.`,
    "image": `https://${city.domain}/images/expert-humidite-${city.slug}.jpg`,
    "address": {
      "@type": "PostalAddress",
      "addressLocality": city.name,
      "addressRegion": city.region,
      "postalCode": city.postalCode,
      "addressCountry": "FR"
    },
    "geo": {
      "@type": "GeoCoordinates",
      "addressLocality": city.name
    },
    "areaServed": [
      {
        "@type": "City",
        "name": city.name
      },
      {
        "@type": "AdministrativeArea",
        "name": city.region
      }
    ],
    "url": canonicalURL,
    "telephone": "+33-X-XX-XX-XX-XX",
    "email": `contact@${city.domain}`,
    "priceRange": "€€",
    "openingHours": ["Mo-Fr 09:00-18:00", "Sa 09:00-12:00"],
    "currenciesAccepted": "EUR",
    "paymentAccepted": "Cash, Credit Card, Bank Transfer",
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": "4.9",
      "reviewCount": "127",
      "bestRating": "5",
      "worstRating": "1"
    }
  };
}

export function generateServiceSchema(city: City) {
  return {
    "@context": "https://schema.org",
    "@type": "Service",
    "serviceType": "Expertise Humidité",
    "name": `Diagnostic et Expertise Humidité ${city.name}`,
    "description": `Diagnostic professionnel des problèmes d'humidité à ${city.name} : remontées capillaires, infiltrations, condensation, moisissures. Rapport détaillé avec préconisations de solutions.`,
    "provider": {
      "@type": "LocalBusiness",
      "name": `Expert Humidité ${city.name}`,
      "areaServed": city.name
    },
    "areaServed": {
      "@type": "City",
      "name": city.name
    },
    "offers": {
      "@type": "Offer",
      "priceCurrency": "EUR",
      "priceRange": "300-800",
      "availability": "https://schema.org/InStock",
      "description": "Tarif selon surface et complexité du diagnostic"
    },
    "category": "Home Services",
    "termsOfService": `https://${city.domain}/#conditions`
  };
}

export function generateFAQSchema(faqs: FAQ[]) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": faqs.map(faq => ({
      "@type": "Question",
      "name": faq.question,
      "acceptedAnswer": {
        "@type": "Answer",
        "text": faq.answer
      }
    }))
  };
}

export function generateBreadcrumbSchema(city: City, canonicalURL: string) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [
      {
        "@type": "ListItem",
        "position": 1,
        "name": "Accueil",
        "item": canonicalURL
      },
      {
        "@type": "ListItem",
        "position": 2,
        "name": `Expert Humidité ${city.name}`,
        "item": canonicalURL
      }
    ]
  };
}

export function generateWebSiteSchema(city: City) {
  return {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": `Expert Humidité ${city.name}`,
    "description": `Site officiel de l'expertise humidité à ${city.name}`,
    "url": `https://${city.domain}`,
    "potentialAction": {
      "@type": "SearchAction",
      "target": `https://${city.domain}/?q={search_term_string}`,
      "query-input": "required name=search_term_string"
    }
  };
}
