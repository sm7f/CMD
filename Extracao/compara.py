import os
import xml.etree.ElementTree as ET
from collections import Counter

# === CONFIGURAÇÕES ===
dir1 = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Extracao\1"  # 274 arquivos
dir2 = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Extracao\2"  # 275 arquivos

# === FUNÇÃO PARA EXTRAIR NÚMERO DO XML (GENÉRICA) ===
def extrair_numero_rps(caminho_xml):
    try:
        tree = ET.parse(caminho_xml)
        root = tree.getroot()

        # Busca qualquer tag com "Numero" no final do nome (suporta namespaces)
        for elem in root.iter():
            tag = elem.tag.split('}')[-1]  # remove prefixos tipo {ns}
            if tag.lower() == "numero" and elem.text:
                valor = elem.text.strip()
                if valor.isdigit():
                    return valor
    except Exception as e:
        print(f"⚠️ Erro ao ler {os.path.basename(caminho_xml)}: {e}")
    return None

# === COLETAR NÚMEROS DE CADA DIRETÓRIO ===
def coletar_numeros(diretorio):
    numeros = []
    total_xml = 0
    for arquivo in os.listdir(diretorio):
        if arquivo.lower().endswith(".xml"):
            total_xml += 1
            caminho = os.path.join(diretorio, arquivo)
            numero = extrair_numero_rps(caminho)
            if numero:
                numeros.append(numero)
            else:
                print(f"⚠️ Nenhum número encontrado em: {arquivo}")
    print(f"📂 {diretorio}: {total_xml} arquivos, {len(numeros)} números extraídos.")
    return numeros

# === EXECUÇÃO ===
numeros_dir1 = coletar_numeros(dir1)
numeros_dir2 = coletar_numeros(dir2)

# === ANÁLISE DE DUPLICATAS ===
dup1 = [n for n, c in Counter(numeros_dir1).items() if c > 1]
dup2 = [n for n, c in Counter(numeros_dir2).items() if c > 1]

if dup1:
    print(f"\n⚠️ Duplicados no diretório 1 ({len(dup1)}): {dup1}")
if dup2:
    print(f"⚠️ Duplicados no diretório 2 ({len(dup2)}): {dup2}")

# === COMPARAÇÃO ===
set1 = set(numeros_dir1)
set2 = set(numeros_dir2)

faltando_em_dir1 = sorted(set2 - set1)
faltando_em_dir2 = sorted(set1 - set2)

# === RELATÓRIO ===
print("\n=== RESULTADO COMPARATIVO ===")
print(f"📊 Total extraído do diretório 1: {len(set1)} únicos ({len(numeros_dir1)} totais)")
print(f"📊 Total extraído do diretório 2: {len(set2)} únicos ({len(numeros_dir2)} totais)")

if faltando_em_dir1:
    print("\n🔴 Faltando no DIRETÓRIO 1:")
    for n in faltando_em_dir1:
        print(f" - RPS {n}")
else:
    print("\n✅ Nenhum número faltando no diretório 1.")

if faltando_em_dir2:
    print("\n🔴 Faltando no DIRETÓRIO 2:")
    for n in faltando_em_dir2:
        print(f" - RPS {n}")
else:
    print("\n✅ Nenhum número faltando no diretório 2.")

# === EXPORTA RESULTADO ===
with open("resultado_comparativo.txt", "w", encoding="utf-8") as f:
    f.write("=== RELATÓRIO DE COMPARAÇÃO DE XML ===\n\n")
    f.write(f"Diretório 1: {dir1}\n")
    f.write(f"Diretório 2: {dir2}\n\n")
    f.write(f"Total de XMLs lidos dir1: {len(numeros_dir1)}\n")
    f.write(f"Total de XMLs lidos dir2: {len(numeros_dir2)}\n\n")
    if faltando_em_dir1:
        f.write("Faltando no diretório 1:\n")
        for n in faltando_em_dir1:
            f.write(f" - RPS {n}\n")
    if faltando_em_dir2:
        f.write("\nFaltando no diretório 2:\n")
        for n in faltando_em_dir2:
            f.write(f" - RPS {n}\n")
    if not faltando_em_dir1 and not faltando_em_dir2:
        f.write("\nNenhuma diferença encontrada.\n")
    if dup1:
        f.write(f"\nDuplicados dir1: {dup1}\n")
    if dup2:
        f.write(f"\nDuplicados dir2: {dup2}\n")

print("\n📄 Resultado salvo em 'resultado_comparativo.txt'")
