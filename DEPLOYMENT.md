# Guide de Déploiement Multi-Domaines

## Architecture

Ce projet génère **44 sites web distincts**, un par ville, chacun avec son propre domaine.

## Domaines

- **Site principal (Bordeaux)** : `expert-humidite-bordeaux.fr`
- **43 autres villes** : `expert-humidite-[ville].fr`

## Stratégie de Déploiement

### Option 1 : Netlify (Recommandé)

#### Avantages
- Déploiement automatique depuis GitHub
- Support multi-domaines natif
- CDN mondial inclus
- HTTPS gratuit
- Build automatique

#### Configuration

1. **Connecter le repo GitHub**
   - Se connecter à Netlify
   - "Add new site" → "Import an existing project"
   - Sélectionner le repo `expert-humidite-multi-villes`

2. **Configuration de build**
   ```
   Build command: npm run build
   Publish directory: dist
   ```

3. **Variables d'environnement**
   - `TALLY_FORM_ID` : ID du formulaire Tally
   - `GA_TRACKING_ID` : Google Analytics ID
   - `CONTACT_EMAIL` : Email de contact
   - `CONTACT_PHONE` : Téléphone

4. **Domaines personnalisés**
   Pour chaque ville, ajouter le domaine correspondant dans Netlify :
   - Domain settings → Add custom domain
   - `expert-humidite-bordeaux.fr`
   - Configurer les DNS chez le registrar

### Option 2 : Vercel

Similaire à Netlify :
- Import du repo GitHub
- Configuration automatique Astro
- Ajout des domaines personnalisés

### Option 3 : Hébergement classique

Si vous préférez un serveur traditionnel :

```bash
# Build de production
npm run build

# Le dossier dist/ contient le site statique
# À uploader via FTP/SSH vers le serveur
```

## DNS Configuration

Pour **chaque domaine** :

### Enregistrements DNS

```
Type: A
Name: @
Value: [IP de Netlify/Vercel]

Type: CNAME
Name: www
Value: [sous-domaine Netlify/Vercel]
```

**Netlify DNS** : `[your-site].netlify.app`
**Vercel DNS** : `[your-site].vercel.app`

## Déploiement Site Bordeaux (Production)

### 1. Vérifier les variables d'environnement

Éditer `.env` dans Netlify/Vercel :
- TALLY_FORM_ID
- GA_TRACKING_ID  
- CONTACT_EMAIL
- CONTACT_PHONE

### 2. Déployer

**Via Netlify** :
```bash
# Netlify détecte automatiquement les pushs sur main
git push origin main
```

**Via Netlify CLI** :
```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod
```

### 3. Configurer le domaine

1. Aller dans Site settings → Domain management
2. Add custom domain → `expert-humidite-bordeaux.fr`
3. Configurer DNS chez le registrar :
   - Type A vers l'IP Netlify
   - Type CNAME www vers le sous-domaine Netlify

4. Activer HTTPS (automatique avec Netlify)

## Déploiement des 43 Autres Villes (Phase 2)

Une fois le système de génération multi-villes créé :

1. **Générer tous les sites**
   ```bash
   npm run generate:all-cities
   ```

2. **Créer un site Netlify par ville**
   - Soit manuellement (44 sites)
   - Soit via Netlify API (automatisé)

3. **Configurer les domaines**
   - Chaque site pointe vers son domaine spécifique
   - DNS configuré pour chaque domaine

### Alternative : Mono-repo avec routing

Au lieu de 44 sites séparés, utiliser Astro avec routing dynamique :
- Un seul déploiement
- 44 domaines pointant vers le même site
- Détection du domaine pour afficher la bonne ville

## Checklist Avant Production

- [ ] Variables d'environnement configurées
- [ ] Formulaire Tally testé
- [ ] Google Analytics configuré
- [ ] Images optimisées (WebP)
- [ ] Tests Lighthouse > 90
- [ ] SEO validé (meta tags, Schema.org)
- [ ] Domaine configuré et DNS propagé
- [ ] HTTPS actif
- [ ] Google Search Console configuré
- [ ] Mentions légales + RGPD

## Monitoring

- **Uptime** : UptimeRobot ou Pingdom
- **Analytics** : Google Analytics
- **SEO** : Google Search Console
- **Performance** : Lighthouse CI

## Coûts Estimés

### Netlify Pro (pour 44 sites)
- Gratuit jusqu'à 100 GB/mois de bande passante
- Pro : $19/mois pour plus de bande passante
- Domaines : ~10€/an par domaine = 440€/an

### Alternative : VPS
- 1 VPS pour héberger les 44 sites statiques
- Ex: Hetzner 4-8€/mois
- Domaines : 440€/an

## Support

En cas de problème :
1. Vérifier les logs de build dans Netlify
2. Tester en local : `npm run build && npm run preview`
3. Vérifier les DNS avec `dig expert-humidite-bordeaux.fr`

---

**Repo GitHub** : https://github.com/jeromedalicieux/expert-humidite-multi-villes
