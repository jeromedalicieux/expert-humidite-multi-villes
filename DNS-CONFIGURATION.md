# Configuration DNS pour Netlify (Domaines existants)

## 🎯 Situation

Vous avez déjà les 44 domaines chez un hébergeur/registrar (OVH, Gandi, etc.)
→ Vous voulez héberger les sites sur Netlify
→ **Solution** : Pointer les DNS vers Netlify

## ⚡ Configuration Rapide

### Étape 1 : Déployer sur Netlify

1. Aller sur https://app.netlify.com
2. "Add new site" → "Import an existing project"
3. Sélectionner GitHub → "expert-humidite-multi-villes"
4. Déployer
5. Noter l'URL : `[votre-site].netlify.app`

### Étape 2 : Ajouter le Premier Domaine (Bordeaux)

Dans Netlify → Site settings → Domain management :

1. Cliquer "Add domain"
2. Entrer : `expert-humidite-bordeaux.fr`
3. Netlify affiche les instructions DNS

### Étape 3 : Configurer les DNS chez votre Hébergeur

Aller dans l'interface DNS de votre hébergeur actuel (OVH, Gandi, etc.)

#### Configuration Requise :

```
Type: A
Nom: @ (ou vide, ou expert-humidite-bordeaux.fr)
Valeur: 75.2.60.5
TTL: 3600

Type: CNAME
Nom: www
Valeur: [votre-site].netlify.app
TTL: 3600
```

#### ⚠️ Important : Supprimer les anciens enregistrements

Avant d'ajouter les nouveaux :
- Supprimer l'ancien A record pointant vers l'ancien hébergement
- Supprimer l'ancien CNAME www si existant

### Étape 4 : Vérifier la Configuration DNS

```bash
# Vérifier l'enregistrement A
dig expert-humidite-bordeaux.fr +short
# Devrait afficher : 75.2.60.5

# Vérifier le CNAME www
dig www.expert-humidite-bordeaux.fr +short
# Devrait afficher : [votre-site].netlify.app
```

### Étape 5 : Attendre la Propagation

- Propagation DNS : 5 minutes à 48h (généralement ~1h)
- HTTPS automatique : Activé par Netlify après propagation
- Vérifier sur : https://expert-humidite-bordeaux.fr

### Étape 6 : Répéter pour les 43 Autres Domaines

Pour chaque domaine :
1. Netlify → Add domain → `expert-humidite-[ville].fr`
2. Chez votre hébergeur → Modifier DNS vers Netlify
3. Attendre propagation

## 📋 Instructions par Hébergeur

### OVH

1. Aller sur https://ovh.com/manager
2. Domaines → Choisir le domaine → Zone DNS
3. Supprimer les anciens A et CNAME
4. Ajouter :
   - Type A @ → 75.2.60.5
   - Type CNAME www → [votre-site].netlify.app
5. Cliquer "Valider"

### Gandi

1. Aller sur https://admin.gandi.net
2. Noms de domaine → Choisir le domaine
3. Enregistrements DNS → Modifier
4. Supprimer anciens A et CNAME
5. Ajouter :
   - A @ 75.2.60.5
   - CNAME www [votre-site].netlify.app

### O2Switch

1. Se connecter au cPanel
2. Zone Editor
3. Modifier les enregistrements
4. Ajouter A et CNAME vers Netlify

### Infomaniak

1. Manager → Domaines
2. Zone DNS
3. Modifier les enregistrements
4. Pointer vers Netlify

## 🔒 HTTPS / SSL

Netlify génère **automatiquement et gratuitement** un certificat SSL Let's Encrypt pour chaque domaine.

**Pas d'action requise** ✅

Le certificat se renouvelle automatiquement tous les 90 jours.

## ⚡ Configuration Avancée (Optionnel)

### Redirection www → non-www (ou inverse)

Dans Netlify → Domain management :
- Primary domain : expert-humidite-bordeaux.fr
- www automatiquement redirigé

### Sous-domaines Additionnels

Si vous voulez `blog.expert-humidite-bordeaux.fr` :

```
Type: CNAME
Nom: blog
Valeur: [votre-site].netlify.app
```

### Redirections Personnalisées

Dans votre repo, fichier `netlify.toml` :

```toml
[[redirects]]
  from = "/ancien-site/*"
  to = "/nouveau-site/:splat"
  status = 301
```

## 🧪 Tester Avant Propagation

Vous pouvez tester le site **avant** que le DNS soit propagé :

```bash
# Mac/Linux
sudo nano /etc/hosts

# Ajouter temporairement :
75.2.60.5 expert-humidite-bordeaux.fr
75.2.60.5 www.expert-humidite-bordeaux.fr
```

Puis visiter http://expert-humidite-bordeaux.fr dans votre navigateur.

**Supprimer ces lignes** après test !

## 📊 Checklist de Migration

Pour chaque domaine :

- [ ] Site déployé sur Netlify
- [ ] Domaine ajouté dans Netlify
- [ ] DNS A pointé vers 75.2.60.5
- [ ] DNS CNAME www pointé vers netlify.app
- [ ] Anciens enregistrements supprimés
- [ ] Propagation DNS vérifiée (dig)
- [ ] HTTPS actif et certificat valide
- [ ] Site accessible et affiche la bonne ville
- [ ] Redirections www fonctionnelles

## ⏱️ Timeline de Migration

**Jour 1** : Déployer sur Netlify + Configurer Bordeaux
**Jours 2-3** : Configurer les 43 autres domaines
**Jours 4-7** : Propagation DNS complète pour tous

## 💡 Astuce Pro

Vous pouvez automatiser l'ajout de domaines via l'API Netlify :

```bash
# Ajouter tous les domaines via API
curl -X POST https://api.netlify.com/api/v1/sites/[SITE_ID]/domains \
  -H "Authorization: Bearer [TOKEN]" \
  -d '{"domain_name": "expert-humidite-paris.fr"}'
```

Répéter 44 fois ou créer un script.

## 🆘 Résolution de Problèmes

### Le site n'est pas accessible après 24h

1. Vérifier DNS : `dig expert-humidite-bordeaux.fr +short`
2. Si ≠ 75.2.60.5 : DNS pas encore propagé
3. Vider cache DNS local : `sudo dscacheutil -flushcache` (Mac)

### HTTPS pas actif

1. Attendre 1-2h après propagation DNS
2. Netlify → Domain settings → "Verify DNS configuration"
3. Forcer renouvellement certificat si besoin

### Mauvaise ville affichée

1. Vérifier le fichier `domain-detection.ts`
2. Vérifier que le fichier JSON existe pour cette ville
3. Regarder les logs Netlify

## 📞 Support

- **Netlify** : https://answers.netlify.com
- **Votre hébergeur** : Pour questions DNS spécifiques

---

**Temps total estimé** : 2-3 jours pour migrer les 44 sites
**Coût** : 0€ (hébergement gratuit sur Netlify)
