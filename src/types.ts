// src/types.ts

export interface City {
  id?: number;
  slug: string;
  name: string;
  domain?: string;
  department: string;
  postalCode?: string;
  zipCode?: string; // Alias pour postalCode
  region: string;
  population: string;
  climate: string;
  humidity_context?: string;
  neighborhoods?: string[];
  nearbyQuartiers?: string[]; // Alias pour neighborhoods
  nearbyTowns?: string[];
  variationGroup?: 'A' | 'B' | 'C';
  seo?: {
    title?: string;
    description?: string;
  };
}

export interface ContentVariation {
  titles: {
    hero_h1: string[];
    section_signs: string[];
    section_causes: string[];
    section_diagnosis: string[];
  };
  synonyms: {
    [key: string]: string[];
  };
  structural_variants: {
    group_a: StructuralVariant;
    group_b: StructuralVariant;
    group_c: StructuralVariant;
  };
}

export interface StructuralVariant {
  section_order: string[];
  tone: 'technical' | 'educational' | 'reassuring';
}

export interface FAQItem {
  question: string;
  answer: string;
}
