# Configuration DNS Cloudflare - Guide Manuel

## 📋 Configuration pour chaque ville

Pour chaque domaine (ex: `expert-humidite-toulouse.fr`), configurer **3 enregistrements DNS** dans Cloudflare :

### 1. Enregistrement A (domaine principal)

```
Type:    A
Name:    @ (ou expert-humidite-toulouse.fr)
Target:  75.2.60.5
TTL:     Auto
Proxy:   ✅ Activé (orange cloud)
```

### 2. Enregistrement CNAME (www)

```
Type:    CNAME
Name:    www
Target:  expert-humidite-toulouse.netlify.app
TTL:     Auto
Proxy:   ✅ Activé (orange cloud)
```

### 3. Enregistrement CNAME (form pour Tally)

```
Type:    CNAME
Name:    form
Target:  cname.tally.so
TTL:     Auto
Proxy:   ⚠️ DÉSACTIVÉ (gris cloud)
```

---

## 🌍 Liste des 44 villes à configurer

### Déjà configurés

- [x] expert-humidite-bordeaux.fr → expert-humidite-bordeaux.netlify.app
- [x] expert-humidite-toulouse.fr → expert-humidite-toulouse.netlify.app

### À configurer (42 restants)

| # | Domaine | Site Netlify |
|---|---------|--------------|
| 1 | expert-humidite-paris.fr | expert-humidite-paris.netlify.app |
| 2 | expert-humidite-marseille.fr | expert-humidite-marseille.netlify.app |
| 3 | expert-humidite-lyon.fr | expert-humidite-lyon.netlify.app |
| 4 | expert-humidite-nice.fr | expert-humidite-nice.netlify.app |
| 5 | expert-humidite-nantes.fr | expert-humidite-nantes.netlify.app |
| 6 | expert-humidite-montpellier.fr | expert-humidite-montpellier.netlify.app |
| 7 | expert-humidite-strasbourg.fr | expert-humidite-strasbourg.netlify.app |
| 8 | expert-humidite-lille.fr | expert-humidite-lille.netlify.app |
| 9 | expert-humidite-rennes.fr | expert-humidite-rennes.netlify.app |
| 10 | expert-humidite-reims.fr | expert-humidite-reims.netlify.app |
| 11 | expert-humidite-saint-etienne.fr | expert-humidite-saint-etienne.netlify.app |
| 12 | expert-humidite-toulon.fr | expert-humidite-toulon.netlify.app |
| 13 | expert-humidite-le-havre.fr | expert-humidite-le-havre.netlify.app |
| 14 | expert-humidite-villeurbanne.fr | expert-humidite-villeurbanne.netlify.app |
| 15 | expert-humidite-dijon.fr | expert-humidite-dijon.netlify.app |
| 16 | expert-humidite-angers.fr | expert-humidite-angers.netlify.app |
| 17 | expert-humidite-grenoble.fr | expert-humidite-grenoble.netlify.app |
| 18 | expert-humidite-nimes.fr | expert-humidite-nimes.netlify.app |
| 19 | expert-humidite-aix-en-provence.fr | expert-humidite-aix-en-provence.netlify.app |
| 20 | expert-humidite-clermont-ferrand.fr | expert-humidite-clermont-ferrand.netlify.app |
| 21 | expert-humidite-le-mans.fr | expert-humidite-le-mans.netlify.app |
| 22 | expert-humidite-brest.fr | expert-humidite-brest.netlify.app |
| 23 | expert-humidite-tours.fr | expert-humidite-tours.netlify.app |
| 24 | expert-humidite-amiens.fr | expert-humidite-amiens.netlify.app |
| 25 | expert-humidite-limoges.fr | expert-humidite-limoges.netlify.app |
| 26 | expert-humidite-annecy.fr | expert-humidite-annecy.netlify.app |
| 27 | expert-humidite-boulogne-billancourt.fr | expert-humidite-boulogne-billancourt.netlify.app |
| 28 | expert-humidite-metz.fr | expert-humidite-metz.netlify.app |
| 29 | expert-humidite-perpignan.fr | expert-humidite-perpignan.netlify.app |
| 30 | expert-humidite-besancon.fr | expert-humidite-besancon.netlify.app |
| 31 | expert-humidite-orleans.fr | expert-humidite-orleans.netlify.app |
| 32 | expert-humidite-rouen.fr | expert-humidite-rouen.netlify.app |
| 33 | expert-humidite-montreuil.fr | expert-humidite-montreuil.netlify.app |
| 34 | expert-humidite-caen.fr | expert-humidite-caen.netlify.app |
| 35 | expert-humidite-argenteuil.fr | expert-humidite-argenteuil.netlify.app |
| 36 | expert-humidite-saint-denis.fr | expert-humidite-saint-denis.netlify.app |
| 37 | expert-humidite-mulhouse.fr | expert-humidite-mulhouse.netlify.app |
| 38 | expert-humidite-nancy.fr | expert-humidite-nancy.netlify.app |
| 39 | expert-humidite-dax.fr | expert-humidite-dax.netlify.app |
| 40 | expert-humidite-pau.fr | expert-humidite-pau.netlify.app |
| 41 | expert-humidite-bayonne.fr | expert-humidite-bayonne.netlify.app |
| 42 | expert-humidite-mont-de-marsan.fr | expert-humidite-mont-de-marsan.netlify.app |

