# ☁️ Configuration Cloudflare Automatique - Expert Humidité

Guide complet pour configurer automatiquement les 44 domaines avec Cloudflare.

---

## 🎯 Pourquoi Cloudflare ?

✅ **CDN mondial gratuit** (performance++++)
✅ **Protection DDoS** automatique
✅ **SSL/TLS gratuit** et automatique
✅ **DNS ultra-rapides** (1.1.1.1)
✅ **Cache intelligent** (moins de charge sur Netlify)
✅ **Analytics** gratuits
✅ **API puissante** pour automatisation

**Bonus** : Cloudflare est gratuit pour 44 domaines !

---

## ⚡ Configuration Automatique en 10 Minutes

### Prérequis

- [x] Compte Cloudflare (gratuit) : https://dash.cloudflare.com/sign-up
- [x] Les 44 domaines achetés chez un registrar (OVH, Gandi, etc.)
- [x] Accès aux paramètres DNS de votre registrar

---

## 📋 Étape 1 : Créer un Token API Cloudflare

### 1.1 Aller sur la page des tokens

https://dash.cloudflare.com/profile/api-tokens

### 1.2 Créer un nouveau token

1. Cliquer sur **"Create Token"**
2. Utiliser le template **"Edit zone DNS"**
3. Ou créer un custom token avec les permissions :
   - **Zone:DNS:Edit** ✅
   - **Zone:Zone:Read** ✅
   - **Account:Zone:Read** ✅

### 1.3 Configurer le token

**Permissions** :
```
Zone - DNS - Edit
Zone - Zone Settings - Read
Account - Zone - Read
```

**Zone Resources** :
- Include : All zones from an account
- Sélectionner votre account

**IP Address Filtering** : (optionnel)
- Laisser vide pour accès depuis n'importe où

