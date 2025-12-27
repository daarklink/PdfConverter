# PdfConverter
PdfConverter est une application simple en Python qui permet de convertir facilement un fichier pdf en docx.

Elle peut être utilisée directement en ligne de commande ou être installée sous forme d'extension pour Nautilus.

> [!WARNING] _l'extension n'a été testé que pour Fedora_ 

# Prérequis
Pour lancer correctement le script il faudra les dépendances suivantes : 

* librairie Python pdf2docx
* le paquet nautilus-python

```
pip install pdf2docx
```

### Fedora
```
sudo dnf install nautilus-python
```

### Ubuntu 
```
sudo apt install nautilus-python ou python3-nautilus
```
_La version Ubuntu peut ne pas fonctionner_

## Utilisation CLI
Le script peut être lancé en ligne de commande comme ceci :
```
python converter.py nom_du_fichier.pdf
```


## Lancer l'installation
Rendre le script exécutable :
```
chmod +x setup.sh
```

Lancer le script d'installation :
```
bash setup.sh
```
ou 
```
./setup.sh
```

A la fin de l'installation, le script va demander pour redémarrer Nautilus, penser à sauvegarder les modifications en cours avant d’accepter.

## Utilisation (extension)
Pour convertir un fichier PDF il suffit de faire clic droit sur un fichier puis ```Convertir en DOCX```.

## Désinstallation
Pour désinstaller l'extension il suffit d'exécuter le script de désinstallation présent dans le répertoire _PdfConverter_ :
```
cd ~/PdfConverter
bash uninstall.sh
```

#
_Note : Merci à @iamhierat sur Tiktok pour l'inspiration du code de conversion !_