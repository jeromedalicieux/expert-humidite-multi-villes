#!/bin/bash

NETLIFY_TOKEN="nfp_FuuqkKDzhfZLumf3Dx1MQ6oGcsVCAPQ80b11"

echo "🔍 Test de connexion Netlify API..."

# Test avec le site Bordeaux
SITE_ID="63153712-52d9-41d4-a373-953fed4ab8b6"
DOMAIN="www.expert-humidite-bordeaux.fr"

RESPONSE=$(curl -s -X POST "https://api.netlify.com/api/v1/sites/${SITE_ID}/domains" \
    -H "Authorization: Bearer ${NETLIFY_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"domain\":\"${DOMAIN}\"}")

echo "Réponse API:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
