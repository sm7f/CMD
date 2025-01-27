import os
import pyodbc
from openpyxl import Workbook
from openpyxl.styles import NamedStyle

# Informações de conexão com o banco de dados
server = 'localhost'  # Exemplo: 'localhost' ou o endereço IP do servidor
database = 'PoliSystemServerSQLDB'  # Nome do banco de dados
username = 'sa'  # Usuário do banco de dados
password = 'PoliSystemsapwd'  # Senha do banco de dados

# Caminho do arquivo Excel onde os dados serão salvos
caminho_excel = r'C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Scripts\sql-inject\resultado-serviços.xlsx'  # Caminho alterado

# Verificar se o diretório existe; caso contrário, criar
diretorio = os.path.dirname(caminho_excel)
if not os.path.exists(diretorio):
    os.makedirs(diretorio)

# Criar a string de conexão
conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}'

try:
    # Conectar ao banco de dados
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    # Comando SQL de consulta
    query = """
    SELECT [CdProduto], DescricaoProduto, StatusTipoProduto, IndIncentivoFiscalISSQN, IndExibilidadeISSQN
    FROM PRODUTO
    WHERE CodigoNCMProduto = '00000000'
    """
    cursor.execute(query)

    # Recuperar os resultados
    rows = cursor.fetchall()

    # Criar uma nova planilha Excel
    workbook = Workbook()
    sheet = workbook.active
    sheet.title = "Resultado-serviços"

    # Adicionar cabeçalho (nomes das colunas)
    colunas = [column[0] for column in cursor.description]
    sheet.append(colunas)

    # Adicionar os dados das linhas
    for row_idx, row in enumerate(rows, start=2):  # Começar a partir da linha 2 (porque a 1 é o cabeçalho)
        sheet.append(list(row))  # Convertendo o pyodbc.Row para uma lista

    # Ajustar a largura das colunas para o conteúdo
    for col in sheet.columns:
        max_length = 0
        column = col[0].column_letter  # Obter o nome da coluna
        for cell in col:
            try:
                if len(str(cell.value)) > max_length:
                    max_length = len(str(cell.value))
            except:
                pass
        adjusted_width = (max_length + 2)
        sheet.column_dimensions[column].width = adjusted_width

    # Salvar o arquivo Excel
    workbook.save(caminho_excel)
    print(f"Arquivo Excel gerado com sucesso em: {caminho_excel}")

except Exception as e:
    print(f"Ocorreu um erro: {e}")
finally:
    # Fechar a conexão
    if conn:
        conn.close()