---

## 📝 Template de configuration (copier-coller)

Pour faciliter la configuration, voici le template à utiliser :

### Pour Toulouse (exemple)

```
# Enregistrement 1
Type: A | Name: @ | Target: 75.2.60.5 | Proxy: ON

# Enregistrement 2
Type: CNAME | Name: www | Target: expert-humidite-toulouse.netlify.app | Proxy: ON

# Enregistrement 3
Type: CNAME | Name: form | Target: cname.tally.so | Proxy: OFF
```

### Pour Paris

```
# Enregistrement 1
Type: A | Name: @ | Target: 75.2.60.5 | Proxy: ON

# Enregistrement 2
Type: CNAME | Name: www | Target: expert-humidite-paris.netlify.app | Proxy: ON

# Enregistrement 3
Type: CNAME | Name: form | Target: cname.tally.so | Proxy: OFF
```

*(Répéter pour les 42 autres villes)*

---

## ⚠️ Points importants

### Proxy Cloudflare

- **ON (orange)** pour `@` et `www` : Active le CDN, SSL automatique, protection DDoS
- **OFF (gris)** pour `form` : Nécessaire pour que Tally fonctionne correctement

### Délai de propagation

- **Immédiat** : Cloudflare met à jour en quelques secondes
- **Cache DNS** : Peut prendre 5-10 minutes pour être visible partout
- **Maximum** : 24-48h dans de rares cas

### Vérification

Tester avec :
```bash
# Domaine principal
dig expert-humidite-toulouse.fr

# WWW
dig www.expert-humidite-toulouse.fr

# Form (Tally)
dig form.expert-humidite-toulouse.fr

# Tester dans le navigateur
curl -I https://expert-humidite-toulouse.fr
curl -I https://www.expert-humidite-toulouse.fr
curl -I https://form.expert-humidite-toulouse.fr
```

---

## 🤖 Alternative : Script automatisé

Si tu préfères automatiser, utiliser le script avec l'API Cloudflare :

```bash
export CLOUDFLARE_API_TOKEN="ton-token"
./scripts/setup-cloudflare-dns-all.sh
```

Ce script configure automatiquement les 44 domaines avec les 3 enregistrements (A, CNAME www, CNAME form).

---

## 📊 Progression

- ✅ Configurés : 2/44 (Bordeaux, Toulouse)
- ⏳ Restants : 42/44

---

**Dernière mise à jour :** 25 novembre 2025
