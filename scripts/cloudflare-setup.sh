#!/bin/bash

# Script d'automatisation complète Cloudflare pour Expert Humidité
# Ajoute les domaines + Configure DNS automatiquement
# Usage: ./cloudflare-setup.sh

set -e

echo "🚀 Configuration automatique Cloudflare"
echo "======================================="
echo ""

# Configuration
CF_API_TOKEN="${CLOUDFLARE_API_TOKEN:-}"
CF_ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-}"
NETLIFY_SITE_URL="${NETLIFY_SITE_URL:-expert-humidite-multi-villes.netlify.app}"

# Vérification des variables
if [ -z "$CF_API_TOKEN" ]; then
  echo "❌ Erreur: Variable CLOUDFLARE_API_TOKEN non définie"
  echo ""
  echo "Pour créer un token API:"
  echo "1. Aller sur https://dash.cloudflare.com/profile/api-tokens"
  echo "2. Cliquer 'Create Token'"
  echo "3. Utiliser le template 'Edit zone DNS'"
  echo "4. Permissions:"
  echo "   - Zone:DNS:Edit"
  echo "   - Zone:Zone:Read"
  echo "   - Account:Zone:Read"
  echo "5. Copier le token"
  echo ""
  echo "Ensuite, exécuter:"
  echo "export CLOUDFLARE_API_TOKEN=votre-token"
  echo "export CLOUDFLARE_ACCOUNT_ID=votre-account-id"
  echo "export NETLIFY_SITE_URL=expert-humidite-multi-villes.netlify.app"
  echo "./cloudflare-setup.sh"
  exit 1
fi

if [ -z "$CF_ACCOUNT_ID" ]; then
  echo "❌ Erreur: Variable CLOUDFLARE_ACCOUNT_ID non définie"
  echo ""
  echo "Pour trouver votre Account ID:"
  echo "1. Aller sur https://dash.cloudflare.com"
  echo "2. Sélectionner n'importe quel domaine"
  echo "3. Dans la sidebar droite, copier 'Account ID'"
  echo ""
  echo "Ensuite, exécuter:"
  echo "export CLOUDFLARE_API_TOKEN=votre-token"
  echo "export CLOUDFLARE_ACCOUNT_ID=votre-account-id"
  echo "./cloudflare-setup.sh"
  exit 1
fi

echo "✅ Configuration OK"
echo "Account ID: $CF_ACCOUNT_ID"
echo "Token: ${CF_API_TOKEN:0:20}..."
echo "Netlify URL: $NETLIFY_SITE_URL"
echo ""

# Liste des 44 domaines
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

echo "📋 ${#DOMAINS[@]} domaines à configurer"
echo ""

ADDED=0
CONFIGURED=0
ALREADY_EXISTS=0
FAILED=0

