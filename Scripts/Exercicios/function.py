def remover_espacos_duplos_triplos(texto):
    novo_texto = ''
    espacos_consecutivos = 0

    for caractere in texto:
        if caractere == ' ':
            espacos_consecutivos += 1
            if espacos_consecutivos <= 3:
                novo_texto += caractere
        else:
            novo_texto += caractere
            espacos_consecutivos = 0

    return novo_texto

# Função para ler o conteúdo de um arquivo
def ler_arquivo(nome_arquivo):
    with open(nome_arquivo, 'r') as arquivo:
        return arquivo.read()

# Função para escrever o conteúdo em um arquivo
def escrever_arquivo(nome_arquivo, conteudo):
    with open(nome_arquivo, 'w') as arquivo:
        arquivo.write(conteudo)

# Nome do arquivo de bloco de notas
nome_arquivo = "C:\Users\Maqplan\Desktop\produtos.txt"

# Ler o conteúdo do arquivo
try:
    texto_com_espacos = ler_arquivo(nome_arquivo)
except FileNotFoundError:
    print(f"Arquivo '{nome_arquivo}' não encontrado.")
else:
    # Aplicar a função para remover espaços duplos ou triplos
    texto_sem_espacos_duplos = remover_espacos_duplos_triplos(texto_com_espacos)

    # Escrever o novo texto de volta no arquivo
    escrever_arquivo(nome_arquivo, texto_sem_espacos_duplos)

    print("Texto original:")
    print(texto_com_espacos)

    print("\nTexto sem espaços duplos ou triplos:")
    print(texto_sem_espacos_duplos)
    print(f"\nConteúdo modificado foi salvo no arquivo '{nome_arquivo}'.")
