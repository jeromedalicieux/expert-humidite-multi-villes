# Expert Humidité - Générateur Multi-Villes

Site web de référence pour l'expertise humidité en France, déployé sur 44 villes avec détection automatique du domaine.

## 🎯 Projet

Générateur de sites web SEO-optimisés pour experts en diagnostic humidité dans 44 grandes villes françaises.

**Architecture** : 1 repository → 1 site Netlify → 44 domaines

Chaque domaine (`expert-humidite-[ville].fr`) affiche automatiquement le contenu personnalisé pour sa ville.

---

## ✨ Features

- ✅ **Détection automatique de la ville** par domaine
- ✅ **SEO ultra-optimisé** (Schema.org, Open Graph, Twitter Cards)
- ✅ **Design responsive** mobile-first
- ✅ **Performance maximale** (Astro SSG)
- ✅ **HTTPS automatique** via Netlify
- ✅ **Multi-domaines** (44 sites sur 1 seul déploiement)
- ✅ **Formulaire de contact** intégré (Tally)
- ✅ **Villes limitrophes** pour SEO local

---

## 🚀 Quick Start

### Installation locale

```bash
npm install
npm run dev
```

Le site sera accessible sur `http://localhost:4321/`

### Build de production

```bash
npm run build
npm run preview
```

---

## 📦 Structure du Projet

```
expert-humidite-bordeaux/
├── src/
│   ├── components/          # Composants Astro
│   │   ├── Hero.astro       # Section hero avec CTA
│   │   ├── Process.astro    # Processus en 4 étapes
│   │   ├── Coverage.astro   # Zone d'intervention
│   │   ├── Testimonials.astro  # Témoignages clients
│   │   ├── FAQ.astro        # Questions fréquentes
│   │   ├── ContactForm.astro   # Formulaire Tally
│   │   ├── FloatingCTA.astro   # CTA flottant mobile
│   │   └── Footer.astro     # Pied de page
│   ├── layouts/
│   │   └── BaseLayout.astro # Layout principal avec SEO
│   ├── pages/
│   │   └── index.astro      # Page d'accueil
│   ├── data/                # Données JSON par ville
│   │   ├── bordeaux.json    # ✅ Données Bordeaux
│   │   └── [43 autres villes à créer]
│   ├── utils/
│   │   ├── domain-detection.ts  # Détection de la ville
│   │   └── schema.ts        # Générateurs Schema.org
│   └── types.ts             # Types TypeScript
├── public/                  # Assets statiques
├── scripts/                 # Scripts d'automatisation
│   ├── add-netlify-domains.sh   # Ajouter 44 domaines via API
│   └── verify-domains.sh    # Vérifier DNS et HTTPS
├── netlify.toml             # Configuration Netlify
└── README.md                # Ce fichier
```

---

## 🌍 Villes Supportées

**1 ville complète actuellement** :
- ✅ Bordeaux (avec données JSON complètes)

**43 villes à compléter** (Phase 2) :
Paris, Lyon, Marseille, Toulouse, Nice, Nantes, Strasbourg, Montpellier, Lille, Rennes, Reims, Saint-Étienne, Toulon, Grenoble, Dijon, Angers, Nîmes, Villeurbanne, Clermont-Ferrand, Le Mans, Aix-en-Provence, Brest, Tours, Amiens, Limoges, Annecy, Perpignan, Boulogne-Billancourt, Metz, Besançon, Orléans, Saint-Denis, Argenteuil, Rouen, Mulhouse, Montreuil, Caen, Nancy, Tourcoing, Roubaix, Vitry-sur-Seine, Avignon, Poitiers.

---

## 🚀 Déploiement

### Étape 1 : Déployer sur Netlify

#### Option A : Quick Start (Rapide)
Suivre le guide : **[QUICK-START-NETLIFY.md](./QUICK-START-NETLIFY.md)**
⏱️ Déploiement en 10 minutes

#### Option B : Guide Détaillé
Suivre le guide complet : **[NETLIFY-DEPLOY-GUIDE.md](./NETLIFY-DEPLOY-GUIDE.md)**
📖 Toutes les étapes expliquées en détail

### Étape 2 : Configuration DNS

Vous avez **2 options** pour gérer vos DNS :

#### Option 1 : Cloudflare (Recommandé) ⚡

**Avantages** :
- ✅ CDN mondial gratuit (performance++)
- ✅ Protection DDoS automatique
- ✅ SSL/TLS gratuit
- ✅ Configuration automatisée avec nos scripts
- ✅ Analytics gratuits

