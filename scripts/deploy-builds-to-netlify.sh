#!/bin/bash
# Déploiement des builds sur les sites Netlify existants
# Prérequis: NETLIFY_AUTH_TOKEN défini
# Usage: export NETLIFY_AUTH_TOKEN="ton-token" && ./scripts/deploy-builds-to-netlify.sh

set -e

echo "🚀 Déploiement des builds vers Netlify"
echo "======================================="
echo ""

# Vérifier le token
if [ -z "$NETLIFY_AUTH_TOKEN" ]; then
    echo "❌ NETLIFY_AUTH_TOKEN non défini"
    echo ""
    echo "Usage: export NETLIFY_AUTH_TOKEN='ton-token' && ./scripts/deploy-builds-to-netlify.sh"
    exit 1
fi

# Vérifier que les builds existent
if [ ! -d "builds" ]; then
    echo "❌ Dossier builds/ introuvable"
    echo "Lance d'abord: ./scripts/build-all-cities.sh"
    exit 1
fi

# Lire le fichier cities
CITIES_FILE="cities-full.json"

if [ ! -f "$CITIES_FILE" ]; then
    echo "❌ Fichier $CITIES_FILE introuvable"
    exit 1
fi

# Vérifier jq
if ! command -v jq &> /dev/null; then
    echo "❌ jq non installé : brew install jq"
    exit 1
fi

# Extraire la liste des villes
CITIES=$(cat "$CITIES_FILE" | jq -r '.cities[] | @json')
COUNT=0
TOTAL=$(echo "$CITIES" | wc -l | tr -d ' ')
DEPLOYED=0
SKIPPED=0
FAILED=0

echo "📦 $TOTAL builds à déployer"
echo ""

# Boucle sur chaque ville
while IFS= read -r city; do
    ((COUNT++))

    SLUG=$(echo "$city" | jq -r '.slug')
    NAME=$(echo "$city" | jq -r '.name')
    SITE_NAME="expert-humidite-$SLUG"
    BUILD_DIR="builds/$SLUG"

    echo "[$COUNT/$TOTAL] 🏙️  $NAME ($SITE_NAME)..."

    # Vérifier que le build existe
    if [ ! -d "$BUILD_DIR" ]; then
        echo "   ❌ Build introuvable dans $BUILD_DIR"
        ((FAILED++))
        echo ""
        continue
    fi

    # Vérifier si le site existe sur Netlify
    SITE_ID=$(curl -s -X GET "https://api.netlify.com/api/v1/sites?name=$SITE_NAME" \
        -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" | jq -r '.[0].id // empty')

    if [ -z "$SITE_ID" ]; then
        echo "   ⚠️  Site Netlify n'existe pas encore, skip"
        ((SKIPPED++))
    else
        echo "   → Déploiement vers $SITE_NAME (ID: $SITE_ID)..."

        # Créer un zip du build
        ZIP_FILE="/tmp/${SITE_NAME}-deploy.zip"
        (cd "$BUILD_DIR" && zip -r -q "$ZIP_FILE" .)

        # Upload via API Netlify
        DEPLOY_RESPONSE=$(curl -s -X POST "https://api.netlify.com/api/v1/sites/$SITE_ID/deploys" \
            -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
            -H "Content-Type: application/zip" \
            --data-binary "@$ZIP_FILE")

        DEPLOY_ID=$(echo "$DEPLOY_RESPONSE" | jq -r '.id // empty')

        if [ -n "$DEPLOY_ID" ]; then
            DEPLOY_URL=$(echo "$DEPLOY_RESPONSE" | jq -r '.ssl_url // .url')
            echo "   ✅ Déployé : $DEPLOY_URL"
            ((DEPLOYED++))

            # Nettoyer le zip
            rm -f "$ZIP_FILE"
        else
            ERROR=$(echo "$DEPLOY_RESPONSE" | jq -r '.message // "Erreur inconnue"')
            echo "   ❌ Erreur : $ERROR"
            ((FAILED++))
        fi
    fi

    echo ""

done <<< "$CITIES"

echo "=========================================="
echo "✅ Déploiement terminé !"
echo ""
echo "📊 Statistiques :"
echo "   - Traités : $COUNT/$TOTAL"
echo "   - Déployés : $DEPLOYED"
echo "   - Sites inexistants (skipped) : $SKIPPED"
echo "   - Erreurs : $FAILED"
echo ""

if [ $SKIPPED -gt 0 ]; then
    echo "⚠️  $SKIPPED sites n'existent pas encore sur Netlify"
    echo "   Lance d'abord : export NETLIFY_AUTH_TOKEN='...' && ./scripts/create-sites-api.sh"
    echo ""
fi

echo "🔍 Vérification :"
echo "   Teste chaque URL dans ton navigateur :"
echo "   - https://expert-humidite-paris.netlify.app"
echo "   - https://expert-humidite-lyon.netlify.app"
echo "   - https://expert-humidite-marseille.netlify.app"
echo "   - ..."
echo ""
