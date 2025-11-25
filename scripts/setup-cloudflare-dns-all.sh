#!/bin/bash
# Script d'automatisation DNS Cloudflare pour les 44 villes
# Nécessite : CLOUDFLARE_API_TOKEN et CLOUDFLARE_ZONE_ID configurés
# Usage: export CLOUDFLARE_API_TOKEN="votre-token" && ./scripts/setup-cloudflare-dns-all.sh

set -e

echo "☁️  Configuration DNS Cloudflare pour les 44 sites"
echo "================================================="
echo ""

# Vérifier les variables d'environnement
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ Variable CLOUDFLARE_API_TOKEN non définie"
    echo "💡 Obtenez votre token sur : https://dash.cloudflare.com/profile/api-tokens"
    echo "   Permissions requises : Zone.DNS (Edit)"
    exit 1
fi

if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
    echo "⚠️  CLOUDFLARE_ZONE_ID non défini"
    echo "💡 Obtention automatique de la zone..."
    # On suppose qu'on utilise une zone parente commune (ex: expert-humidite.fr)
fi

# Fonction pour créer un enregistrement DNS
create_dns_record() {
    local DOMAIN=$1
    local NETLIFY_SITE=$2

    echo "   → Configuration DNS pour $DOMAIN..."

    # Obtenir l'ID de zone si nécessaire
    if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
        ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" | jq -r '.result[0].id')

        if [ "$ZONE_ID" = "null" ] || [ -z "$ZONE_ID" ]; then
            echo "   ⚠️  Zone Cloudflare non trouvée pour $DOMAIN"
            echo "   💡 Créez d'abord le domaine sur Cloudflare"
            return 1
        fi
    else
        ZONE_ID=$CLOUDFLARE_ZONE_ID
    fi

    # Créer l'enregistrement A/CNAME vers Netlify
    # Netlify Load Balancer IP
    NETLIFY_IP="75.2.60.5"

    # Créer enregistrement pour le domaine principal
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{
            \"type\": \"A\",
            \"name\": \"@\",
            \"content\": \"$NETLIFY_IP\",
            \"ttl\": 1,
            \"proxied\": true
        }" | jq -r '.success' > /dev/null

    # Créer enregistrement pour www → pointe vers Netlify
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{
            \"type\": \"CNAME\",
            \"name\": \"www\",
            \"content\": \"$NETLIFY_SITE.netlify.app\",
            \"ttl\": 1,
            \"proxied\": true
        }" | jq -r '.success' > /dev/null

    # Créer enregistrement pour form → pointe vers Tally
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{
            \"type\": \"CNAME\",
            \"name\": \"form\",
            \"content\": \"cname.tally.so\",
            \"ttl\": 1,
            \"proxied\": false
        }" | jq -r '.success' > /dev/null

    echo "   ✅ DNS configuré pour $DOMAIN (@ + www + form)"
}

# Lire le fichier cities
CITIES_FILE="cities-full.json"

if [ ! -f "$CITIES_FILE" ]; then
    echo "❌ Fichier $CITIES_FILE introuvable"
    exit 1
fi

# Vérifier que jq est installé
if ! command -v jq &> /dev/null; then
    echo "❌ jq n'est pas installé. Installation..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    else
        sudo apt-get install -y jq
    fi
fi

# Extraire la liste des villes
CITIES=$(cat "$CITIES_FILE" | jq -r '.cities[] | @json')
COUNT=0
TOTAL=$(echo "$CITIES" | wc -l | tr -d ' ')

echo "✅ $TOTAL domaines à configurer"
echo ""

# Boucle sur chaque ville
while IFS= read -r city; do
    ((COUNT++))

    SLUG=$(echo "$city" | jq -r '.slug')
    NAME=$(echo "$city" | jq -r '.name')
    DOMAIN=$(echo "$city" | jq -r '.domain')

    echo "[$COUNT/$TOTAL] 📍 $NAME ($DOMAIN)"

    # Créer les enregistrements DNS
    create_dns_record "$DOMAIN" "expert-humidite-$SLUG" || echo "   ⚠️  Échec pour $DOMAIN"

    # Pause pour éviter le rate limiting
    sleep 1

    echo ""

done <<< "$CITIES"

echo ""
echo "================================================="
echo "✅ Configuration DNS terminée pour $TOTAL villes"
echo ""
echo "⏱️  Les changements DNS peuvent prendre 24-48h"
echo ""
echo "🔍 Vérification recommandée :"
echo "   ./scripts/verify-dns-all.sh"
echo ""
