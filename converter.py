import sys
from pdf2docx import Converter
import  os

def pdf_to_word(pdf_path, start=0, end=None) :
    if not os.path.exists(pdf_path) :
        raise FileNotFoundError(f"Fichier introuvable : {pdf_path}")
    docx_path = os.path.splitext(pdf_path)[0] + ".docx"

    converter = Converter(pdf_path)
    try :
        converter.convert(docx_path, start=start, end=end)
        print(f"Converti : {docx_path}")

    except Exception as e :
        print(f"Erreur de conversion : {e}")

    finally:
        converter.close()

def main() :
    if len(sys.argv) > 2 :
        raise ValueError(f"Trop d'arguments fournis ({len(sys.argv)} au lieu de 2)")
    if len(sys.argv) < 2 :
        raise ValueError(f"Pas assez d'arguments fournis ({len(sys.argv)} au lieu de 2)")

    pdf_to_word(sys.argv[1])

if __name__ == '__main__':
    try:
        main()
    except ValueError as e:
        print(f"Erreur: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Erreur inattendue: {e}", file=sys.stderr)
        sys.exit(1)