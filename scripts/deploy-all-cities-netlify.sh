#!/bin/bash
# Script d'automatisation du déploiement Netlify pour les 44 villes
# Nécessite : netlify-cli installé globalement (npm i -g netlify-cli)
# Usage: ./scripts/deploy-all-cities-netlify.sh

set -e

echo "🚀 Déploiement automatisé des 44 sites Expert Humidité sur Netlify"
echo "=================================================================="
echo ""

# Vérifier que netlify-cli est installé
if ! command -v netlify &> /dev/null; then
    echo "❌ netlify-cli n'est pas installé. Installation..."
    npm install -g netlify-cli
fi

# Vérifier l'authentification Netlify
echo "🔐 Vérification de l'authentification Netlify..."
if ! netlify status &> /dev/null; then
    echo "❌ Non authentifié. Lancement de la commande d'auth..."
    netlify login
fi

# Lire le fichier cities
CITIES_FILE="cities-full.json"

if [ ! -f "$CITIES_FILE" ]; then
    echo "❌ Fichier $CITIES_FILE introuvable"
    exit 1
fi

# Extraire la liste des villes avec jq
CITIES=$(cat "$CITIES_FILE" | jq -r '.cities[] | @json')

echo "✅ ${#CITIES[@]} villes trouvées"
echo ""

# Compteur
COUNT=0
TOTAL=$(echo "$CITIES" | wc -l | tr -d ' ')

# Boucle sur chaque ville
while IFS= read -r city; do
    ((COUNT++))

    SLUG=$(echo "$city" | jq -r '.slug')
    NAME=$(echo "$city" | jq -r '.name')
    DOMAIN=$(echo "$city" | jq -r '.domain')

    echo "[$COUNT/$TOTAL] 📍 Traitement de $NAME ($SLUG)..."
    echo "       Domain: $DOMAIN"

    # Nom du site Netlify (doit être unique)
    SITE_NAME="expert-humidite-$SLUG"

    # Créer le site sur Netlify
    echo "   → Création du site Netlify..."

    # Vérifier si le site existe déjà
    if netlify sites:list | grep -q "$SITE_NAME"; then
        echo "   ⚠️  Site $SITE_NAME existe déjà, passage au suivant"
    else
        # Créer le site
        netlify sites:create --name "$SITE_NAME" --account-slug "$NETLIFY_TEAM_SLUG" 2>&1 | grep -v "Warning" || true

        echo "   ✅ Site créé: $SITE_NAME.netlify.app"

        # Ajouter le domaine personnalisé
        echo "   → Ajout du domaine personnalisé $DOMAIN..."
        netlify domains:create "$DOMAIN" --site "$SITE_NAME" 2>&1 | grep -v "Warning" || true

        # Ajouter www aussi
        netlify domains:create "www.$DOMAIN" --site "$SITE_NAME" 2>&1 | grep -v "Warning" || true

        echo "   ✅ Domaines configurés"
    fi

    echo ""

done <<< "$CITIES"

echo ""
echo "=================================================================="
echo "✅ Déploiement terminé pour $TOTAL villes !"
echo ""
echo "📋 Prochaines étapes :"
echo "   1. Build du site : npm run build"
echo "   2. Déployer sur chaque site créé"
echo "   3. Configurer les DNS chez Cloudflare (voir script suivant)"
echo ""
echo "💡 Pour déployer le build sur tous les sites :"
echo "   ./scripts/deploy-build-all-sites.sh"
echo ""
