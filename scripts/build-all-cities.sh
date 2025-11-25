#!/bin/bash
# Script de build de 44 sites séparés (un par ville)
# Chaque build est configuré pour une ville spécifique
# Usage: ./scripts/build-all-cities.sh

set -e

echo "🏗️  Build des 44 sites Expert Humidité"
echo "======================================"
echo ""

# Lire le fichier cities
CITIES_FILE="cities-full.json"

if [ ! -f "$CITIES_FILE" ]; then
    echo "❌ Fichier $CITIES_FILE introuvable"
    exit 1
fi

# Vérifier que jq est installé
if ! command -v jq &> /dev/null; then
    echo "❌ jq n'est pas installé"
    exit 1
fi

# Créer le dossier builds/ pour stocker tous les builds
BUILDS_DIR="builds"
rm -rf "$BUILDS_DIR"
mkdir -p "$BUILDS_DIR"

# Extraire la liste des villes
CITIES=$(cat "$CITIES_FILE" | jq -r '.cities[] | @json')
COUNT=0
TOTAL=$(echo "$CITIES" | wc -l | tr -d ' ')

echo "✅ $TOTAL villes à builder"
echo ""

# Boucle sur chaque ville
while IFS= read -r city; do
    ((COUNT++))

    SLUG=$(echo "$city" | jq -r '.slug')
    NAME=$(echo "$city" | jq -r '.name')
    DOMAIN=$(echo "$city" | jq -r '.domain')

    echo "[$COUNT/$TOTAL] 🏙️  Build de $NAME ($SLUG)..."

    # Modifier temporairement domain-detection.ts pour forcer cette ville
    # Sauvegarder l'original
    cp src/utils/domain-detection.ts src/utils/domain-detection.ts.bak

    # Remplacer le fallback par la ville actuelle
    sed -i.tmp "s/'localhost': 'toulouse'/'localhost': '$SLUG'/g" src/utils/domain-detection.ts
    sed -i.tmp "s/return 'toulouse'/return '$SLUG'/g" src/utils/domain-detection.ts
    rm src/utils/domain-detection.ts.tmp

    # Build le site
    echo "   → Building..."
    npm run build > /dev/null 2>&1

    # Copier le build dans builds/[ville]/
    CITY_BUILD_DIR="$BUILDS_DIR/$SLUG"
    mkdir -p "$CITY_BUILD_DIR"
    cp -r dist/* "$CITY_BUILD_DIR/"

    echo "   ✅ Build créé dans $CITY_BUILD_DIR/"

    # Restaurer le fichier original
    mv src/utils/domain-detection.ts.bak src/utils/domain-detection.ts

    echo ""

done <<< "$CITIES"

echo "======================================"
echo "✅ Tous les builds sont prêts dans builds/"
echo ""
echo "📊 Taille totale des builds :"
du -sh "$BUILDS_DIR"
echo ""
echo "📁 Structure :"
echo "   builds/"
echo "     ├── paris/         → deploy sur expert-humidite-paris"
echo "     ├── lyon/          → deploy sur expert-humidite-lyon"
echo "     ├── marseille/     → deploy sur expert-humidite-marseille"
echo "     └── ... (41 autres)"
echo ""
echo "🚀 Prochaine étape : Déployer tous les builds"
echo "   ./scripts/deploy-builds-to-netlify.sh"
echo ""