for domain in "${DOMAINS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🌐 Configuration de: $domain"
  echo ""

  # Étape 1: Vérifier si le domaine existe déjà dans Cloudflare
  echo -n "  1️⃣  Vérification du domaine... "

  ZONE_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$domain" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json")

  ZONE_ID=$(echo "$ZONE_CHECK" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

  if [ -n "$ZONE_ID" ]; then
    echo "✅ Existe (Zone ID: ${ZONE_ID:0:15}...)"
    ((ALREADY_EXISTS++))
  else
    # Étape 2: Ajouter le domaine à Cloudflare
    echo "🆕 N'existe pas, ajout..."

    ADD_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones" \
      -H "Authorization: Bearer $CF_API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{
        \"account\": {\"id\": \"$CF_ACCOUNT_ID\"},
        \"name\": \"$domain\",
        \"type\": \"full\"
      }")

    ZONE_ID=$(echo "$ADD_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

    if [ -n "$ZONE_ID" ]; then
      echo "     ✅ Domaine ajouté (Zone ID: ${ZONE_ID:0:15}...)"
      ((ADDED++))
    else
      echo "     ❌ Échec de l'ajout"
      echo "$ADD_RESPONSE" | head -3
      ((FAILED++))
      continue
    fi
  fi

  # Étape 3: Supprimer les anciens enregistrements DNS
  echo "  2️⃣  Nettoyage des anciens DNS... "

  EXISTING_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json")

  RECORD_IDS=$(echo "$EXISTING_RECORDS" | grep -o '"id":"[^"]*' | cut -d'"' -f4)

  if [ -n "$RECORD_IDS" ]; then
    DELETED_COUNT=0
    while IFS= read -r record_id; do
      curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id" \
        -H "Authorization: Bearer $CF_API_TOKEN" > /dev/null
      ((DELETED_COUNT++))
    done <<< "$RECORD_IDS"
    echo "     ✅ $DELETED_COUNT anciens enregistrements supprimés"
  else
    echo "     ℹ️  Aucun enregistrement existant"
  fi

  # Étape 4: Créer l'enregistrement A (@ → Netlify)
  echo "  3️⃣  Création DNS A record... "

  A_RECORD=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{
      \"type\": \"A\",
      \"name\": \"@\",
      \"content\": \"75.2.60.5\",
      \"ttl\": 1,
      \"proxied\": true
    }")

  if echo "$A_RECORD" | grep -q '"success":true'; then
    echo "     ✅ A record créé (@ → 75.2.60.5) avec proxy Cloudflare"
  else
    echo "     ❌ Échec A record"
  fi

  # Étape 5: Créer l'enregistrement CNAME (www → Netlify)
  echo "  4️⃣  Création DNS CNAME record... "

  CNAME_RECORD=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{
      \"type\": \"CNAME\",
      \"name\": \"www\",
      \"content\": \"$NETLIFY_SITE_URL\",
      \"ttl\": 1,
      \"proxied\": true
    }")

  if echo "$CNAME_RECORD" | grep -q '"success":true'; then
    echo "     ✅ CNAME créé (www → $NETLIFY_SITE_URL) avec proxy"
  else
    echo "     ❌ Échec CNAME"
  fi

  # Étape 6: Configurer SSL/TLS en mode Full
  echo "  5️⃣  Configuration SSL/TLS Full... "

  SSL_CONFIG=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/ssl" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"value":"full"}')

  if echo "$SSL_CONFIG" | grep -q '"success":true'; then
    echo "     ✅ SSL/TLS configuré en mode Full"
  fi

  # Étape 7: Activer Always Use HTTPS
  echo "  6️⃣  Activation Always Use HTTPS... "

  HTTPS_CONFIG=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/always_use_https" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"value":"on"}')

  if echo "$HTTPS_CONFIG" | grep -q '"success":true'; then
    echo "     ✅ Always Use HTTPS activé"
  fi

  ((CONFIGURED++))
  echo "  ✅ $domain configuré avec succès!"
  echo ""

  # Pause pour éviter rate limiting
  sleep 1
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Résumé Final"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Domaines:"
echo "  🆕 Ajoutés: $ADDED"
echo "  ♻️  Déjà existants: $ALREADY_EXISTS"
echo "  ✅ Configurés: $CONFIGURED / ${#DOMAINS[@]}"
echo "  ❌ Échecs: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo "🎉 Tous les domaines ont été configurés avec succès!"
  echo ""
  echo "⏭️  Prochaines étapes:"
  echo ""
  echo "1. Mettre à jour les nameservers chez votre registrar:"
  echo "   Pour chaque domaine, aller chez votre registrar (Gandi, OVH, etc.)"
  echo "   et changer les nameservers vers ceux de Cloudflare."
  echo "   Cloudflare vous donnera les nameservers spécifiques pour chaque domaine."
  echo ""
  echo "2. Attendre la propagation DNS (1-24h)"
  echo ""
  echo "3. Vérifier avec:"
  echo "   ./scripts/verify-cloudflare.sh"
  echo ""
  echo "4. Ajouter les domaines dans Netlify:"
  echo "   ./scripts/add-netlify-domains.sh"
  echo ""
else
  echo "⚠️  Certains domaines n'ont pas pu être configurés."
  echo "Vérifier les messages d'erreur ci-dessus."
fi

echo ""
echo "💡 Commandes utiles:"
echo "   dig $domain +short              # Vérifier DNS"
echo "   curl -I https://$domain         # Tester HTTPS"
echo "   ./scripts/verify-cloudflare.sh  # Vérifier tous les domaines"
