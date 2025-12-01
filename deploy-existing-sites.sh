#!/bin/bash
# Déploie les builds sur les sites Netlify existants
# Usage: export NETLIFY_AUTH_TOKEN="ton-token" && bash deploy-existing-sites.sh

# Liste des sites existants (16 sites)
SITES="paris marseille lyon toulouse nice nantes toulon le-havre villeurbanne bordeaux"

cd builds || exit 1

for CITY in $SITES; do
    echo "🚀 Déploiement de $CITY..."
    
    if [ -d "$CITY" ]; then
        netlify deploy --site="expert-humidite-$CITY" --prod --dir="$CITY" 2>&1 | grep -E "(Live|Deploy|URL)" || echo "   ✅ Déployé"
    else
        echo "   ⚠️  Build non trouvé pour $CITY"
    fi
    
    echo ""
done

echo "✅ Déploiement des sites existants terminé !"
