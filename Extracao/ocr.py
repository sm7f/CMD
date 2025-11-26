import pytesseract
from pdf2image import convert_from_path
import os

# 🔧 Definir caminho do Poppler manualmente
POPPLER_PATH = r"C:\Program Files\poppler-25.07.0\Library\bin"

# Caminho do PDF
PDF_PATH = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Extracao\REFORMA2026.pdf"
OUTPUT_TXT = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Extracao\REFORMA2026_EXTRAIDO.txt"

# Caminho do executável do Tesseract
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

# Converter cada página do PDF em imagem
print("📄 Convertendo PDF em imagens...")
pages = convert_from_path(PDF_PATH, dpi=150, poppler_path=POPPLER_PATH)

total = len(pages)
print(f"✅ {total} páginas detectadas.")

all_text = ""
for i, page in enumerate(pages, start=1):
    print(f"🧾 Processando página {i}/{len(pages)}...")
    text = pytesseract.image_to_string(page, lang="por")
    all_text += f"\n\n--- Página {i} ---\n{text}"

with open(OUTPUT_TXT, "w", encoding="utf-8") as f:
    f.write(all_text)

print(f"\n✅ Extração concluída! Texto salvo em: {OUTPUT_TXT}")
