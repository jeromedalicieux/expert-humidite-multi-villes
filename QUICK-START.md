# Quick Start - Déploiement automatisé des 44 sites

## 🚀 Déploiement en 1 commande

```bash
./scripts/deploy-all-complete.sh
```

Ce script fait **tout automatiquement** :
1. ✅ Crée les 44 sites sur Netlify
2. ✅ Build les 44 versions (une par ville)
3. ✅ Déploie chaque version sur son site

**Durée totale :** ~30-60 minutes

---

## 📋 Prérequis (une seule fois)

### 1. Installer les outils

```bash
# Netlify CLI
npm install -g netlify-cli

# jq (parser JSON)
brew install jq  # macOS
# ou
sudo apt-get install jq  # Linux
```

### 2. S'authentifier Netlify

```bash
netlify login
```

### 3. Configurer Cloudflare (optionnel, pour DNS)

```bash
export CLOUDFLARE_API_TOKEN="votre-token-ici"
```

---

## 🎯 Architecture

```
44 villes = 44 sites Netlify séparés = 44 builds dédiés

┌─────────────────────────────────────────────────┐
│  expert-humidite-paris.fr                       │
│  → Site Netlify: expert-humidite-paris          │
│  → Build dédié: builds/paris/                   │
│  → Données: src/data/paris.json                 │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  expert-humidite-lyon.fr                        │
│  → Site Netlify: expert-humidite-lyon           │
│  → Build dédié: builds/lyon/                    │
│  → Données: src/data/lyon.json                  │
└─────────────────────────────────────────────────┘

... × 42 autres villes
```

**Avantages :**
- ✅ Chaque site est indépendant
- ✅ Analytics séparés par ville
- ✅ Déploiements indépendants
- ✅ Variables d'environnement dédiées
- ✅ Rollback individuel possible

---

## 📁 Fichiers importants

| Fichier | Description |
|---------|-------------|
| `cities-full.json` | Liste des 44 villes avec métadonnées |
| `AUTOMATION-GUIDE.md` | Documentation complète |
| `scripts/deploy-all-complete.sh` | Script tout-en-un |
| `scripts/build-all-cities.sh` | Build les 44 sites |
| `scripts/deploy-builds-to-netlify.sh` | Déploie sur Netlify |
| `scripts/setup-cloudflare-dns-all.sh` | Configure les DNS |

---

## 🛠️ Commandes utiles

```bash
# Voir tous les sites Netlify créés
netlify sites:list

# Ouvrir un site dans le navigateur
netlify open --site=expert-humidite-paris

# Voir les logs d'un site
netlify logs --site=expert-humidite-paris

# Déployer manuellement une ville
npm run build
netlify deploy --site=expert-humidite-paris --prod --dir=dist
```

---

## 💰 Coûts

| Service | Coût |
|---------|------|
| Netlify (44 sites) | 0€/mois (gratuit) |
| Cloudflare DNS | 0€/mois (gratuit) |
| Domaines (44) | ~440€/an |
| **Total** | **~440€/an** |

---

## 🆘 Problèmes courants

### Erreur : "Site already exists"
✅ Normal, le script passe au suivant automatiquement

### Erreur : "Build failed"
```bash
# Tester le build localement
npm run build
```

### Erreur : "Not authenticated"
```bash
netlify login
```

### DNS ne fonctionne pas
⏱️ Attendre 24-48h pour la propagation DNS

---

## 📚 Documentation complète

Pour plus de détails, voir [AUTOMATION-GUIDE.md](./AUTOMATION-GUIDE.md)

---

**Dernière mise à jour :** 25 novembre 2025
