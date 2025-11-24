#!/bin/bash

# Script de vérification Cloudflare
# Vérifie que tous les domaines sont correctement configurés
# Usage: ./verify-cloudflare.sh

echo "🔍 Vérification Configuration Cloudflare"
echo "========================================"
echo ""

CF_API_TOKEN="${CLOUDFLARE_API_TOKEN:-}"

if [ -z "$CF_API_TOKEN" ]; then
  echo "⚠️  Mode vérification sans API (DNS uniquement)"
  echo "   Pour vérification complète, définir: export CLOUDFLARE_API_TOKEN=..."
  echo ""
  API_MODE=false
else
  echo "✅ Token API détecté - Vérification complète"
  echo ""
  API_MODE=true
fi

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

CF_OK=0
CF_PENDING=0
DNS_OK=0
DNS_PENDING=0
HTTPS_OK=0
HTTPS_FAILED=0
PROXIED=0

echo "📋 Vérification de ${#DOMAINS[@]} domaines"
echo ""

for domain in "${DOMAINS[@]}"; do
  echo -n "🌐 $domain: "

  if [ "$API_MODE" = true ]; then
    # Vérification via API Cloudflare
    ZONE_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$domain" \
      -H "Authorization: Bearer $CF_API_TOKEN" \
      -H "Content-Type: application/json")

    ZONE_ID=$(echo "$ZONE_CHECK" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
    STATUS=$(echo "$ZONE_CHECK" | grep -o '"status":"[^"]*' | head -1 | cut -d'"' -f4)

    if [ -n "$ZONE_ID" ]; then
      if [ "$STATUS" = "active" ]; then
        echo -n "✅ CF Active"
        ((CF_OK++))

        # Vérifier les DNS records
        DNS_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
          -H "Authorization: Bearer $CF_API_TOKEN" \
          -H "Content-Type: application/json")

        A_RECORD=$(echo "$DNS_RECORDS" | grep -o '"type":"A"' | wc -l | tr -d ' ')
        CNAME_RECORD=$(echo "$DNS_RECORDS" | grep -o '"type":"CNAME"' | wc -l | tr -d ' ')
        IS_PROXIED=$(echo "$DNS_RECORDS" | grep -o '"proxied":true' | wc -l | tr -d ' ')

        if [ "$A_RECORD" -gt 0 ] && [ "$CNAME_RECORD" -gt 0 ]; then
          echo -n " | ✅ DNS OK"
          ((DNS_OK++))
        else
          echo -n " | ⚠️  DNS incomplet (A:$A_RECORD, CNAME:$CNAME_RECORD)"
        fi

        if [ "$IS_PROXIED" -gt 0 ]; then
          echo -n " | 🛡️  Proxy ON"
          ((PROXIED++))
        fi

      else
        echo -n "⏳ CF Pending ($STATUS)"
        ((CF_PENDING++))
      fi
    else
      echo -n "❌ Pas sur CF"
      ((CF_PENDING++))
    fi
  else
    # Vérification DNS simple (sans API)
    IP=$(dig +short "$domain" | head -n1)

    if [ -n "$IP" ]; then
      # Si on obtient une IP Cloudflare (commençant par 104.x ou 172.x)
      if [[ "$IP" =~ ^104\. ]] || [[ "$IP" =~ ^172\. ]] || [[ "$IP" =~ ^75\.2\.60\.5$ ]]; then
        echo -n "✅ DNS OK ($IP)"
        ((DNS_OK++))
      else
        echo -n "⚠️  DNS vers $IP (pas Cloudflare)"
        ((DNS_PENDING++))
      fi
    else
      echo -n "❌ Pas de DNS"
      ((DNS_PENDING++))
    fi
  fi

  # Test HTTPS (pour tous les modes)
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain" --max-time 5 2>/dev/null || echo "000")

  if [ "$HTTP_CODE" = "200" ]; then
    echo " | 🔒 HTTPS OK"
    ((HTTPS_OK++))
  elif [ "$HTTP_CODE" = "000" ]; then
    echo " | ⏳ Non accessible"
    ((HTTPS_FAILED++))
  else
    echo " | ⚠️  HTTP $HTTP_CODE"
    ((HTTPS_FAILED++))
  fi

done

echo ""
echo "========================================"
echo "📊 Résumé Global"
echo "========================================"
echo ""

if [ "$API_MODE" = true ]; then
  echo "Cloudflare:"
  echo "  ✅ Actifs: $CF_OK / ${#DOMAINS[@]}"
  echo "  ⏳ En attente: $CF_PENDING / ${#DOMAINS[@]}"
  echo ""
  echo "DNS:"
  echo "  ✅ Configurés: $DNS_OK / ${#DOMAINS[@]}"
  echo "  🛡️  Avec proxy CF: $PROXIED / ${#DOMAINS[@]}"
  echo ""
else
  echo "DNS (vérification externe):"
  echo "  ✅ Résolus: $DNS_OK / ${#DOMAINS[@]}"
  echo "  ⏳ En attente: $DNS_PENDING / ${#DOMAINS[@]}"
  echo ""
fi

echo "HTTPS:"
echo "  🔒 Actifs: $HTTPS_OK / ${#DOMAINS[@]}"
echo "  ❌ Non actifs: $HTTPS_FAILED / ${#DOMAINS[@]}"
echo ""

# Calcul du pourcentage
PERCENT=$((CF_OK * 100 / ${#DOMAINS[@]}))

if [ $CF_OK -eq ${#DOMAINS[@]} ] && [ $HTTPS_OK -eq ${#DOMAINS[@]} ]; then
  echo "🎉 Configuration 100% complète!"
  echo "   Tous les domaines sont actifs avec HTTPS"
elif [ $CF_OK -gt 0 ]; then
  echo "⏳ Configuration en cours: $PERCENT%"
  echo ""
  echo "Actions recommandées:"
  if [ $CF_PENDING -gt 0 ]; then
    echo "  1. Vérifier que les nameservers sont changés chez le registrar"
    echo "  2. Attendre la propagation DNS (peut prendre 24-48h)"
  fi
  if [ $HTTPS_FAILED -gt 0 ]; then
    echo "  3. Attendre que Cloudflare active les certificats SSL"
    echo "  4. S'assurer que le mode SSL/TLS est en 'Full' dans Cloudflare"
  fi
else
  echo "⏳ Configuration pas encore démarrée"
  echo ""
  echo "Lancer:"
  echo "  export CLOUDFLARE_API_TOKEN=votre-token"
  echo "  export CLOUDFLARE_ACCOUNT_ID=votre-account-id"
  echo "  ./scripts/cloudflare-setup.sh"
fi

echo ""
echo "💡 Commandes utiles:"
echo "   dig expert-humidite-paris.fr +short    # Vérifier DNS"
echo "   curl -I https://expert-humidite-paris.fr  # Tester HTTPS"
echo ""
echo "   Pour configuration complète:"
echo "   export CLOUDFLARE_API_TOKEN=..."
echo "   ./scripts/verify-cloudflare.sh"
