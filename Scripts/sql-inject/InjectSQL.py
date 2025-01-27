import os
import pyodbc
import tkinter as tk
from tkinter import messagebox, filedialog

# Função para gerar visualização de tabela simples e organizada em formato de texto
def gerar_visualizacao_em_texto(colunas, rows):
    # Calcular a largura máxima de cada coluna
    colunas_largura = [len(col) for col in colunas]
    for row in rows:
        for i, cell in enumerate(row):
            colunas_largura[i] = max(colunas_largura[i], len(str(cell)))

    # Criar a linha de cabeçalho
    header = " | ".join([col.ljust(colunas_largura[i]) for i, col in enumerate(colunas)])
    separator = "-|-".join(["-" * largura for largura in colunas_largura])  # Linha separadora
    
    # Criar o conteúdo da tabela
    table_data = "\n".join(
        [" | ".join([str(cell).ljust(colunas_largura[i]) for i, cell in enumerate(row)]) for row in rows]
    )

    # Montar a tabela final
    tabela_completa = f"{header}\n{separator}\n{table_data}"
    return tabela_completa

# Função para realizar a consulta e exibir o resultado em formato de texto
def realizar_consulta(consulta):
    # Obter as informações da interface (o que o usuário inseriu)
    server = entry_server.get()
    database = entry_database.get()
    username = entry_username.get()
    password = entry_password.get()

    try:
        # Criar a string de conexão
        conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}'

        # Conectar ao banco de dados
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()

        # Executar a consulta SQL
        cursor.execute(consulta)

        # Recuperar os resultados
        rows = cursor.fetchall()

        # Obter os nomes das colunas
        colunas = [column[0] for column in cursor.description]

        # Gerar a visualização em texto
        tabela_completa = gerar_visualizacao_em_texto(colunas, rows)

        # Exibir a tabela no campo de texto
        text_output.delete(1.0, tk.END)  # Limpar o campo de texto
        text_output.insert(tk.END, tabela_completa)

        messagebox.showinfo("Sucesso", "Consulta realizada com sucesso!")

    except Exception as e:
        messagebox.showerror("Erro", f"Ocorreu um erro: {e}")

    finally:
        # Fechar a conexão
        if conn:
            conn.close()

# Consultas SQL
query_dia_atual = """
SELECT cdvenda, DataHoraVenda, valortotalvenda
FROM VENDA
WHERE DataHoraVenda > CAST(GETDATE() AS DATE)
"""

query_mes_atual = """
SELECT cdvenda, DataHoraVenda, valortotalvenda
FROM VENDA
WHERE YEAR(DataHoraVenda) = YEAR(GETDATE()) 
  AND MONTH(DataHoraVenda) = MONTH(GETDATE())
"""

query_mes_anterior = """
SELECT cdvenda, DataHoraVenda, valortotalvenda
FROM VENDA
WHERE YEAR(DataHoraVenda) = YEAR(DATEADD(MONTH, -1, GETDATE()))
  AND MONTH(DataHoraVenda) = MONTH(DATEADD(MONTH, -1, GETDATE()))
"""

# Criar a janela principal do Tkinter
root = tk.Tk()
root.title("Sistema de Consulta de Banco de Dados")

# Configurar a janela
root.geometry("1000x800")  # Aumentando o tamanho da janela

# Frame principal com 2 colunas
frame_main = tk.Frame(root, padx=10, pady=10)
frame_main.pack(fill="both", padx=20, pady=10)

# Frame para as configurações de banco de dados
frame_db = tk.Frame(frame_main, padx=10, pady=10)
frame_db.grid(row=0, column=0, sticky="w", padx=10, pady=10)

# Frame para as consultas
frame_query = tk.Frame(frame_main, padx=10, pady=10)
frame_query.grid(row=0, column=1, sticky="w", padx=10, pady=10)

# Labels e campos de entrada para o servidor, banco de dados, usuário e senha
label_server = tk.Label(frame_db, text="Servidor:")
label_server.grid(row=0, column=0, sticky="w", pady=5)
entry_server = tk.Entry(frame_db)
entry_server.insert(0, 'localhost')  # Valor padrão
entry_server.grid(row=0, column=1, pady=5)

label_database = tk.Label(frame_db, text="Banco de Dados:")
label_database.grid(row=1, column=0, sticky="w", pady=5)
entry_database = tk.Entry(frame_db)
entry_database.insert(0, 'PoliSystemServerSQLDB')  # Valor padrão
entry_database.grid(row=1, column=1, pady=5)

label_username = tk.Label(frame_db, text="Usuário:")
label_username.grid(row=2, column=0, sticky="w", pady=5)
entry_username = tk.Entry(frame_db)
entry_username.insert(0, 'sa')  # Valor padrão
entry_username.grid(row=2, column=1, pady=5)

label_password = tk.Label(frame_db, text="Senha:")
label_password.grid(row=3, column=0, sticky="w", pady=5)
entry_password = tk.Entry(frame_db, show="*")
entry_password.insert(0, 'PoliSystemsapwd')  # Valor padrão
entry_password.grid(row=3, column=1, pady=5)

# Funções para os botões de consulta
def consulta_dia_atual():
    realizar_consulta(query_dia_atual)

def consulta_mes_atual():
    realizar_consulta(query_mes_atual)

def consulta_mes_anterior():
    realizar_consulta(query_mes_anterior)

# Botões para as consultas no frame_query
button_dia_atual = tk.Button(frame_query, text="Dia Atual", command=consulta_dia_atual)
button_dia_atual.grid(row=0, column=0, pady=10, padx=10)

button_mes_atual = tk.Button(frame_query, text="Mês Atual", command=consulta_mes_atual)
button_mes_atual.grid(row=1, column=0, pady=10, padx=10)

button_mes_anterior = tk.Button(frame_query, text="Mês Anterior", command=consulta_mes_anterior)
button_mes_anterior.grid(row=2, column=0, pady=10, padx=10)

# Frame para exibir os resultados da consulta
frame_results = tk.Frame(root, padx=10, pady=10)
frame_results.pack(fill="both", padx=20, pady=10)

# Adicionando o canvas para permitir a rolagem horizontal
canvas = tk.Canvas(frame_results)
scrollbar = tk.Scrollbar(frame_results, orient="horizontal", command=canvas.xview)
canvas.configure(xscrollcommand=scrollbar.set)

# Frame para o campo de texto
frame_text = tk.Frame(canvas)
text_output = tk.Text(frame_text, wrap=tk.NONE, height=20, font=("Courier", 10))
text_output.pack(fill="both", expand=True)

# Adicionando o frame_text ao canvas
canvas.create_window((0, 0), window=frame_text, anchor="nw")

# Configurar o canvas para rolagem horizontal
def on_frame_configure(event):
    canvas.configure(scrollregion=canvas.bbox("all"))

frame_text.bind("<Configure>", on_frame_configure)
canvas.pack(fill="both", expand=True, side="left")
scrollbar.pack(fill="x", side="bottom")

# Iniciar a interface gráfica
root.mainloop()
