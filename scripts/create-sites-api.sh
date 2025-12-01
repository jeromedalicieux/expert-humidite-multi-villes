#!/bin/bash
# Création des sites Netlify via API (plus fiable que CLI)
# Prérequis: Obtenir un Personal Access Token sur https://app.netlify.com/user/applications
# Usage: export NETLIFY_AUTH_TOKEN="ton-token" && ./scripts/create-sites-api.sh

set -e

echo "🚀 Création des 44 sites via l'API Netlify"
echo "=========================================="
echo ""

# Vérifier le token
if [ -z "$NETLIFY_AUTH_TOKEN" ]; then
    echo "❌ NETLIFY_AUTH_TOKEN non défini"
    echo ""
    echo "Pour obtenir le token :"
    echo "1. Va sur : https://app.netlify.com/user/applications"
    echo "2. Clique sur 'New access token'"
    echo "3. Copie le token"
    echo "4. Export : export NETLIFY_AUTH_TOKEN='ton-token'"
    echo ""
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

# Obtenir l'account slug (ID du team)
ACCOUNT_SLUG=$(curl -s -X GET "https://api.netlify.com/api/v1/accounts" \
    -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" | jq -r '.[0].slug')

if [ "$ACCOUNT_SLUG" = "null" ] || [ -z "$ACCOUNT_SLUG" ]; then
    echo "❌ Impossible de récupérer le compte Netlify"
    exit 1
fi

echo "✅ Compte Netlify: $ACCOUNT_SLUG"
echo ""

# Extraire la liste des villes
CITIES=$(cat "$CITIES_FILE" | jq -r '.cities[] | @json')
COUNT=0
TOTAL=$(echo "$CITIES" | wc -l | tr -d ' ')
CREATED=0
SKIPPED=0

# Boucle sur chaque ville
while IFS= read -r city; do
    ((COUNT++))

    SLUG=$(echo "$city" | jq -r '.slug')
    NAME=$(echo "$city" | jq -r '.name')
    SITE_NAME="expert-humidite-$SLUG"

    echo "[$COUNT/$TOTAL] 🏙️  $NAME ($SITE_NAME)..."

    # Vérifier si le site existe déjà
    EXISTING=$(curl -s -X GET "https://api.netlify.com/api/v1/sites?name=$SITE_NAME" \
        -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" | jq -r '.[0].id // empty')

    if [ -n "$EXISTING" ]; then
        echo "   ⚠️  Site existe déjà (ID: $EXISTING)"
        ((SKIPPED++))
    else
        # Créer le site via API
        RESPONSE=$(curl -s -X POST "https://api.netlify.com/api/v1/sites" \
            -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{
                \"name\": \"$SITE_NAME\",
                \"account_slug\": \"$ACCOUNT_SLUG\",
                \"custom_domain\": null
            }")

        SITE_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

        if [ -n "$SITE_ID" ]; then
            SITE_URL=$(echo "$RESPONSE" | jq -r '.ssl_url // .url')
            echo "   ✅ Créé : $SITE_URL"
            ((CREATED++))
        else
            ERROR=$(echo "$RESPONSE" | jq -r '.message // "Erreur inconnue"')
            echo "   ❌ Erreur : $ERROR"
        fi
    fi

    echo ""

done <<< "$CITIES"

echo "=========================================="
echo "✅ Terminé !"
echo ""
echo "📊 Statistiques :"
echo "   - Traités : $COUNT/$TOTAL"
echo "   - Créés : $CREATED"
echo "   - Déjà existants : $SKIPPED"
echo ""
echo "🔍 Vérification :"
echo "   netlify sites:list | grep expert-humidite"
echo ""
