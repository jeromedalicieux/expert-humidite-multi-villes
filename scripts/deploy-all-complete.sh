#!/bin/bash
# Script complet de déploiement automatisé
# Crée les 44 sites Netlify, build et déploie tout
# Usage: ./scripts/deploy-all-complete.sh

set -e

echo "🎯 Déploiement COMPLET des 44 sites Expert Humidité"
echo "===================================================="
echo ""
echo "Ce script va :"
echo "  1. Créer les 44 sites sur Netlify"
echo "  2. Builder les 44 versions (une par ville)"
echo "  3. Déployer chaque build sur son site Netlify"
echo ""
echo "⏱️  Durée estimée : 30-60 minutes"
echo ""

read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Annulé"
    exit 1
fi

echo ""
echo "======================================"
echo "ÉTAPE 1/3 : Création des sites Netlify"
echo "======================================"
echo ""

./scripts/deploy-all-cities-netlify.sh

echo ""
echo "======================================"
echo "ÉTAPE 2/3 : Build des 44 sites"
echo "======================================"
echo ""

./scripts/build-all-cities.sh

echo ""
echo "======================================"
echo "ÉTAPE 3/3 : Déploiement sur Netlify"
echo "======================================"
echo ""

./scripts/deploy-builds-to-netlify.sh

echo ""
echo "===================================================="
echo "✅ DÉPLOIEMENT COMPLET TERMINÉ !"
echo "===================================================="
echo ""
echo "🌐 Les 44 sites sont maintenant en ligne sur Netlify"
echo ""
echo "🔧 Prochaines étapes recommandées :"
echo "   1. Configurer les DNS Cloudflare :"
echo "      export CLOUDFLARE_API_TOKEN='votre-token'"
echo "      ./scripts/setup-cloudflare-dns-all.sh"
echo ""
echo "   2. Vérifier les sites :"
echo "      netlify sites:list"
echo ""
echo "   3. Tester quelques URLs :"
echo "      curl -I https://expert-humidite-paris.netlify.app"
echo "      curl -I https://expert-humidite-lyon.netlify.app"
echo ""
echo "💰 Coût Netlify : 0€ (tous les sites sur le plan gratuit)"
echo ""
