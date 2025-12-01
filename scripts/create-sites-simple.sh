#!/bin/bash
# Script simplifié pour créer uniquement les sites Netlify (sans configuration domaine)
# Usage: ./scripts/create-sites-simple.sh

set -e

echo "🚀 Création simple des 44 sites Netlify"
echo "======================================="
echo ""

# Liste manuelle des 44 villes
CITIES="paris marseille lyon toulouse nice nantes montpellier strasbourg bordeaux lille rennes reims saint-etienne toulon le-havre villeurbanne dijon angers grenoble nimes aix-en-provence clermont-ferrand le-mans brest tours amiens limoges annecy boulogne-billancourt metz perpignan besancon orleans rouen montreuil caen argenteuil saint-denis mulhouse nancy dax pau bayonne mont-de-marsan"

COUNT=0
TOTAL=44

for CITY in $CITIES; do
    ((COUNT++))
    echo "[$COUNT/$TOTAL] Création de expert-humidite-$CITY..."

    # Vérifier si le site existe déjà
    if netlify sites:list 2>/dev/null | grep -q "expert-humidite-$CITY"; then
        echo "   ⚠️  Site existe déjà, skip"
    else
        # Créer le site (va demander interactivement la team)
        netlify sites:create --name "expert-humidite-$CITY" 2>&1 | tail -3 || echo "   ❌ Erreur"
    fi

    echo ""
done

echo "======================================"
echo "✅ Processus terminé"
echo ""
echo "Vérification :"
netlify sites:list | grep expert-humidite | wc -l | xargs echo "Sites créés:"
echo ""
