# Configuration Multi-Domaines (44 villes, 1 site)

## 🎯 Architecture Choisie

**1 Repository → 1 Site Netlify → 44 Domaines**

Tous les domaines pointent vers le même site. Le site détecte automatiquement quel domaine l'utilisateur visite et affiche la ville correspondante.

## ✅ Avantages

- **1 seul déploiement** au lieu de 44
- **Maintenance simplifiée** : 1 seul codebase
- **Coûts réduits** : 1 seul site Netlify
- **Updates instantanés** : Modifier 1 fichier met à jour les 44 sites
- **Performance** : CDN partagé

## 📋 Comment ça marche ?

### 1. Détection du Domaine

Le fichier `src/utils/domain-detection.ts` :
- Lit le domaine de la requête (ex: `expert-humidite-paris.fr`)
- Détermine la ville correspondante (ex: `paris`)
- Charge les données JSON de cette ville

### 2. Chargement Dynamique

```typescript
// Dans index.astro
const hostname = Astro.url.hostname;  // "expert-humidite-lyon.fr"
const citySlug = detectCityFromDomain(hostname);  // "lyon"
const city = await loadCityData(citySlug);  // Charge lyon.json
```

### 3. Rendu Personnalisé

Le site affiche automatiquement :
- Le nom de la ville
- Les quartiers locaux
- Les villes limitrophes
- Le contenu localisé

## 🚀 Déploiement sur Netlify

### Étape 1 : Déployer le Site

1. Connecter le repo GitHub à Netlify
2. Configuration automatique détectée
3. Déployer → Vous obtenez `[random].netlify.app`

### Étape 2 : Ajouter TOUS les Domaines

Dans Netlify → Site settings → Domain management → Add domain :

```
expert-humidite-bordeaux.fr
expert-humidite-paris.fr
expert-humidite-marseille.fr
expert-humidite-lyon.fr
expert-humidite-toulouse.fr
expert-humidite-nice.fr
expert-humidite-nantes.fr
... (les 44 domaines)
```

**Important** : Pas besoin de créer 44 sites Netlify ! Un seul site avec 44 domaines.

### Étape 3 : Configurer les DNS

Pour **chaque domaine**, chez votre registrar :

#### Option A : DNS Netlify (Recommandé)
```
Nameservers:
dns1.p0X.nsone.net
dns2.p0X.nsone.net
dns3.p0X.nsone.net
dns4.p0X.nsone.net
```

#### Option B : DNS Externe
```
Type: A
Name: @
Value: 75.2.60.5 (IP Netlify)

Type: CNAME  
Name: www
Value: [votre-site].netlify.app
```

### Étape 4 : HTTPS Automatique

Netlify génère automatiquement un certificat SSL pour chaque domaine.
Temps de propagation : 1-24h par domaine.

## 📁 Structure des Données

### Fichier par Ville

Chaque ville a son fichier JSON :

```
src/data/
├── bordeaux.json
├── paris.json
├── marseille.json
├── lyon.json
... (44 fichiers)
```

### Format JSON

```json
{
  "id": 9,
  "slug": "bordeaux",
  "name": "Bordeaux",
  "domain": "expert-humidite-bordeaux.fr",
  "department": "33",
  "region": "Nouvelle-Aquitaine",
  "neighborhoods": ["Chartrons", "Bastide"],
  "nearbyTowns": ["Mérignac", "Pessac"],
  "variationGroup": "A"
}
```

## 🧪 Tests en Local

### Tester avec différents domaines

1. **Modifier /etc/hosts** (sur Mac/Linux)

```bash
sudo nano /etc/hosts

# Ajouter :
127.0.0.1 expert-humidite-paris.local
127.0.0.1 expert-humidite-lyon.local
127.0.0.1 expert-humidite-marseille.local
```

2. **Lancer le dev server**

```bash
npm run dev
```

3. **Visiter**
- http://expert-humidite-paris.local:4321 → Affiche Paris
- http://expert-humidite-lyon.local:4321 → Affiche Lyon
- http://localhost:4321 → Affiche Bordeaux (défaut)

## 🔧 Ajouter une Nouvelle Ville

### 1. Créer le fichier JSON

```bash
src/data/toulouse.json
```

### 2. Ajouter au mapping (optionnel)

Dans `src/utils/domain-detection.ts` :

```typescript
const DOMAIN_TO_CITY_MAP: Record<string, string> = {
  // ...
  'expert-humidite-toulouse.fr': 'toulouse',
  'www.expert-humidite-toulouse.fr': 'toulouse',
};
```

### 3. Créer les variations de contenu

Fichiers FAQ, témoignages, etc. pour Toulouse.

### 4. Déployer

```bash
git add .
git commit -m "feat: Ajoute Toulouse"
git push
```

Netlify redéploie automatiquement.

### 5. Ajouter le domaine dans Netlify

Domain management → Add domain → `expert-humidite-toulouse.fr`

## 📊 Monitoring

### Vérifier quel domaine affiche quelle ville

```bash
# Test Bordeaux
curl -H "Host: expert-humidite-bordeaux.fr" https://[votre-site].netlify.app | grep "Bordeaux"

# Test Paris  
curl -H "Host: expert-humidite-paris.fr" https://[votre-site].netlify.app | grep "Paris"
```

### Google Analytics

Toutes les villes partagent le même GA, mais vous pouvez filtrer par :
- Hostname (pour voir les visites par ville)
- URL path
- Custom dimension avec le nom de la ville

## 💰 Coûts

### Netlify Pricing

- **Free tier** : Jusqu'à 100 GB/mois de bande passante
  - Suffisant pour ~50,000 visites/mois
  - **44 domaines inclus gratuitement** ✅

- **Pro ($19/mois)** : Si vous dépassez 100 GB
  - Bande passante illimitée
  - 44 domaines inclus

### Domaines

- ~10€/an par domaine
- 44 domaines × 10€ = **440€/an**
- À acheter chez Gandi, OVH, Namecheap, etc.

### Total Estimé

- Hébergement : **Gratuit** (ou 19$/mois si gros trafic)
- Domaines : **440€/an**
- **Total : 440-668€/an** pour 44 sites

## 🔐 Sécurité

Tous les headers de sécurité sont configurés dans `netlify.toml` :
- X-Frame-Options
- X-XSS-Protection  
- X-Content-Type-Options
- Referrer-Policy
- Permissions-Policy

HTTPS forcé automatiquement par Netlify.

## 📈 Évolutivité

Pour ajouter 100 villes de plus :
1. Créer les 100 fichiers JSON
2. Ajouter les 100 domaines dans Netlify
3. Un seul déploiement

Pas de limite technique. Netlify supporte des milliers de domaines par site.

## ❓ FAQ

**Q: Peut-on avoir des URL différentes pour chaque ville ?**
R: Non, toutes les villes ont la même structure d'URL. Mais le contenu change selon le domaine.

**Q: Et si on veut des pages différentes par ville ?**
R: Il faudrait passer à un système de routing dynamique avec `[city].astro`.

**Q: Les 44 sites se chargent-ils tous en mémoire ?**
R: Non ! Seule la ville demandée est chargée (lazy loading).

**Q: Quid du SEO ?**
R: Chaque domaine a ses propres meta tags, Schema.org, et contenu unique. Google voit 44 sites distincts.

---

**Prêt à déployer ?** Suivez le guide dans `DEPLOYMENT.md`