👉 **[CLOUDFLARE-SETUP.md](./CLOUDFLARE-SETUP.md)** - Configuration automatique complète

```bash
# Configuration automatique des 44 domaines
export CLOUDFLARE_API_TOKEN="..."
export CLOUDFLARE_ACCOUNT_ID="..."
./scripts/cloudflare-setup.sh
```

#### Option 2 : DNS chez votre registrar

Configuration manuelle chez OVH, Gandi, O2Switch, Infomaniak, etc.

👉 **[DNS-CONFIGURATION.md](./DNS-CONFIGURATION.md)** - Instructions par hébergeur

---

## 🛠️ Scripts Utiles

### Configuration Cloudflare (automatique)

```bash
# Configurer automatiquement les 44 domaines sur Cloudflare
export CLOUDFLARE_API_TOKEN="votre-token"
export CLOUDFLARE_ACCOUNT_ID="votre-account-id"
./scripts/cloudflare-setup.sh

# Vérifier la configuration Cloudflare
./scripts/verify-cloudflare.sh
```

### Configuration Netlify

```bash
# Ajouter automatiquement les 44 domaines sur Netlify
export NETLIFY_SITE_ID="votre-site-id"
export NETLIFY_TOKEN="votre-token-api"
./scripts/add-netlify-domains.sh

# Vérifier tous les domaines (DNS + HTTPS)
./scripts/verify-domains.sh
```

---

## 🧞 Commandes NPM

| Commande | Action |
|----------|--------|
| `npm install` | Installer les dépendances |
| `npm run dev` | Serveur dev sur `localhost:4321` |
| `npm run build` | Build de production dans `./dist/` |
| `npm run preview` | Prévisualiser le build en local |
| `npm run astro check` | Vérifier les erreurs TypeScript |

---

## 🏗️ Architecture Multi-Domaines

### Comment ça fonctionne ?

1. **Détection du domaine** : `domain-detection.ts` détecte le hostname
2. **Chargement des données** : Import dynamique du JSON correspondant
3. **Rendu personnalisé** : Chaque composant utilise les données de la ville

**Exemple** :
```typescript
// src/utils/domain-detection.ts
const hostname = Astro.url.hostname;  // "expert-humidite-paris.fr"
const citySlug = detectCityFromDomain(hostname);  // "paris"
const city = await loadCityData(citySlug);  // Import de paris.json
```

### Fallback

Si le JSON de la ville n'existe pas, le système fallback sur `bordeaux.json`.

---

## 📊 SEO & Schema.org

Chaque page inclut automatiquement :

- ✅ **LocalBusiness** (nom, adresse, téléphone, zone)
- ✅ **Service** (description du service d'expertise)
- ✅ **FAQPage** (questions fréquentes structurées)
- ✅ **BreadcrumbList** (fil d'Ariane)
- ✅ **WebSite** (informations générales du site)
- ✅ **Open Graph** (partage réseaux sociaux)
- ✅ **Twitter Cards** (prévisualisation Twitter)
- ✅ **AggregateRating** (note moyenne 4.9/5)

---

## 🎨 Technologies

- **[Astro 5.16.0](https://astro.build)** - Générateur de sites statiques
- **[Tailwind CSS v4.1.17](https://tailwindcss.com)** - Framework CSS
- **[TypeScript](https://www.typescriptlang.org/)** - Typage statique
- **[Netlify](https://www.netlify.com/)** - Hébergement et CDN
- **[Tally](https://tally.so/)** - Formulaire de contact

---

## 📝 Phase 2 : Génération Multi-Villes

**Prochaines étapes** :

1. Créer les 43 fichiers JSON restants (`src/data/[ville].json`)
2. Implémenter le système de variations anti-duplicate (groupes A, B, C)
3. Créer les FAQ personnalisées par ville
4. Ajouter des images réelles pour remplacer les placeholders
5. Configurer les DNS pour tous les domaines
6. Soumettre chaque site à Google Search Console

---

## 🔒 Sécurité

Headers configurés dans `netlify.toml` :

- `X-Frame-Options: DENY` (protection clickjacking)
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`

---

## 📞 Support

- **Documentation Astro** : https://docs.astro.build
- **Documentation Netlify** : https://docs.netlify.com
- **Repository GitHub** : https://github.com/jeromedalicieux/expert-humidite-multi-villes

---

## 📄 Licence

Projet privé - Tous droits réservés

---

**Créé avec ❤️ en utilisant Astro + Tailwind CSS**
