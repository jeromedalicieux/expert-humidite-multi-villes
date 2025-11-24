#!/bin/bash

# Script pour ajouter automatiquement tous les domaines sur Netlify via l'API
# Usage: ./add-netlify-domains.sh

set -e  # Arrêter le script en cas d'erreur

echo "🚀 Script d'ajout des domaines Netlify"
echo "======================================="
echo ""

# Configuration
SITE_ID="${NETLIFY_SITE_ID:-}"
TOKEN="${NETLIFY_TOKEN:-}"

if [ -z "$SITE_ID" ]; then
  echo "❌ Erreur: Variable NETLIFY_SITE_ID non définie"
  echo ""
  echo "Pour trouver votre SITE_ID:"
  echo "1. Aller sur https://app.netlify.com"
  echo "2. Sélectionner votre site"
  echo "3. Site settings → General → Site details"
  echo "4. Copier le 'Site ID'"
  echo ""
  echo "Ensuite, exécuter:"
  echo "export NETLIFY_SITE_ID=votre-site-id"
  echo "export NETLIFY_TOKEN=votre-token"
  echo "./add-netlify-domains.sh"
  exit 1
fi

if [ -z "$TOKEN" ]; then
  echo "❌ Erreur: Variable NETLIFY_TOKEN non définie"
  echo ""
  echo "Pour créer un token:"
  echo "1. Aller sur https://app.netlify.com/user/applications"
  echo "2. Personal access tokens → New access token"
  echo "3. Description: 'Add domains script'"
  echo "4. Copier le token"
  echo ""
  echo "Ensuite, exécuter:"
  echo "export NETLIFY_SITE_ID=votre-site-id"
  echo "export NETLIFY_TOKEN=votre-token"
  echo "./add-netlify-domains.sh"
  exit 1
fi

echo "✅ Configuration OK"
echo "Site ID: $SITE_ID"
echo "Token: ${TOKEN:0:10}..."
echo ""

# Liste complète des 44 domaines
DOMAINS=(
  "expert-humidite-bordeaux.fr"
  "expert-humidite-paris.fr"
  "expert-humidite-lyon.fr"
  "expert-humidite-marseille.fr"
  "expert-humidite-toulouse.fr"
  "expert-humidite-nice.fr"
  "expert-humidite-nantes.fr"
  "expert-humidite-strasbourg.fr"
  "expert-humidite-montpellier.fr"
  "expert-humidite-lille.fr"
  "expert-humidite-rennes.fr"
  "expert-humidite-reims.fr"
  "expert-humidite-saint-etienne.fr"
  "expert-humidite-toulon.fr"
  "expert-humidite-grenoble.fr"
  "expert-humidite-dijon.fr"
  "expert-humidite-angers.fr"
  "expert-humidite-nimes.fr"
  "expert-humidite-villeurbanne.fr"
  "expert-humidite-clermont-ferrand.fr"
  "expert-humidite-le-mans.fr"
  "expert-humidite-aix-en-provence.fr"
  "expert-humidite-brest.fr"
  "expert-humidite-tours.fr"
  "expert-humidite-amiens.fr"
  "expert-humidite-limoges.fr"
  "expert-humidite-annecy.fr"
  "expert-humidite-perpignan.fr"
  "expert-humidite-boulogne-billancourt.fr"
  "expert-humidite-metz.fr"
  "expert-humidite-besancon.fr"
  "expert-humidite-orleans.fr"
  "expert-humidite-saint-denis.fr"
  "expert-humidite-argenteuil.fr"
  "expert-humidite-rouen.fr"
  "expert-humidite-mulhouse.fr"
  "expert-humidite-montreuil.fr"
  "expert-humidite-caen.fr"
  "expert-humidite-nancy.fr"
  "expert-humidite-tourcoing.fr"
  "expert-humidite-roubaix.fr"
  "expert-humidite-vitry-sur-seine.fr"
  "expert-humidite-avignon.fr"
  "expert-humidite-poitiers.fr"
)

echo "📋 ${#DOMAINS[@]} domaines à ajouter"
echo ""

SUCCESS=0
FAILED=0
ALREADY_EXISTS=0

for domain in "${DOMAINS[@]}"; do
  echo -n "Ajout de $domain... "

  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    "https://api.netlify.com/api/v1/sites/$SITE_ID/domains" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"domain_name\": \"$domain\"}")

  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  BODY=$(echo "$RESPONSE" | head -n-1)

  if [ "$HTTP_CODE" -eq 201 ]; then
    echo "✅ Ajouté"
    ((SUCCESS++))
  elif [ "$HTTP_CODE" -eq 422 ] && echo "$BODY" | grep -q "already"; then
    echo "⚠️  Existe déjà"
    ((ALREADY_EXISTS++))
  else
    echo "❌ Erreur (HTTP $HTTP_CODE)"
    echo "   Réponse: $BODY"
    ((FAILED++))
  fi

  # Pause pour éviter le rate limiting
  sleep 0.5
done

echo ""
echo "======================================="
echo "📊 Résumé:"
echo "   ✅ Ajoutés: $SUCCESS"
echo "   ⚠️  Déjà existants: $ALREADY_EXISTS"
echo "   ❌ Échecs: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo "🎉 Tous les domaines ont été traités avec succès!"
  echo ""
  echo "⏭️  Prochaines étapes:"
  echo "1. Configurer les DNS pour chaque domaine (voir DNS-CONFIGURATION.md)"
  echo "2. Attendre la propagation DNS (24-48h)"
  echo "3. Vérifier que HTTPS s'active automatiquement"
else
  echo "⚠️  Certains domaines n'ont pas pu être ajoutés."
  echo "Vérifier les messages d'erreur ci-dessus."
  exit 1
fi
