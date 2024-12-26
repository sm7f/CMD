import json

# Lista de NCMs fornecidos
ncms_fornecidos = [
    "82013000", "82011000", "39204900", "87168000", "87168001", "82023100", 
    "39172300", "39174090", "81502900", "35061090", "39174090", "39209990", 
    "84818095", "84818095", "52889000", "39172300", "73170090", "90178090", 
    "82075019", "82052000", "84869000", "39229000", "39174010", "84818099", 
    "72171090", "72171090", "64039990", "40151900", "40151900", "39174090", 
    "39174090", "44170090", "86960000", "83021000", "83014000", "83011000", 
    "39174090", "82055900", "61169200", "73158200", "83011000", "83021000", 
    "39174090", "82075011", "39172300", "39174090", "83011000", "73158200", 
    "68042211", "73170090", "61169200"
]

# Função para carregar a tabela oficial de NCM de um arquivo JSON
def carregar_tabela_ncm(caminho_arquivo):
    tabela_oficial = set()
    with open(caminho_arquivo, mode='r', encoding='utf-8') as arquivo:
        dados_json = json.load(arquivo)
        for item in dados_json:  # Ajuste conforme a estrutura do seu arquivo JSON
            # Supondo que o código NCM esteja em um campo específico, como 'codigo'
            tabela_oficial.add(item['codigo'])  # Altere 'codigo' para o nome correto da chave
    return tabela_oficial

# Caminho do arquivo JSON da tabela oficial
caminho_tabela = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Script-main\Script-main\CMD\ncm.json"  # Substitua pelo nome correto do arquivo

# Carregar tabela oficial
try:
    tabela_ncm_oficial = carregar_tabela_ncm(caminho_tabela)

    # Verificar os NCMs fornecidos
    ncms_invalidos = [ncm for ncm in ncms_fornecidos if ncm not in tabela_ncm_oficial]

    if ncms_invalidos:
        print("Os seguintes NCMs são inválidos ou não estão na tabela oficial:")
        print(ncms_invalidos)
    else:
        print("Todos os NCMs fornecidos são válidos.")
except FileNotFoundError:
    print(f"Arquivo da tabela NCM oficial não encontrado: {caminho_tabela}")
except json.JSONDecodeError:
    print(f"Erro ao ler o arquivo JSON: {caminho_tabela}")
52241233473488000123550010000116011213360309