import os
import json
import re
from datetime import datetime

# ============================================================
# CONFIGURAÇÃO
# ============================================================
PASTA = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD"
SAIDA_DIR = PASTA  # onde salvar o resultado

# ============================================================
# FUNÇÕES
# ============================================================

def ler_arquivo_recente(pasta):
    """Retorna o caminho do arquivo mais recente (.json ou .log)."""
    arquivos = [
        os.path.join(pasta, f)
        for f in os.listdir(pasta)
        if f.lower().endswith((".json", ".log"))
    ]
    if not arquivos:
        return None
    return max(arquivos, key=os.path.getmtime)


def detectar_tipo(conteudo: str) -> str:
    """Detecta o tipo de conteúdo."""
    try:
        json.loads(conteudo)
        return "json"
    except Exception:
        pass

    if re.search(r"-------------- Error \(\d{4}-\d{2}-\d{2}", conteudo):
        return "log_pdv"

    return "log_generico"


def tratar_json(conteudo: str):
    """Formatar JSON."""
    obj = json.loads(conteudo)
    return json.dumps(obj, indent=4, ensure_ascii=False)


def tratar_log_pdv(conteudo: str):
    """Converte logs PDV para JSON estruturado."""
    blocos = re.split(r"-------------- Error", conteudo)
    erros = []
    for b in blocos:
        if not b.strip():
            continue
        m_data = re.search(r"\((\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d+)\)", b)
        if not m_data:
            continue
        data = m_data.group(1)
        call = re.search(r"Call Site:\s*(.+)", b)
        tipo = re.search(r"Exception Type:\s*(.+)", b)
        msg = re.search(r"Exception Message:\s*(.+)", b)
        inner = re.search(r"Inner Exception:\s*(.+)", b)
        erros.append({
            "Data": data.strip(),
            "CallSite": call.group(1).strip() if call else "",
            "Tipo": tipo.group(1).strip() if tipo else "",
            "Mensagem": msg.group(1).strip() if msg else "",
            "InnerException": inner.group(1).strip() if inner else ""
        })
    return json.dumps(erros, indent=4, ensure_ascii=False)


def tratar_log_generico(conteudo: str):
    """Filtra linhas com palavras-chave de erro."""
    padroes = ["Exception", "ERROR", "violates", "duplicate key", "Inner Exception"]
    linhas = conteudo.splitlines()
    capturados = [l for l in linhas if any(p in l for p in padroes)]
    return json.dumps([{"Linha": l} for l in capturados], indent=4, ensure_ascii=False)


def salvar_resultado(conteudo_json: str):
    """Salva resultado JSON."""
    data_hora = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    nome_arquivo = f"resultado_{data_hora}.json"
    caminho = os.path.join(SAIDA_DIR, nome_arquivo)
    with open(caminho, "w", encoding="utf-8") as f:
        f.write(conteudo_json)
    return caminho


# ============================================================
# EXECUÇÃO
# ============================================================

def main():
    print("\n🧩 JSONFAST — Conversor de LOG e JSON (Python Edition)")
    print("======================================================\n")
    print("1️⃣  Colar manualmente o conteúdo (pressione ENTER duplo ao terminar)")
    print("2️⃣  Usar o último arquivo encontrado (.json ou .log)\n")

    modo = input("Digite 1 ou 2: ").strip()

    # === MODO 1 — COLAR MANUALMENTE ===
    if modo == "1":
        print("\n📋 Cole o conteúdo abaixo e pressione ENTER duas vezes quando terminar:\n")
        linhas = []
        while True:
            try:
                linha = input()
            except EOFError:
                break
            if not linha.strip():
                break
            linhas.append(linha)
        conteudo = "\n".join(linhas)
        if not conteudo.strip():
            print("❌ Nenhum conteúdo colado.")
            return

    # === MODO 2 — ARQUIVO AUTOMÁTICO ===
    elif modo == "2":
        arquivo = ler_arquivo_recente(PASTA)
        if not arquivo:
            print(f"❌ Nenhum arquivo .json ou .log encontrado em {PASTA}")
            return
        print(f"\n📂 Arquivo encontrado: {arquivo}")
        with open(arquivo, "r", encoding="utf-8", errors="ignore") as f:
            conteudo = f.read()

    else:
        print("⚠️ Opção inválida. Use 1 ou 2.")
        return

    tipo = detectar_tipo(conteudo)

    if tipo == "json":
        print("✅ JSON detectado — formatando...")
        saida = tratar_json(conteudo)
    elif tipo == "log_pdv":
        print("🧱 Log PDV detectado — convertendo para JSON estruturado...")
        saida = tratar_log_pdv(conteudo)
    else:
        print("🧾 Log genérico detectado — extraindo exceções...")
        saida = tratar_log_generico(conteudo)

    destino = salvar_resultado(saida)
    print("\n✅ Conversão concluída com sucesso!")
    print(f"📁 Arquivo salvo em: {destino}\n")


if __name__ == "__main__":
    main()
