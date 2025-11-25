# Test Multi-Domaines en Local

## Méthode 1 : Modifier /etc/hosts (Recommandé)

Ajouter ces lignes dans `/etc/hosts` :
```
127.0.0.1 expert-humidite-bordeaux.local
127.0.0.1 expert-humidite-toulouse.local
```

Puis accéder :
- http://expert-humidite-bordeaux.local:4321/ → Bordeaux
- http://expert-humidite-toulouse.local:4321/ → Toulouse

## Méthode 2 : Tests de production

Une fois déployé sur Netlify/Cloudflare :
- https://expert-humidite-bordeaux.fr → Bordeaux
- https://expert-humidite-toulouse.fr → Toulouse

## Vérification

Chaque ville doit afficher :
- Son nom dans le H1
- Ses quartiers spécifiques
- Son contexte humidité local
- Sa FAQ personnalisée
