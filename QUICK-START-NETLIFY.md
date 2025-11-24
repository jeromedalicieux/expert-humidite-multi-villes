# 🚀 Quick Start - Déploiement Netlify

Guide ultra-rapide pour déployer les 44 sites Expert Humidité sur Netlify.

---

## ⚡ Déploiement en 10 minutes

### 1️⃣ Créer le site sur Netlify (2 min)

1. Aller sur https://app.netlify.com
2. **Add new site** → **Import an existing project** → **GitHub**
3. Sélectionner le repo : `expert-humidite-multi-villes`
4. Configuration (auto-détectée depuis `netlify.toml`) :
   ```
   Build command: npm run build
   Publish directory: dist
   ```
5. Cliquer **"Deploy"**

✅ **Site en ligne** : `https://[random-name].netlify.app`

---

### 2️⃣ Renommer le site (30 sec)

1. **Site settings** → **Change site name**
2. Entrer : `expert-humidite-multi-villes`

✅ **Nouvelle URL** : `https://expert-humidite-multi-villes.netlify.app`

---

### 3️⃣ Ajouter les 44 domaines via API (2 min)

#### Récupérer les identifiants :

**Site ID :**
- Netlify → **Site settings** → **General** → Copier le **Site ID**

**Token d'API :**
- https://app.netlify.com/user/applications
- **Personal access tokens** → **New access token**
- Description : `Add domains script`
- Copier le token

#### Exécuter le script :

```bash
cd expert-humidite-bordeaux

export NETLIFY_SITE_ID="votre-site-id"
export NETLIFY_TOKEN="votre-token"

./scripts/add-netlify-domains.sh
```

✅ **44 domaines ajoutés** en ~30 secondes

---

### 4️⃣ Configurer les DNS (variable selon hébergeur)

Pour **chaque domaine**, configurer chez votre hébergeur DNS :

```
Type: A
Nom: @ (ou vide)
Valeur: 75.2.60.5
TTL: 3600

Type: CNAME
Nom: www
Valeur: expert-humidite-multi-villes.netlify.app
TTL: 3600
```

#### Exemples par hébergeur :

**OVH** :
- Manager → Domaines → Zone DNS
- Supprimer anciens A et CNAME
- Ajouter nouveaux enregistrements

**Gandi** :
- Admin → Domaines → Enregistrements DNS
- Modifier les enregistrements

**Autres** : Voir [DNS-CONFIGURATION.md](./DNS-CONFIGURATION.md)

⏱️ **Temps** : ~10-15 min par domaine = 4-6h pour 44 domaines

---

### 5️⃣ Attendre la propagation DNS (24-48h)

Vérifier avec :

```bash
dig expert-humidite-bordeaux.fr +short
# Devrait afficher: 75.2.60.5

dig www.expert-humidite-bordeaux.fr +short
# Devrait afficher: expert-humidite-multi-villes.netlify.app
```

Ou utiliser le script de vérification :

```bash
./scripts/verify-domains.sh
```

✅ **HTTPS s'active automatiquement** dès que les DNS sont propagés (1-5 min après)

---

### 6️⃣ Activer Force HTTPS (30 sec par domaine)

Dans Netlify → **Domain management** :

1. Pour chaque domaine, aller dans **HTTPS**
2. Activer **"Force HTTPS"**
3. Activer **"Certificate renewal"** (auto)

✅ **Redirection automatique** http → https

---

## 📊 Checklist Rapide

- [ ] Site créé sur Netlify depuis GitHub
- [ ] Site renommé `expert-humidite-multi-villes`
- [ ] 44 domaines ajoutés via script API
- [ ] DNS A (75.2.60.5) configuré pour tous les domaines
- [ ] DNS CNAME (netlify.app) configuré pour www
- [ ] Propagation DNS vérifiée (dig ou script)
- [ ] HTTPS actif sur tous les domaines
- [ ] Force HTTPS activé

---

## ⏱️ Timeline

| Étape | Durée |
|-------|-------|
| Création site + 1er déploiement | 2 min |
| Renommer le site | 30 sec |
| Ajouter 44 domaines (script) | 2 min |
| Configurer DNS (44 domaines) | 4-6h |
| **Propagation DNS** | **24-48h** |
| Activation HTTPS (auto) | 1-5 min après DNS |
| Activer Force HTTPS | 30 sec × 44 = 22 min |

**Total actif** : ~5-7h
**Total passif (attente)** : 24-48h

---

## 🛠️ Scripts Utiles

### Ajouter les domaines automatiquement

```bash
export NETLIFY_SITE_ID="votre-site-id"
export NETLIFY_TOKEN="votre-token"
./scripts/add-netlify-domains.sh
```

### Vérifier tous les domaines

```bash
./scripts/verify-domains.sh
```

### Tester le build en local

```bash
npm run build
npm run preview  # Tester le build en local
```

---

## 🆘 Problèmes Courants

### Le site affiche toujours "Bordeaux"

**Cause** : Le fichier JSON de la ville n'existe pas encore.

**Solution** : Pour l'instant, c'est normal. Seul `bordeaux.json` existe. Les 43 autres fichiers JSON seront créés en Phase 2. Le système de détection fonctionne, il fallback juste sur Bordeaux.

### HTTPS ne s'active pas

**Cause** : DNS pas encore propagé.

**Solution** :
1. Vérifier DNS : `dig expert-humidite-[ville].fr +short`
2. Si ≠ 75.2.60.5, attendre encore
3. Si = 75.2.60.5, attendre 1-2h de plus
4. Netlify → **Domain management** → **Verify DNS configuration**

### Build échoue

**Cause** : Erreur dans le code.

**Solution** :
1. Netlify → **Deploys** → Voir les logs
2. Reproduire : `npm run build`
3. Corriger → Push → Auto-redéploiement

---

## 📞 Support

- **Guide détaillé** : [NETLIFY-DEPLOY-GUIDE.md](./NETLIFY-DEPLOY-GUIDE.md)
- **Configuration DNS** : [DNS-CONFIGURATION.md](./DNS-CONFIGURATION.md)
- **Netlify Support** : https://answers.netlify.com

---

## 🎉 C'est tout !

Vous avez maintenant **44 sites en ligne** sur **44 domaines** avec :

✅ HTTPS automatique et gratuit
✅ Auto-déploiement depuis GitHub
✅ CDN mondial ultra-rapide
✅ Détection automatique de la ville par domaine
✅ 0€ d'hébergement (plan gratuit)

**Félicitations !** 🎊
