# Guide d'Automatisation Multi-Villes

Ce guide explique comment déployer automatiquement les 44 sites Expert Humidité sur Netlify et configurer les DNS Cloudflare.

## Prérequis

### 1. Installation des outils

```bash
# Netlify CLI
npm install -g netlify-cli

# jq (pour parser JSON)
brew install jq  # macOS
# ou
sudo apt-get install jq  # Linux
```

### 2. Authentification

**Netlify:**
```bash
netlify login
```

**Cloudflare:**
- Créer un API Token sur https://dash.cloudflare.com/profile/api-tokens
- Permissions requises : `Zone.DNS` (Edit)
- Exporter la variable :
  ```bash
  export CLOUDFLARE_API_TOKEN="votre-token-ici"
  ```

## Étapes de déploiement complet

### Étape 1 : Créer les sites Netlify

Ce script crée automatiquement les 44 sites sur Netlify :

```bash
cd expert-humidite-bordeaux
./scripts/deploy-all-cities-netlify.sh
```

**Ce que fait le script :**
- ✅ Crée 44 sites Netlify (un par ville)
- ✅ Configure les domaines personnalisés (ex: `expert-humidite-paris.fr`)
- ✅ Configure les sous-domaines `www`
- ✅ Génère les noms de sites : `expert-humidite-[ville].netlify.app`

**Durée estimée :** 5-10 minutes

### Étape 2 : Build et déploiement du code

```bash
# Build le projet
npm run build

# Le build génère un dossier /dist/ identique pour tous les sites
# La détection de ville se fait via le domaine
```

### Étape 3 : Déployer sur tous les sites

Option A : Déploiement manuel (recommandé pour la première fois)

```bash
# Pour chaque ville, exemple avec Paris :
netlify deploy --site=expert-humidite-paris --prod --dir=dist
```

Option B : Script automatisé (à créer si nécessaire)

```bash
./scripts/deploy-build-all-sites.sh
```

### Étape 4 : Configuration DNS Cloudflare

Ce script configure automatiquement les DNS pour pointer vers Netlify :

```bash
export CLOUDFLARE_API_TOKEN="votre-token"
./scripts/setup-cloudflare-dns-all.sh
```

**Ce que fait le script :**
- ✅ Crée les enregistrements A vers l'IP Netlify (75.2.60.5)
- ✅ Crée les enregistrements CNAME pour www
- ✅ Active le proxy Cloudflare (CDN + SSL)
- ✅ Configure les 44 domaines automatiquement

**Durée estimée :** 5 minutes
**Propagation DNS :** 24-48 heures maximum

## Architecture multi-domaines

### Comment ça fonctionne

```
1. Visiteur → expert-humidite-paris.fr
2. DNS Cloudflare → Netlify Load Balancer
3. Netlify serve le même build /dist/
4. Astro détecte le domaine (dans src/utils/domain-detection.ts)
5. Charge automatiquement les données paris.json
6. Affiche le contenu personnalisé Paris
```

**Un seul build, 44 domaines différents !**

### Fichiers nécessaires par ville

Pour chaque nouvelle ville, créer :

```
src/data/
├── [ville].json          # Métadonnées ville
└── faq-[ville].json      # FAQ personnalisée
```

Et ajouter dans `src/utils/domain-detection.ts` :

```typescript
'expert-humidite-[ville].fr': '[ville]',
'www.expert-humidite-[ville].fr': '[ville]',
```

## Vérification et tests

### Tester un domaine localement

Modifier `/etc/hosts` :
```
127.0.0.1 expert-humidite-paris.local
```

Puis accéder à : http://expert-humidite-paris.local:4321

### Vérifier les DNS

```bash
./scripts/verify-domains.sh
```

### Vérifier les sites Netlify

```bash
netlify sites:list
```

### Vérifier un site spécifique

```bash
netlify status --site=expert-humidite-paris
```

## Gestion des domaines

### Acheter les domaines

Les 44 domaines doivent être achetés (environ 10€/an chacun) :
- expert-humidite-paris.fr
- expert-humidite-lyon.fr
- expert-humidite-marseille.fr
- ... (41 autres)

**Budget total domaines :** ~440€/an

### Transférer vers Cloudflare

1. Ajouter chaque domaine dans Cloudflare
2. Mettre à jour les nameservers chez le registrar
3. Attendre la vérification (24-48h)
4. Lancer le script DNS

## Maintenance

### Ajouter une nouvelle ville

1. Créer les fichiers JSON :
   ```bash
   cp src/data/bordeaux.json src/data/nouvelle-ville.json
   cp src/data/faq-bordeaux.json src/data/faq-nouvelle-ville.json
   ```

2. Éditer les données

3. Ajouter dans `domain-detection.ts`

4. Créer le site Netlify :
   ```bash
   netlify sites:create --name expert-humidite-nouvelle-ville
   ```

5. Configurer DNS Cloudflare

6. Déployer :
   ```bash
   npm run build
   netlify deploy --site=expert-humidite-nouvelle-ville --prod --dir=dist
   ```

### Mettre à jour tous les sites

```bash
# Rebuild
npm run build

# Déployer sur tous les sites
for city in paris lyon marseille toulouse ...; do
  netlify deploy --site=expert-humidite-$city --prod --dir=dist
done
```

## Coûts estimés

| Service | Coût mensuel | Coût annuel |
|---------|--------------|-------------|
| Netlify (44 sites) | $0 (plan gratuit) | $0 |
| Cloudflare DNS | $0 (plan gratuit) | $0 |
| Domaines (44 × 10€) | ~37€ | ~440€ |
| **Total** | **~37€** | **~440€** |

## Troubleshooting

### Erreur : Site existe déjà
Le script vérifie automatiquement et passe au suivant.

### Erreur : DNS non propagé
Attendre 24-48h, ou vérifier avec :
```bash
dig expert-humidite-paris.fr
```

### Erreur : Build Netlify échoue
Vérifier les logs :
```bash
netlify logs --site=expert-humidite-paris
```

### Erreur : Contenu incorrect affiché
Vérifier `src/utils/domain-detection.ts` et les fichiers JSON.

## Support

Pour toute question :
- Documentation Netlify : https://docs.netlify.com
- Documentation Cloudflare : https://developers.cloudflare.com
- Astro Docs : https://docs.astro.build

---

**Dernière mise à jour :** 25 novembre 2025
**Testé avec :** Netlify CLI 17.x, Cloudflare API v4
