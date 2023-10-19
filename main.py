class Exec:
    def __init__(self):
        self.dados = []


    def Cont(self):
        tabela = {}
        tabela ["nome"] =  str(input("Digite o nome: "))
        tabela ["telefone"] = int(input("Digite o telefone: "))
        tabela ["sexo"] =  str(input("Digite o sexo: "))

        self.dados.append(tabela)


    def showPerfil(self):
        for tabela in self.dados:
            print (f"Nome: {tabela['nome']}, Telefone: {tabela['telefone']}, Sexo: {tabela['sexo']}")
    

