# Guide de Déploiement Netlify - Expert Humidité Multi-Villes

## 🎯 Objectif

Déployer le site Expert Humidité sur Netlify avec support multi-domaines (44 villes).

---

## ✅ Prérequis

- [x] Compte Netlify existant
- [x] Repo GitHub : https://github.com/jeromedalicieux/expert-humidite-multi-villes
- [x] 44 domaines déjà achetés chez un hébergeur (OVH, Gandi, etc.)
- [x] Build testé en local (✅ fonctionne)

---

## 📋 Étape 1 : Créer le Site sur Netlify

### 1.1 Se connecter à Netlify
1. Aller sur https://app.netlify.com
2. Se connecter avec votre compte

### 1.2 Créer un nouveau site
1. Cliquer sur **"Add new site"** → **"Import an existing project"**
2. Choisir **GitHub** comme source
3. Autoriser Netlify à accéder à vos repos si ce n'est pas déjà fait
4. Rechercher et sélectionner le repo : **`expert-humidite-multi-villes`**

### 1.3 Configurer le build
Netlify devrait détecter automatiquement la configuration depuis `netlify.toml`, mais vérifier :

```
Build command: npm run build
Publish directory: dist
Branch to deploy: main
```

5. Cliquer sur **"Deploy"**

⏱️ Le premier déploiement prend ~1-2 minutes.

### 1.4 Vérifier le déploiement
1. Une fois terminé, Netlify génère une URL temporaire : `https://[random-name].netlify.app`
2. Cliquer sur l'URL pour vérifier que le site Bordeaux s'affiche correctement
3. Vous devriez voir le site "Expert Humidité Bordeaux" complet

✅ **Étape 1 terminée !** Votre site est en ligne sur Netlify.

---

## 📋 Étape 2 : Renommer le Site (Optionnel mais recommandé)

Pour avoir une URL Netlify plus propre :

1. Dans Netlify, aller dans **Site settings** → **General** → **Site details**
2. Cliquer sur **"Change site name"**
3. Entrer : `expert-humidite-multi-villes`
4. Sauvegarder

✅ URL Netlify : `https://expert-humidite-multi-villes.netlify.app`

---

## 📋 Étape 3 : Ajouter le Premier Domaine (Bordeaux)

### 3.1 Dans Netlify
1. Aller dans **Domain management** (dans le menu de gauche)
2. Cliquer sur **"Add a domain"**
3. Entrer : `expert-humidite-bordeaux.fr`
4. Cliquer sur **"Verify"**
5. Netlify détecte que vous possédez déjà le domaine → Cliquer **"Add domain"**
6. Netlify affiche maintenant les instructions DNS

### 3.2 Configurer les DNS chez votre hébergeur

Netlify vous donne 2 enregistrements à créer :

**Enregistrement A (pour le domaine racine) :**
```
Type: A
Nom: @ (ou expert-humidite-bordeaux.fr)
Valeur: 75.2.60.5
TTL: 3600
```

**Enregistrement CNAME (pour www) :**
```
Type: CNAME
Nom: www
Valeur: expert-humidite-multi-villes.netlify.app
TTL: 3600
```

### 3.3 Étapes par hébergeur

#### Si vous êtes chez **OVH** :
1. Aller sur https://ovh.com/manager
2. Domaines → Sélectionner `expert-humidite-bordeaux.fr`
3. Onglet **"Zone DNS"**
4. **Supprimer** les anciens enregistrements A et CNAME existants
5. Cliquer **"Ajouter une entrée"** → Type A
   - Sous-domaine : (vide ou @)
   - Cible : `75.2.60.5`
6. Cliquer **"Ajouter une entrée"** → Type CNAME
   - Sous-domaine : `www`
   - Cible : `expert-humidite-multi-villes.netlify.app.` (noter le point final)
7. Valider

#### Si vous êtes chez **Gandi** :
1. Aller sur https://admin.gandi.net
2. Noms de domaine → Sélectionner `expert-humidite-bordeaux.fr`
3. **Enregistrements DNS** → Modifier
4. Supprimer anciens A et CNAME
5. Ajouter :
   - `@ 3600 IN A 75.2.60.5`
   - `www 3600 IN CNAME expert-humidite-multi-villes.netlify.app.`

#### Autres hébergeurs :
Voir le fichier [DNS-CONFIGURATION.md](./DNS-CONFIGURATION.md) pour les instructions détaillées.

### 3.4 Vérifier la propagation DNS

Attendre 10-30 minutes, puis vérifier :

```bash
# Vérifier l'enregistrement A
dig expert-humidite-bordeaux.fr +short
# Devrait afficher : 75.2.60.5

# Vérifier le CNAME www
dig www.expert-humidite-bordeaux.fr +short
# Devrait afficher : expert-humidite-multi-villes.netlify.app
```

