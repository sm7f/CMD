import xml.etree.ElementTree as ET
from openpyxl import Workbook

# Caminho do arquivo XML
caminho_arquivo = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Scripts\Exercicios\produtos.xml"

# Caminho para salvar o arquivo Excel
caminho_excel = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Scripts\Exercicios\nomes_produtos.xlsx"

try:
    # Carregar e parsear o arquivo XML
    tree = ET.parse(caminho_arquivo)
    root = tree.getroot()

    # Definir o namespace (no seu caso, o namespace é 'http://www.portalfiscal.inf.br/nfe')
    namespace = {'nfe': 'http://www.portalfiscal.inf.br/nfe'}

    # Lista para armazenar os dados dos produtos (código e nome)
    produtos = []

    # Buscar as tags <xProd> e <cProd> dentro de <prod>, considerando o namespace
    for det in root.findall(".//nfe:det", namespace):
        prod = det.find(".//nfe:prod", namespace)
        if prod is not None:
            cprod = prod.find(".//nfe:cProd", namespace)
            xprod = prod.find(".//nfe:xProd", namespace)
            if cprod is not None and xprod is not None:
                produtos.append([cprod.text, xprod.text])

    # Verificar se algum produto foi encontrado
    if produtos:
        # Criar uma nova planilha Excel
        workbook = Workbook()
        sheet = workbook.active
        sheet.title = "Produtos"

        # Adicionar o cabeçalho
        sheet.append(["Código do Produto", "Nome do Produto"])  # Títulos das colunas

        # Adicionar os dados dos produtos ao Excel
        for produto in produtos:
            sheet.append(produto)

        # Salvar o arquivo Excel
        workbook.save(caminho_excel)
        print(f"Arquivo Excel gerado com sucesso em: {caminho_excel}")
    else:
        print("Nenhum produto encontrado no XML.")

except FileNotFoundError:
    print("Arquivo XML não encontrado. Verifique o caminho.")
except ET.ParseError:
    print("Erro ao parsear o arquivo XML. Verifique a estrutura do XML.")
except Exception as e:
    print(f"Ocorreu um erro: {e}")
