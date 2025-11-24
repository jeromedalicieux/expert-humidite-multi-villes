#!/bin/bash

# Script de vérification de tous les domaines
# Vérifie que DNS pointe vers Netlify et que le site répond
# Usage: ./verify-domains.sh

echo "🔍 Vérification des domaines Expert Humidité"
echo "============================================="
echo ""

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

NETLIFY_IP="75.2.60.5"
DNS_OK=0
DNS_PENDING=0
HTTPS_OK=0
HTTPS_FAILED=0

echo "🔍 Vérification DNS (enregistrement A → $NETLIFY_IP)"
echo ""

for domain in "${DOMAINS[@]}"; do
  echo -n "📍 $domain: "

  # Vérifier l'enregistrement A
  IP=$(dig +short "$domain" | head -n1)

  if [ "$IP" = "$NETLIFY_IP" ]; then
    echo -n "✅ DNS OK"
    ((DNS_OK++))

    # Tester HTTPS
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$domain" --max-time 5 || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
      echo " | 🔒 HTTPS OK"
      ((HTTPS_OK++))

      # Extraire le titre de la page pour vérifier la ville
      TITLE=$(curl -s "https://$domain" | grep -o '<title>.*</title>' | head -1 | sed 's/<[^>]*>//g')
      if [ -n "$TITLE" ]; then
        echo "   Titre: $TITLE"
      fi
    else
      echo " | ⚠️  HTTPS erreur (code $HTTP_CODE)"
      ((HTTPS_FAILED++))
    fi
  elif [ -z "$IP" ]; then
    echo "❌ Pas de DNS configuré"
    ((DNS_PENDING++))
  else
    echo "⚠️  DNS pointe vers $IP (devrait être $NETLIFY_IP)"
    ((DNS_PENDING++))
  fi
done

echo ""
echo "============================================="
echo "📊 Résumé:"
echo ""
echo "DNS:"
echo "   ✅ Configurés correctement: $DNS_OK / ${#DOMAINS[@]}"
echo "   ⏳ En attente: $DNS_PENDING / ${#DOMAINS[@]}"
echo ""
echo "HTTPS:"
echo "   🔒 Actifs: $HTTPS_OK / ${#DOMAINS[@]}"
echo "   ⚠️  Non actifs: $HTTPS_FAILED / ${#DOMAINS[@]}"
echo ""

if [ $DNS_OK -eq ${#DOMAINS[@]} ] && [ $HTTPS_OK -eq ${#DOMAINS[@]} ]; then
  echo "🎉 Tous les domaines sont opérationnels!"
elif [ $DNS_OK -eq 0 ]; then
  echo "⏳ Les DNS ne sont pas encore configurés."
  echo "   Suivre les instructions dans DNS-CONFIGURATION.md"
elif [ $DNS_PENDING -gt 0 ]; then
  echo "⏳ Certains DNS sont en cours de propagation."
  echo "   Attendre 24-48h et relancer ce script."
elif [ $HTTPS_FAILED -gt 0 ]; then
  echo "⚠️  DNS OK mais HTTPS non actif sur certains domaines."
  echo "   Attendre 1-2h que Netlify génère les certificats SSL."
  echo "   Ou vérifier dans Netlify → Domain management → HTTPS"
fi

echo ""
echo "💡 Commandes utiles:"
echo "   dig expert-humidite-paris.fr +short    # Vérifier DNS d'un domaine"
echo "   curl -I https://expert-humidite-paris.fr  # Tester HTTPS d'un domaine"