### 3.5 Activer HTTPS dans Netlify

1. Retourner dans Netlify → **Domain management**
2. Attendre que le statut du domaine passe à **"Netlify DNS is set up"**
3. Aller dans **HTTPS** (même page)
4. Netlify génère automatiquement un certificat SSL Let's Encrypt (prend 1-5 minutes)
5. Activer **"Force HTTPS"** pour rediriger http → https automatiquement

✅ **Le site Bordeaux est maintenant accessible sur https://expert-humidite-bordeaux.fr** 🎉

---

## 📋 Étape 4 : Ajouter les 43 Autres Domaines

Pour chaque ville restante, **répéter l'Étape 3** :

### Liste des 43 domaines à ajouter :

```
expert-humidite-paris.fr
expert-humidite-lyon.fr
expert-humidite-marseille.fr
expert-humidite-toulouse.fr
expert-humidite-nice.fr
expert-humidite-nantes.fr
expert-humidite-strasbourg.fr
expert-humidite-montpellier.fr
expert-humidite-lille.fr
expert-humidite-rennes.fr
expert-humidite-reims.fr
expert-humidite-saint-etienne.fr
expert-humidite-toulon.fr
expert-humidite-grenoble.fr
expert-humidite-dijon.fr
expert-humidite-angers.fr
expert-humidite-nimes.fr
expert-humidite-villeurbanne.fr
expert-humidite-clermont-ferrand.fr
expert-humidite-le-mans.fr
expert-humidite-aix-en-provence.fr
expert-humidite-brest.fr
expert-humidite-tours.fr
expert-humidite-amiens.fr
expert-humidite-limoges.fr
expert-humidite-annecy.fr
expert-humidite-perpignan.fr
expert-humidite-boulogne-billancourt.fr
expert-humidite-metz.fr
expert-humidite-besancon.fr
expert-humidite-orleans.fr
expert-humidite-saint-denis.fr
expert-humidite-argenteuil.fr
expert-humidite-rouen.fr
expert-humidite-mulhouse.fr
expert-humidite-montreuil.fr
expert-humidite-caen.fr
expert-humidite-nancy.fr
expert-humidite-tourcoing.fr
expert-humidite-roubaix.fr
expert-humidite-vitry-sur-seine.fr
expert-humidite-avignon.fr
expert-humidite-poitiers.fr
```

### 🚀 Méthode Rapide (recommandée)

Au lieu d'ajouter manuellement les 43 domaines un par un, vous pouvez utiliser l'API Netlify :

