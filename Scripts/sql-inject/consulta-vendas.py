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
caminho_excel = r'C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Scripts\sql-inject\resultado-vendas.xlsx'  # Caminho alterado

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

    # Executar uma consulta SQL
    query = """
    SELECT cdvenda, DataHoraVenda, valortotalvenda
    FROM VENDA
    WHERE YEAR(DataHoraVenda) = YEAR(GETDATE()) 
    AND MONTH(DataHoraVenda) = MONTH(GETDATE())
    """  # Altere para sua consulta SQL
    cursor.execute(query)

    # Recuperar os resultados
    rows = cursor.fetchall()

    # Criar uma nova planilha Excel
    workbook = Workbook()
    sheet = workbook.active
    sheet.title = "Resultados"

    # Adicionar cabeçalho (nomes das colunas)
    colunas = [column[0] for column in cursor.description]
    sheet.append(colunas)

    # Criar e adicionar o estilo de data e hora ao workbook
    date_time_style = NamedStyle(name="datetime_style", number_format="YYYY-MM-DD HH:MM:SS")
    workbook.add_named_style(date_time_style)

    # Adicionar os dados das linhas
    for row_idx, row in enumerate(rows, start=2):  # Começar a partir da linha 2 (porque a 1 é o cabeçalho)
        sheet.append(list(row))  # Convertendo o pyodbc.Row para uma lista

        # Verificar se a coluna DataHoraVenda existe e formatar
        if 'DataHoraVenda' in colunas:
            datahora_idx = colunas.index('DataHoraVenda') + 1  # Obter o índice da coluna DataHoraVenda
            for i, cell in enumerate(sheet[row_idx]):
                if i == datahora_idx - 1:  # Se a célula for da coluna DataHoraVenda
                    cell.style = date_time_style

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