4. Cliquer **"Continue to summary"**
5. Cliquer **"Create Token"**
6. **COPIER LE TOKEN** (il ne sera affiché qu'une fois !)

✅ Token créé : `abc123...xyz789`

---

## 📋 Étape 2 : Récupérer votre Account ID

1. Aller sur https://dash.cloudflare.com
2. Cliquer sur n'importe quel domaine (ou en ajouter un temporairement)
3. Dans la sidebar droite, sous **"Account Details"**, copier l'**Account ID**

✅ Account ID : `a1b2c3d4e5f6...`

---

## 📋 Étape 3 : Exécuter le Script d'Automatisation

### 3.1 Configurer les variables d'environnement

```bash
cd /Users/papa/Workspace/experts\ humidité\ sites/expert-humidite-bordeaux

export CLOUDFLARE_API_TOKEN="votre-token-copié-ici"
export CLOUDFLARE_ACCOUNT_ID="votre-account-id-ici"
export NETLIFY_SITE_URL="expert-humidite-multi-villes.netlify.app"
```

### 3.2 Lancer le script

```bash
./scripts/cloudflare-setup.sh
```

### 3.3 Que fait le script ?

Pour **chaque domaine** (les 44) :

1. ✅ Vérifie si le domaine existe sur Cloudflare
2. ✅ Ajoute le domaine à Cloudflare (si nécessaire)
3. ✅ Supprime les anciens DNS records
4. ✅ Crée l'enregistrement **A** : `@ → 75.2.60.5` (Netlify IP)
5. ✅ Crée l'enregistrement **CNAME** : `www → expert-humidite-multi-villes.netlify.app`
6. ✅ Active le **Proxy Cloudflare** (CDN + protection DDoS)
7. ✅ Configure **SSL/TLS en mode Full**
8. ✅ Active **Always Use HTTPS**

⏱️ **Durée** : ~2-3 minutes pour 44 domaines

---

## 📋 Étape 4 : Changer les Nameservers chez votre Registrar

Le script a ajouté les domaines sur Cloudflare, mais ils ne sont pas encore actifs.
Il faut **changer les nameservers** chez votre registrar (OVH, Gandi, etc.).

### 4.1 Récupérer les nameservers Cloudflare

Pour **chaque domaine** :

1. Aller sur https://dash.cloudflare.com
2. Cliquer sur le domaine (ex: `expert-humidite-bordeaux.fr`)
3. Si le domaine est en **"Pending"**, Cloudflare affiche les nameservers :

```
Nameserver 1: carter.ns.cloudflare.com
Nameserver 2: reza.ns.cloudflare.com
```

*Note : Les nameservers peuvent être différents pour chaque domaine*

### 4.2 Changer les nameservers chez votre registrar

#### Si vous êtes chez **OVH** :

1. Aller sur https://ovh.com/manager
2. **Domaines** → Sélectionner `expert-humidite-bordeaux.fr`
3. Onglet **"Serveurs DNS"**
4. Cliquer **"Modifier les serveurs DNS"**
5. Sélectionner **"Personnaliser les serveurs DNS"**
6. Entrer les nameservers Cloudflare :
   - DNS 1 : `carter.ns.cloudflare.com`
   - DNS 2 : `reza.ns.cloudflare.com`
7. Valider

**Répéter pour les 43 autres domaines**

#### Si vous êtes chez **Gandi** :

1. Aller sur https://admin.gandi.net
2. **Noms de domaine** → Sélectionner le domaine
3. **Serveurs de noms**
4. Modifier en "Serveurs de noms externes"
5. Entrer les nameservers Cloudflare
6. Enregistrer

#### Si vous êtes chez **Namecheap** :

1. Aller sur https://namecheap.com
2. **Domain List** → Manage
3. **Nameservers** → Custom DNS
4. Entrer les nameservers Cloudflare
5. Save

#### Autres registrars :

Chercher "changer nameservers [nom-du-registrar]" ou contacter leur support.

---

### 4.3 Automatisation du changement de nameservers (Optionnel)

**Attention** : Certains registrars (comme OVH) proposent une API pour automatiser le changement de nameservers.

Si tous vos domaines sont chez **le même registrar**, vous pouvez créer un script pour automatiser.

**Exemple pour OVH** (nécessite API OVH) :
```bash
# À créer si besoin
./scripts/update-nameservers-ovh.sh
```

---

## 📋 Étape 5 : Attendre l'Activation (1-48h)

Une fois les nameservers changés :

⏱️ **Propagation DNS** : 1-48h (généralement ~4-8h)

### 5.1 Vérifier l'état dans Cloudflare

1. Aller sur https://dash.cloudflare.com
2. Chaque domaine affiche son statut :
   - 🟡 **Pending** : Nameservers pas encore changés ou propagation en cours
   - 🟢 **Active** : Domaine actif sur Cloudflare !

### 5.2 Vérifier avec le script

```bash
./scripts/verify-cloudflare.sh
```

Ce script vérifie :
- ✅ Statut Cloudflare (Active/Pending)
- ✅ DNS configurés (A + CNAME)
- ✅ Proxy Cloudflare actif
- ✅ HTTPS fonctionnel

---

## 📋 Étape 6 : Ajouter les Domaines dans Netlify

Une fois que **les domaines sont actifs sur Cloudflare**, il faut les ajouter dans Netlify.

### Option 1 : Script automatique

```bash
export NETLIFY_SITE_ID="votre-site-id"
export NETLIFY_TOKEN="votre-netlify-token"
./scripts/add-netlify-domains.sh
```

### Option 2 : Manuellement

Pour chaque domaine :
1. Netlify → **Domain management**
2. **Add domain**
3. Entrer : `expert-humidite-bordeaux.fr`
4. Netlify détectera que les DNS pointent déjà vers lui
5. Répéter pour les 44 domaines

---

## 📋 Étape 7 : Vérification Finale

### 7.1 Vérifier que tout fonctionne

```bash
# Vérifier Cloudflare
./scripts/verify-cloudflare.sh

# Vérifier Netlify
./scripts/verify-domains.sh
```

### 7.2 Tester manuellement

Pour quelques domaines :

```bash
# Vérifier DNS
dig expert-humidite-bordeaux.fr +short
# Devrait afficher une IP Cloudflare (104.x.x.x ou 172.x.x.x)

dig www.expert-humidite-bordeaux.fr +short
# Devrait afficher expert-humidite-multi-villes.netlify.app puis une IP

# Tester HTTPS
curl -I https://expert-humidite-bordeaux.fr
# Devrait afficher HTTP/2 200

# Tester dans le navigateur
open https://expert-humidite-bordeaux.fr
```

### 7.3 Vérifier le contenu

**Important** : Chaque domaine doit afficher **la bonne ville**.

- `https://expert-humidite-bordeaux.fr` → Doit afficher "Bordeaux"
- `https://expert-humidite-paris.fr` → Doit afficher "Paris" (une fois le JSON créé)

Pour l'instant, seul Bordeaux a son JSON, donc les autres villes afficheront Bordeaux par défaut (c'est normal).

---

## ✅ Checklist Complète

### Phase 1 : Configuration Cloudflare
- [ ] Compte Cloudflare créé
- [ ] Token API créé et copié
- [ ] Account ID récupéré
- [ ] Script `cloudflare-setup.sh` exécuté
- [ ] 44 domaines ajoutés sur Cloudflare
- [ ] DNS configurés (A + CNAME)
- [ ] SSL/TLS configuré en Full
- [ ] Always Use HTTPS activé

### Phase 2 : Nameservers
- [ ] Nameservers Cloudflare récupérés pour chaque domaine
- [ ] Nameservers changés chez le registrar (44 domaines)
- [ ] Propagation DNS en cours (attendre 1-48h)

### Phase 3 : Activation
- [ ] Domaines actifs sur Cloudflare (statut "Active")
- [ ] DNS résolus correctement (vérifier avec `dig`)
- [ ] Proxy Cloudflare actif (CDN)
- [ ] HTTPS fonctionnel

### Phase 4 : Netlify
- [ ] 44 domaines ajoutés dans Netlify
- [ ] Sites accessibles sur tous les domaines
- [ ] Redirections www fonctionnelles

---

## 🎨 Configuration Avancée Cloudflare (Optionnel)

### Optimisations de performance

1. **Minification automatique**
   - Dashboard → Speed → Optimization
   - Activer : Auto Minify (HTML, CSS, JS)

