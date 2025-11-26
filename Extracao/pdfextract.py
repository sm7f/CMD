import pdfplumber
import os

# Caminho fixo do PDF
CAMINHO_PDF = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Extracao\REFORMA2026.pdf"

def extrair_texto_linha_a_linha(caminho_pdf):
    if not os.path.exists(caminho_pdf):
        print(f"❌ Arquivo não encontrado: {caminho_pdf}")
        return None

    nome_pdf = os.path.basename(caminho_pdf)
    nome_saida = os.path.splitext(nome_pdf)[0] + "_extraido.txt"
    caminho_saida = os.path.join(os.path.dirname(caminho_pdf), nome_saida)

    print(f"📂 Lendo PDF: {caminho_pdf}")
    print("⏳ Extraindo texto página por página...\n")

    with pdfplumber.open(caminho_pdf) as pdf, open(caminho_saida, "w", encoding="utf-8") as saida:
        for i, pagina in enumerate(pdf.pages, start=1):
            texto = pagina.extract_text()
            if texto:
                saida.write(f"=== PÁGINA {i} ===\n")
                for linha in texto.split("\n"):
                    saida.write(linha.strip() + "\n")
                saida.write("\n")
                print(f"✅ Página {i} extraída ({len(texto.splitlines())} linhas)")
            else:
                saida.write(f"=== PÁGINA {i} ===\n[Sem texto legível]\n\n")
                print(f"⚠️ Página {i} sem texto extraível (provável imagem).")

    print("\n🎯 Extração concluída!")
    print(f"📁 Arquivo salvo em: {caminho_saida}")
    return caminho_saida


if __name__ == "__main__":
    extrair_texto_linha_a_linha(CAMINHO_PDF)