1. Aller dans **User settings** → **Applications** → **Personal access tokens**
2. Créer un nouveau token avec scope **"Write"**
3. Noter le token (il ne sera affiché qu'une fois)

4. Créer un script `add-domains.sh` :

```bash
#!/bin/bash

SITE_ID="[VOTRE_SITE_ID]"  # Trouver dans Site settings → General
TOKEN="[VOTRE_TOKEN]"

DOMAINS=(
  "expert-humidite-paris.fr"
  "expert-humidite-lyon.fr"
  # ... ajouter tous les domaines
)

for domain in "${DOMAINS[@]}"; do
  echo "Adding $domain..."
  curl -X POST "https://api.netlify.com/api/v1/sites/$SITE_ID/domains" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"domain_name\": \"$domain\"}"
  sleep 1
done
```

5. Exécuter : `bash add-domains.sh`

⏱️ **Timeline pour ajouter tous les domaines** :
- Méthode manuelle : ~2-3 heures
- Méthode API : ~5 minutes

---

## 📋 Étape 5 : Configurer les DNS pour Tous les Domaines

Pour chaque domaine, aller chez votre hébergeur et configurer :

```
Type: A
Nom: @
Valeur: 75.2.60.5

Type: CNAME
Nom: www
Valeur: expert-humidite-multi-villes.netlify.app
```

**Conseil** : Si tous vos domaines sont chez le même hébergeur, certains proposent une fonction "Appliquer à plusieurs domaines" qui peut accélérer le processus.

⏱️ **Timeline** :
- Configuration DNS : ~3-4 heures pour 44 domaines
- Propagation complète : 24-48h

---

## 📋 Étape 6 : Vérifier Chaque Domaine

Une fois les DNS configurés, vérifier que chaque domaine :

1. **Affiche la bonne ville** : `https://expert-humidite-paris.fr` doit afficher "Paris", pas "Bordeaux"
2. **HTTPS fonctionne** : Le cadenas vert doit être présent
3. **www redirige correctement** : `www.expert-humidite-paris.fr` → `expert-humidite-paris.fr`

### Script de vérification automatique :

```bash
#!/bin/bash

DOMAINS=(
  "expert-humidite-bordeaux.fr"
  "expert-humidite-paris.fr"
  # ... tous les domaines
)

for domain in "${DOMAINS[@]}"; do
  echo "Testing $domain..."
  curl -sI "https://$domain" | head -1
  curl -s "https://$domain" | grep -o '<title>.*</title>' | head -1
  echo "---"
done
```

---

## 🔧 Configuration Avancée (Optionnel)

### Activer les Build Hooks pour auto-déploiement

1. Netlify → **Build & deploy** → **Build hooks**
2. Créer un hook : "Auto deploy on content update"
3. Copier l'URL du webhook

Utile si vous voulez déclencher un redéploiement automatique (par exemple, depuis un CMS).

### Configurer les redirections personnalisées

Si besoin, ajouter dans `netlify.toml` :

```toml
[[redirects]]
  from = "/contact"
  to = "#formulaire"
  status = 200
```

### Ajouter des variables d'environnement

1. Netlify → **Site settings** → **Environment variables**
2. Ajouter des variables (ex : `PUBLIC_GA_TRACKING_ID`)

---

## ⚠️ Résolution de Problèmes

### Le site affiche toujours "Bordeaux" sur tous les domaines

**Cause** : Le système de détection de domaine ne fonctionne pas.

**Solution** :
1. Vérifier que le fichier JSON existe pour cette ville dans `src/data/[ville].json`
2. Vérifier les logs Netlify : **Deploys** → Dernier déploiement → **Deploy log**
3. Si le JSON n'existe pas, il faut le créer (Phase 2 du projet)

### HTTPS ne s'active pas

**Cause** : DNS pas encore propagé ou mal configuré.

**Solution** :
1. Vérifier avec `dig` que les DNS pointent bien vers Netlify
2. Attendre 1-2h de plus
3. Dans Netlify → **Domain management** → Cliquer **"Verify DNS configuration"**
4. Si toujours bloqué, cliquer **"Renew certificate"**

### Le build échoue

**Cause** : Erreur dans le code ou dépendances manquantes.

**Solution** :
1. Aller dans **Deploys** → Dernier déploiement → **Deploy log**
2. Lire l'erreur complète
3. Reproduire en local : `npm run build`
4. Corriger l'erreur, commit, push → Netlify redéploie automatiquement

---

## 📊 Checklist Complète

### Phase 1 : Premier domaine (Bordeaux)
- [ ] Site créé sur Netlify depuis GitHub
- [ ] Build réussi (premier déploiement)
- [ ] URL Netlify accessible
- [ ] Site renommé en `expert-humidite-multi-villes`
- [ ] Domaine `expert-humidite-bordeaux.fr` ajouté dans Netlify
- [ ] DNS A configuré (75.2.60.5)
- [ ] DNS CNAME www configuré
- [ ] Propagation DNS vérifiée avec `dig`
- [ ] HTTPS actif avec certificat valide
- [ ] Site accessible sur https://expert-humidite-bordeaux.fr
- [ ] Force HTTPS activé

### Phase 2 : 43 domaines restants
- [ ] Tous les domaines ajoutés dans Netlify (manuellement ou via API)
- [ ] DNS configuré pour tous les domaines
- [ ] Propagation DNS vérifiée pour tous
- [ ] HTTPS actif sur tous les domaines
- [ ] Chaque domaine affiche la bonne ville (une fois les JSON créés)

---

## 📞 Support

- **Netlify Support** : https://answers.netlify.com
- **Documentation Netlify** : https://docs.netlify.com
- **DNS Propagation Check** : https://dnschecker.org

---

## ⏱️ Timeline Globale

| Étape | Durée |
|-------|-------|
| Création site Netlify + 1er déploiement | 5-10 min |
| Configuration domaine Bordeaux + DNS | 20-30 min |
| Propagation DNS Bordeaux | 1-24h |
| Ajout 43 domaines (API) | 10 min |
| Configuration DNS pour 43 domaines | 3-4h |
| Propagation DNS complète | 24-48h |
| **Total** | **2-3 jours** |

---

## 🎉 Félicitations !

Une fois toutes les étapes complétées, vous aurez :

✅ 44 sites en ligne sur 44 domaines différents
✅ HTTPS automatique et gratuit sur tous
✅ Auto-déploiement depuis GitHub (à chaque push)
✅ CDN mondial ultra-rapide
✅ Bande passante illimitée (plan gratuit jusqu'à 100GB/mois)
✅ Architecture multi-domaines avec détection automatique

**Coût total : 0€ d'hébergement** (seulement le coût des domaines ~440€/an)

---

**Prêt à déployer ? Suivez l'Étape 1 ci-dessus !** 🚀
