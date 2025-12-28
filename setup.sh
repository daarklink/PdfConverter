#!/bin/bash
# Script d'installation de l'extension Nautilus PdfConverter
# Installe l'extension pour convertir PDF en DOCX via clic droit

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
echo "   Installation de PdfConverter pour Nautilus"
echo "================================================"
echo ""

# Vérifier que les fichiers nécessaires existent
print_step "Vérification des fichiers requis..."

REQUIRED_FILES=("pdf_to_docx.py" "converter.py" "uninstall.sh")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -ne 0 ]; then
    print_error "Fichiers manquants : ${MISSING_FILES[*]}"
    exit 1
fi

print_success "Tous les fichiers requis sont présents"
echo ""

# Détecter le système d'exploitation
print_step "Détection du système d'exploitation..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="$ID"
    print_success "Système détecté : $NAME"
else
    print_error "Impossible de détecter le système d'exploitation"
    exit 1
fi
echo ""

# Vérifier que nautilus-python est installé
print_step "Vérification de nautilus-python..."

SKIP_NAUTILUS_CHECK=false

case "$OS_ID" in
    fedora|rhel|centos)
        PACKAGE_NAME="nautilus-python"
        PACKAGE_MANAGER="dnf"
        CHECK_CMD="rpm -qa | grep -q nautilus-python"
        INSTALL_CMD="sudo dnf install -y nautilus-python"
        ;;
    ubuntu|debian)
        PACKAGE_NAME="python3-nautilus"
        PACKAGE_MANAGER="apt"
        CHECK_CMD="dpkg -l | grep -q python3-nautilus"
        INSTALL_CMD="sudo apt install -y python3-nautilus"
        ;;
    *)
        print_warning "Système d'exploitation non reconnu : $OS_ID"
        print_warning "Systèmes supportés : Fedora, RHEL, CentOS, Ubuntu, Debian"
        echo ""
        echo "Vous devrez installer manuellement le paquet nautilus-python"
        echo "(ou équivalent pour votre distribution)"
        echo ""
        if confirm "Voulez-vous continuer l'installation sans vérification ?"; then
            SKIP_NAUTILUS_CHECK=true
            print_warning "Vérification de nautilus-python ignorée"
        else
            print_error "Installation annulée"
            exit 1
        fi
        ;;
esac

if [ "$SKIP_NAUTILUS_CHECK" = false ]; then
    if ! eval "$CHECK_CMD" 2>/dev/null; then
        print_warning "$PACKAGE_NAME n'est pas installé"
        if confirm "Voulez-vous l'installer maintenant ?"; then
            eval "$INSTALL_CMD"
            print_success "$PACKAGE_NAME installé"
        else
            print_error "Installation annulée. $PACKAGE_NAME est requis."
            exit 1
        fi
    else
        print_success "$PACKAGE_NAME est déjà installé"
    fi
fi
echo ""

# Vérifier que pdf2docx est installé
print_step "Vérification de pdf2docx..."

if ! python3 -c "import pdf2docx" 2>/dev/null; then
    print_warning "Le module Python pdf2docx n'est pas installé"
    if confirm "Voulez-vous l'installer maintenant ?"; then
        pip install --user pdf2docx
        print_success "pdf2docx installé"
    else
        print_error "Installation annulée. pdf2docx est requis."
        exit 1
    fi
else
    print_success "pdf2docx est déjà installé"
fi
echo ""

# Créer le répertoire d'installation
print_step "Création du répertoire d'installation..."

if [ -d "$INSTALL_DIR" ]; then
    print_warning "Le répertoire $INSTALL_DIR existe déjà"
    if confirm "Voulez-vous le supprimer et réinstaller ?"; then
        rm -rf "$INSTALL_DIR"
        print_success "Ancien répertoire supprimé"
    else
        print_error "Installation annulée"
        exit 1
    fi
fi

mkdir -p "$INSTALL_DIR"
print_success "Répertoire créé : $INSTALL_DIR"
echo ""

# Copier les fichiers dans le répertoire d'installation
print_step "Copie des fichiers de l'application..."

cp converter.py "$INSTALL_DIR/"
cp setup.sh "$INSTALL_DIR/"
cp uninstall.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/converter.py"
chmod +x "$INSTALL_DIR/setup.sh"
chmod +x "$INSTALL_DIR/uninstall.sh"

print_success "Fichiers copiés :"
echo "  - converter.py"
echo "  - setup.sh"
echo "  - uninstall.sh"
echo ""

# Créer le répertoire des extensions Nautilus
print_step "Création du répertoire des extensions Nautilus..."

mkdir -p "$EXTENSIONS_DIR"
print_success "Répertoire créé : $EXTENSIONS_DIR"
echo ""

# Modifier le chemin de converter.py dans pdf_to_docx.py avant de le copier
print_step "Configuration de l'extension..."

# Créer une version modifiée de pdf_to_docx.py avec le bon chemin
sed "s|self.converter_script = os.path.expanduser('.*')|self.converter_script = '$INSTALL_DIR/converter.py'|" \
    pdf_to_docx.py > "$EXTENSIONS_DIR/pdf_to_docx.py"

print_success "Extension configurée avec le chemin : $INSTALL_DIR/converter.py"
echo ""

# Rendre le fichier exécutable
print_step "Configuration des permissions..."

chmod +x "$EXTENSIONS_DIR/pdf_to_docx.py"
print_success "Permissions configurées (exécutable)"
echo ""

# Vérifier la configuration
print_step "Vérification de l'installation..."

if [ -f "$INSTALL_DIR/converter.py" ] && [ -f "$EXTENSIONS_DIR/pdf_to_docx.py" ]; then
    print_success "Installation vérifiée avec succès"
else
    print_error "Problème lors de l'installation"
    exit 1
fi
echo ""

# Résumé de l'installation
echo "================================================"
echo "   Résumé de l'installation"
echo "================================================"
echo "✓ Application installée : $INSTALL_DIR"
echo "  - converter.py"
echo "  - setup.sh"
echo "  - uninstall.sh"
echo ""
echo "✓ Extension Nautilus : $EXTENSIONS_DIR/pdf_to_docx.py"
echo "✓ Permissions configurées"
echo "✓ Dépendances vérifiées"
echo ""
print_success "Vous pouvez maintenant supprimer le dossier d'installation d'origine"
echo ""

# Demander confirmation avant de redémarrer Nautilus
print_warning "Pour activer l'extension, Nautilus doit être redémarré."
echo "  Cela fermera toutes les fenêtres Nautilus ouvertes."
echo ""

if confirm "Voulez-vous redémarrer Nautilus maintenant ?"; then
    print_step "Redémarrage de Nautilus..."
    nautilus -q
    sleep 1
    print_success "Nautilus redémarré"
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}   Installation terminée avec succès !${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "Pour tester l'extension :"
    echo "  1. Ouvrez Nautilus"
    echo "  2. Faites un clic droit sur un fichier PDF"
    echo "  3. Sélectionnez 'Convertir en DOCX'"
    echo ""
else
    print_warning "Nautilus n'a pas été redémarré"
    echo ""
    echo "Pour activer l'extension manuellement :"
    echo "  Exécutez : nautilus -q"
    echo ""
fi

echo "Fichiers installés dans : $INSTALL_DIR"
echo ""
echo "Pour désinstaller :"
echo "  cd $INSTALL_DIR"
echo "  ./uninstall.sh"
echo ""