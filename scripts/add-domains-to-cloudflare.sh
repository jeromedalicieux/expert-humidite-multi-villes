#!/bin/bash
# Script pour ajouter automatiquement les 44 domaines sur Cloudflare
# Usage: export CLOUDFLARE_API_TOKEN="ton-token" && ./scripts/add-domains-to-cloudflare.sh

set -e

echo "☁️  Ajout des 44 domaines sur Cloudflare"
echo "========================================"
echo ""

# Vérifier le token
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ CLOUDFLARE_API_TOKEN non défini"
    echo ""
    echo "Pour obtenir le token :"
    echo "1. Va sur : https://dash.cloudflare.com/profile/api-tokens"
    echo "2. Clique sur 'Create Token'"
    echo "3. Utilise le template 'Edit zone DNS' ou crée un custom token"
    echo "4. Permissions requises : Zone.Zone (Edit), Zone.DNS (Edit)"
    echo "5. Export : export CLOUDFLARE_API_TOKEN='ton-token'"
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

# Obtenir l'account ID depuis une zone existante
ACCOUNT_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[0].account.id')

if [ "$ACCOUNT_ID" = "null" ] || [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Impossible de récupérer le compte Cloudflare"
    echo "Vérifie que ton token a les bonnes permissions ou qu'une zone existe déjà"
    exit 1
fi

echo "✅ Compte Cloudflare: $ACCOUNT_ID"
echo ""

# Extraire la liste des villes
CITIES=$(cat "$CITIES_FILE" | jq -r '.cities[] | @json')
COUNT=0
TOTAL=$(echo "$CITIES" | wc -l | tr -d ' ')
ADDED=0
SKIPPED=0
FAILED=0

echo "📦 $TOTAL domaines à ajouter"
echo ""

# Boucle sur chaque ville
while IFS= read -r city; do
    ((COUNT++))

    SLUG=$(echo "$city" | jq -r '.slug')
    NAME=$(echo "$city" | jq -r '.name')
    DOMAIN=$(echo "$city" | jq -r '.domain')

    echo "[$COUNT/$TOTAL] 🌍 $NAME ($DOMAIN)..."

    # Vérifier si le domaine existe déjà
    EXISTING=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" | jq -r '.result[0].id // empty')

    if [ -n "$EXISTING" ]; then
        echo "   ⚠️  Domaine existe déjà (Zone ID: $EXISTING)"
        ((SKIPPED++))
    else
        # Ajouter le domaine sur Cloudflare
        RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{
                \"account\": {
                    \"id\": \"$ACCOUNT_ID\"
                },
                \"name\": \"$DOMAIN\",
                \"type\": \"full\"
            }")

        ZONE_ID=$(echo "$RESPONSE" | jq -r '.result.id // empty')
        SUCCESS=$(echo "$RESPONSE" | jq -r '.success')

        if [ "$SUCCESS" = "true" ] && [ -n "$ZONE_ID" ]; then
            NAMESERVERS=$(echo "$RESPONSE" | jq -r '.result.name_servers | join(", ")')
            echo "   ✅ Ajouté : Zone ID $ZONE_ID"
            echo "   📝 Nameservers à configurer chez ton registrar :"
            echo "      $NAMESERVERS"
            ((ADDED++))
        else
            ERROR=$(echo "$RESPONSE" | jq -r '.errors[0].message // "Erreur inconnue"')
            echo "   ❌ Erreur : $ERROR"
            ((FAILED++))
        fi
    fi

    echo ""
    sleep 1

done <<< "$CITIES"

echo "=========================================="
echo "✅ Terminé !"
echo ""
echo "📊 Statistiques :"
echo "   - Traités : $COUNT/$TOTAL"
echo "   - Ajoutés : $ADDED"
echo "   - Déjà existants : $SKIPPED"
echo "   - Erreurs : $FAILED"
echo ""

if [ $ADDED -gt 0 ]; then
    echo "⚠️  IMPORTANT : Tu dois maintenant :"
    echo "   1. Aller chez ton registrar (là où tu as acheté les domaines)"
    echo "   2. Pour chaque domaine, changer les nameservers vers ceux de Cloudflare"
    echo "   3. Attendre la propagation DNS (quelques heures)"
    echo "   4. Relancer ./scripts/setup-cloudflare-dns-all.sh pour configurer les DNS"
    echo ""
fi

echo "🔍 Vérification :"
echo "   https://dash.cloudflare.com/"
echo ""
