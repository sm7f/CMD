import os
import csv
import pyodbc

# Informações de conexão com o banco de dados
server = 'localhost'  # Exemplo: 'localhost' ou o endereço IP do servidor
database = 'PoliSystemServerSQLDB'  # Nome do banco de dados
username = 'sa'  # Usuário do banco de dados
password = 'PoliSystemsapwd'  # Senha do banco de dados

# Caminho do arquivo CSV onde os dados serão salvos
caminho_csv = r'C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Scripts\sql-inject\resultado.csv'  # Caminho alterado

# Verificar se o diretório existe; caso contrário, criar
diretorio = os.path.dirname(caminho_csv)
if not os.path.exists(diretorio):
    os.makedirs(diretorio)

# Criar a string de conexão
conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}'

try:
    # Conectar ao banco de dados
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    # Executar uma consulta SQL
    query = "SELECT * FROM Venda"  # Altere para sua consulta SQL
    cursor.execute(query)

    # Recuperar os resultados
    rows = cursor.fetchall()

    # Escrever os dados no arquivo CSV
    with open(caminho_csv, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)

        # Escrever cabeçalho (nomes das colunas)
        colunas = [column[0] for column in cursor.description]
        writer.writerow(colunas)

        # Escrever os dados
        for row in rows:
            writer.writerow(row)

    print(f"Arquivo CSV gerado com sucesso em: {caminho_csv}")

except Exception as e:
    print(f"Ocorreu um erro: {e}")
finally:
    # Fechar a conexão
    if conn:
        conn.close()