2. **Brotli Compression**
   - Dashboard → Speed → Optimization
   - Activer : Brotli

3. **Cache Rules**
   - Dashboard → Caching → Cache Rules
   - Créer une règle pour cacher les assets statiques

4. **Rocket Loader** (optionnel)
   - Dashboard → Speed → Optimization
   - Activer : Rocket Loader (améliore le chargement JS)

### Sécurité renforcée

1. **Bot Fight Mode**
   - Dashboard → Security → Bots
   - Activer : Bot Fight Mode

2. **Security Level**
   - Dashboard → Security → Settings
   - Niveau : Medium (ou High si beaucoup d'attaques)

3. **Challenge Passage**
   - Dashboard → Security → Settings
   - Challenge Passage : 30 minutes

---

## 🔧 Résolution de Problèmes

### Le domaine reste en "Pending" après 48h

**Causes possibles** :
1. Nameservers pas changés chez le registrar
2. Propagation DNS lente
3. Anciens DNS en cache

**Solutions** :
```bash
# Vérifier les nameservers actuels
dig expert-humidite-bordeaux.fr NS +short

# Devrait afficher les nameservers Cloudflare
# carter.ns.cloudflare.com
# reza.ns.cloudflare.com

# Si ce n'est pas le cas, vérifier chez le registrar
```

### HTTPS ne fonctionne pas

**Cause** : Mode SSL/TLS incorrect

**Solution** :
1. Dashboard Cloudflare → SSL/TLS
2. Vérifier que le mode est **"Full"** (pas "Flexible" ni "Full Strict")
3. Attendre 5-10 minutes

### Le site affiche une erreur 522 (Connection timed out)

**Cause** : Cloudflare ne peut pas joindre Netlify

**Solutions** :
1. Vérifier que le domaine est ajouté dans Netlify
2. Vérifier que les DNS records pointent vers Netlify :
   - A : 75.2.60.5
   - CNAME : expert-humidite-multi-villes.netlify.app
3. Désactiver temporairement le proxy Cloudflare (nuage orange → gris)

### Le site affiche toujours "Bordeaux" sur tous les domaines

**Cause normale** : Les JSON des autres villes n'existent pas encore

**Solution** : C'est prévu pour la Phase 2 du projet.
Le système de détection fonctionne, il fallback juste sur Bordeaux par défaut.

---

## 📊 Monitoring

### Analytics Cloudflare (gratuit)

1. Dashboard → Analytics & Logs
2. Voir :
   - Trafic (requests, bandwidth)
   - Menaces bloquées
   - Performance (temps de réponse)
   - Cache hit ratio

### Web Analytics (optionnel)

Cloudflare propose un analytics privacy-first gratuit :

1. Dashboard → Web Analytics
2. Activer pour vos domaines
3. Ajouter le snippet JS dans `BaseLayout.astro`

---

## 💰 Coût

**Cloudflare** : **0€ / mois** pour 44 domaines (plan Free)

**Inclus dans le plan Free** :
- CDN illimité
- Protection DDoS illimitée
- SSL/TLS gratuit
- DNS ultra-rapides
- 10 Page Rules
- 3 Page Rules par domaine
- Analytics de base

**Si vous voulez plus** :
- Plan Pro : 20€/mois par domaine (pas nécessaire pour ce projet)

---

## ⏱️ Timeline Globale

| Étape | Durée Active | Durée Passive |
|-------|--------------|---------------|
| Créer token API | 2 min | - |
| Exécuter script | 3 min | - |
| Changer nameservers (44 domaines) | 2-4h | - |
| **Propagation DNS** | - | **4-48h** |
| Vérifier activation | 5 min | - |
| Ajouter domaines Netlify | 5 min | - |
| **Total** | **~3-5h** | **4-48h** |

---

## 🎉 Félicitations !

Une fois terminé, vous aurez :

✅ 44 domaines sur Cloudflare (CDN mondial gratuit)
✅ Protection DDoS automatique
✅ SSL/TLS gratuit et automatique
✅ DNS ultra-rapides (1.1.1.1)
✅ Cache intelligent
✅ Sites accessibles sur 44 domaines
✅ HTTPS partout

**Et tout ça gratuitement !** 🎊

---

## 📞 Support

- **Cloudflare Docs** : https://developers.cloudflare.com
- **Cloudflare Community** : https://community.cloudflare.com
- **Cloudflare Status** : https://www.cloudflarestatus.com

---

## 💡 Commandes de Référence

```bash
# Configuration complète automatique
export CLOUDFLARE_API_TOKEN="..."
export CLOUDFLARE_ACCOUNT_ID="..."
./scripts/cloudflare-setup.sh

# Vérification
./scripts/verify-cloudflare.sh

# Test DNS
dig expert-humidite-bordeaux.fr +short

# Test HTTPS
curl -I https://expert-humidite-bordeaux.fr

# Ajouter domaines Netlify
export NETLIFY_SITE_ID="..."
export NETLIFY_TOKEN="..."
./scripts/add-netlify-domains.sh
```

---

**Prêt à démarrer ?** Suivez l'**Étape 1** ci-dessus ! 🚀
