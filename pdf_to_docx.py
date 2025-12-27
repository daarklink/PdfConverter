#!/usr/bin/env python3
"""
Extension Nautilus pour convertir PDF en DOCX
Affiche l'option "Convertir en DOCX" UNIQUEMENT sur les fichiers PDF
"""

import os
import subprocess
import urllib.parse
from pathlib import Path
from gi.repository import Nautilus, GObject, GLib


class PdfToDocxExtension(GObject.GObject, Nautilus.MenuProvider):
    """Extension Nautilus pour conversion PDF → DOCX"""
    
    def __init__(self):
        super().__init__()
        
        self.converter_script = os.path.expanduser('~/Documents/Perso/Programmation/PdfConverter/converter.py')
    
    def get_file_items(self, *args):
        """
        Appelé par Nautilus pour chaque fichier sélectionné.
        Retourne les options du menu contextuel.
        """
        # Compatibilité avec différentes versions de nautilus-python
        if len(args) == 1:
            files = args[0]
        else:
            files = args[1]
        
        # Vérifier qu'un seul fichier est sélectionné
        if len(files) != 1:
            return []
        
        file_info = files[0]
        
        # Ignorer les répertoires
        if file_info.is_directory():
            return []
        
        # Récupérer le chemin du fichier
        uri = file_info.get_uri()
        file_path = Path(urllib.parse.unquote(uri.replace('file://', '')))
        
        # ⚠️ VÉRIFICATION CRITIQUE : N'afficher l'option QUE pour les PDF
        if file_path.suffix.lower() != '.pdf':
            return []
        
        # Créer l'entrée du menu contextuel
        item = Nautilus.MenuItem(
            name='PdfToDocx::convert',
            label='Convertir en DOCX',
            tip=f'Convertir {file_path.name} en format Word (DOCX)',
            icon='document-properties'
        )
        
        # Connecter l'action au clic
        item.connect('activate', self._on_convert_clicked, file_path)
        
        return [item]
    
    def _on_convert_clicked(self, menu, file_path):
        """Appelé quand l'utilisateur clique sur 'Convertir en DOCX'"""
        # Lancer la conversion en arrière-plan
        GLib.idle_add(self._run_conversion, file_path)
    
    def _run_conversion(self, file_path):
        """Exécute le script de conversion"""
        try:
            # Notification de début
            self._show_notification(
                "Conversion en cours...",
                f"Traitement de {file_path.name}",
                icon="document-properties"
            )
            
            # Exécuter le script converter.py avec le fichier en argument
            result = subprocess.run(
                ['python3', self.converter_script, str(file_path)],
                capture_output=True,
                text=True,
                timeout=120  # 2 minutes max
            )
            
            # Vérifier le résultat
            if result.returncode == 0:
                # Succès
                output_name = file_path.stem + '.docx'
                self._show_notification(
                    "✓ Conversion réussie",
                    f"{output_name} a été créé",
                    icon="emblem-default"
                )
            else:
                # Erreur
                error_msg = result.stderr.strip() if result.stderr else "Erreur inconnue"
                self._show_notification(
                    "✗ Échec de la conversion",
                    error_msg,
                    icon="dialog-error"
                )
        
        except subprocess.TimeoutExpired:
            self._show_notification(
                "✗ Délai dépassé",
                "La conversion a pris trop de temps (>2 min)",
                icon="dialog-error"
            )
        
        except FileNotFoundError:
            self._show_notification(
                "✗ Script introuvable",
                f"Le script {self.converter_script} n'existe pas",
                icon="dialog-error"
            )
        
        except Exception as e:
            self._show_notification(
                "✗ Erreur inattendue",
                str(e),
                icon="dialog-error"
            )
        
        return False  # Ne pas répéter l'opération
    
    def _show_notification(self, title, message, icon="document-properties"):
        """Affiche une notification système"""
        try:
            subprocess.run([
                'notify-send',
                '-i', icon,
                '-a', 'Convertisseur PDF',
                title,
                message
            ], timeout=2)
        except:
            # Si notify-send échoue, on continue silencieusement
            pass
