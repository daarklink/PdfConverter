#!/bin/bash
# Script de désinstallation de l'extension Nautilus PdfConverter

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Répertoires
INSTALL_DIR="$HOME/PdfConverter"
EXTENSIONS_DIR="$HOME/.local/share/nautilus-python/extensions"

# Fonction pour afficher les étapes
print_step() {
    echo -e "${BLUE}[ÉTAPE]${NC} $1"
}

# Fonction pour afficher les succès
print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Fonction pour afficher les erreurs
print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Fonction pour afficher les avertissements
print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Fonction pour demander confirmation
confirm() {
    read -p "$(echo -e ${YELLOW}[?]${NC} $1 [o/N]: )" response
    case "$response" in
        [oO][uU][iI]|[oO])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

echo "================================================"
echo "  Désinstallation de PdfConverter pour Nautilus"
echo "================================================"
echo ""

print_warning "Cette opération va supprimer :"
echo "  - L'extension Nautilus : $EXTENSIONS_DIR/pdf_to_docx.py"
echo "  - Le répertoire d'installation : $INSTALL_DIR"
echo ""

if ! confirm "Voulez-vous vraiment désinstaller PdfConverter ?"; then
    echo "Désinstallation annulée."
    exit 0
fi

echo ""

# Supprimer l'extension Nautilus
print_step "Suppression de l'extension Nautilus..."

if [ -f "$EXTENSIONS_DIR/pdf_to_docx.py" ]; then
    rm -f "$EXTENSIONS_DIR/pdf_to_docx.py"
    print_success "Extension supprimée"
else
    print_warning "Extension non trouvée (déjà supprimée ?)"
fi
echo ""

# Supprimer le répertoire d'installation
print_step "Suppression du répertoire d'installation..."

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    print_success "Répertoire supprimé : $INSTALL_DIR"
else
    print_warning "Répertoire non trouvé (déjà supprimé ?)"
fi
echo ""

# Demander confirmation avant de redémarrer Nautilus
print_warning "Pour désactiver l'extension, Nautilus doit être redémarré."
echo "  Cela fermera toutes les fenêtres Nautilus ouvertes."
echo ""

if confirm "Voulez-vous redémarrer Nautilus maintenant ?"; then
    print_step "Redémarrage de Nautilus..."
    nautilus -q
    sleep 1
    print_success "Nautilus redémarré"
    echo ""
fi

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   Désinstallation terminée avec succès !${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "PdfConverter a été complètement désinstallé de votre système."
echo ""
echo "Note : Le module Python pdf2docx n'a pas été désinstallé."
echo "Pour le supprimer manuellement :"
echo "  pip uninstall pdf2docx"
echo ""