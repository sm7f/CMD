import pyodbc
import pandas as pd

# Defina a string de conexão para o SQL Server
conn_str = (
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=.;'
    'DATABASE=PoliSystemServerSQLDB;'
    'UID=sa;'
    'PWD=PoliSystemsapwd'
)

# Conecte ao banco de dados
conn = pyodbc.connect(conn_str)

# Defina a consulta SQL
query = """
SELECT ID, NRNFE, VALORTOTALNFE, DATAEMISSAONFE, NATUREZAOPNFE, MODELO
FROM NFE
WHERE NRNFE BETWEEN 318002 AND 318007;
"""

# Execute a consulta e carregue os resultados em um DataFrame do pandas
df = pd.read_sql(query, conn)

# Feche a conexão com o banco de dados
conn.close()

# Salve o DataFrame em um arquivo Excel
output_file = r'C:\Users\Maqplan\Downloads\relatorio_nfe.xlsx'
df.to_excel(output_file, index=False)

print(f"Relatório gerado com sucesso e salvo como {output_file}")

