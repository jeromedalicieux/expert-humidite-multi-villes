#!/bin/bash
# Script de déploiement automatique des 44 builds sur Netlify
# Prérequis : avoir exécuté ./scripts/build-all-cities.sh
# Usage: ./scripts/deploy-builds-to-netlify.sh

set -e

echo "🚀 Déploiement des 44 builds sur Netlify"
echo "========================================"
echo ""

BUILDS_DIR="builds"

if [ ! -d "$BUILDS_DIR" ]; then
    echo "❌ Dossier builds/ introuvable"
    echo "💡 Exécutez d'abord : ./scripts/build-all-cities.sh"
    exit 1
fi

# Vérifier que netlify-cli est installé
if ! command -v netlify &> /dev/null; then
    echo "❌ netlify-cli n'est pas installé"
    exit 1
fi

# Vérifier l'authentification
if ! netlify status &> /dev/null; then
    echo "❌ Non authentifié sur Netlify"
    netlify login
fi

# Lire le fichier cities
CITIES_FILE="cities-full.json"

if [ ! -f "$CITIES_FILE" ]; then
    echo "❌ Fichier $CITIES_FILE introuvable"
    exit 1
fi

# Extraire la liste des villes
CITIES=$(cat "$CITIES_FILE" | jq -r '.cities[] | @json')
COUNT=0
TOTAL=$(echo "$CITIES" | wc -l | tr -d ' ')

echo "✅ $TOTAL sites à déployer"
echo ""

# Demander confirmation
read -p "⚠️  Voulez-vous déployer en PRODUCTION ? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Annulé"
    exit 1
fi

echo ""

# Boucle sur chaque ville
while IFS= read -r city; do
    ((COUNT++))

    SLUG=$(echo "$city" | jq -r '.slug')
    NAME=$(echo "$city" | jq -r '.name')

    CITY_BUILD_DIR="$BUILDS_DIR/$SLUG"
    SITE_NAME="expert-humidite-$SLUG"

    if [ ! -d "$CITY_BUILD_DIR" ]; then
        echo "[$COUNT/$TOTAL] ⚠️  $NAME : build introuvable, skip"
        continue
    fi

    echo "[$COUNT/$TOTAL] 🚀 Déploiement de $NAME..."
    echo "            Site: $SITE_NAME"
    echo "            Dir:  $CITY_BUILD_DIR"

    # Déployer en production
    netlify deploy \
        --site="$SITE_NAME" \
        --prod \
        --dir="$CITY_BUILD_DIR" \
        --message="Deploy $NAME - $(date +%Y-%m-%d)" \
        2>&1 | grep -E "(Live|Production|URL)" || echo "   ✅ Déployé"

    echo ""

done <<< "$CITIES"

echo "========================================"
echo "✅ Déploiement terminé pour $TOTAL sites !"
echo ""
echo "🌐 Vérification des sites :"
echo "   netlify sites:list"
echo ""
echo "🔍 Pour voir un site spécifique :"
echo "   netlify open --site=expert-humidite-paris"
echo ""
