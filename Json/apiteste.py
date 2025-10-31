import requests
import json
import os
import time
from datetime import datetime

# =================== CONFIGURAÇÕES =================== #
BASE_URL = "https://api.erpsaas.com.br/api/Produtos"
HEADERS = {
    "Authorization": "ACXBw1qsnYy0efXLmNiSYDGOXNiShiKxFHxAHwW8Uvnvn44bbDi29fWq0fkqUHsy",
    "Accept": "application/json",
    "Content-Type": "application/json",
    "sistema": "novoerp",
    "x-app-cnpj": "21416561000146",
    "x-app-name": "front-angular",
    "x-app-version": "12.3.0"
}

OUTPUT_DIR = r"C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Json"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# =================== FUNÇÕES =================== #
def buscar_produto_por_id(produto_id):
    """Busca o produto completo (para capturar campos obrigatórios)."""
    url = f"{BASE_URL}/{produto_id}"
    r = requests.get(url, headers=HEADERS, timeout=15)
    if r.status_code == 200:
        return r.json()
    print(f"⚠️ Falha ao buscar produto ID={produto_id}: {r.status_code}")
    return None

def atualizar_favorito(produto):
    """Atualiza o campo favorito mantendo campos obrigatórios."""
    payload = {
        "descricao": produto.get("descricao"),
        "codigoProduto": produto.get("codigoProduto"),
        "favorito": "S"
    }
    r = requests.patch(f"{BASE_URL}/{produto['id']}", headers=HEADERS, json=payload, timeout=15)
    return {"id": produto["id"], "status": r.status_code, "resposta": r.text[:200]}

def listar_produtos(limite=100, skip=0):
    """Lista produtos paginados com campos essenciais"""
    params = {
        "filter": json.dumps({
            "limit": limite,
            "skip": skip,
            "fields": ["id", "codigoProduto", "descricao", "favorito"]
        })
    }
    r = requests.get(BASE_URL, headers=HEADERS, params=params, timeout=30)
    if r.status_code != 200:
        print(f"❌ Erro ao listar produtos (skip={skip}): {r.status_code}")
        return []
    return r.json()

# =================== EXECUÇÃO PRINCIPAL =================== #
def main():
    inicio = datetime.now()
    print("🔍 Buscando produtos para atualização de favorito...")

    todos_produtos = []
    skip = 0
    limite = 100

    # --- PAGINAÇÃO --- #
    while True:
        lote = listar_produtos(limite, skip)
        if not lote:
            break
        todos_produtos.extend(lote)
        print(f"📦 Página {skip//limite + 1}: {len(lote)} produtos (total: {len(todos_produtos)})")
        skip += limite
        time.sleep(0.4)

    produtos_para_atualizar = [p for p in todos_produtos if p.get("favorito") == "N"]

    print(f"🧩 Total de produtos a atualizar: {len(produtos_para_atualizar)}")

    resultados = []
    for p in produtos_para_atualizar:
        produto_id = p["id"]
        print(f"✏️ Atualizando produto {p.get('codigoProduto')} - {p.get('descricao')}")
        produto_completo = buscar_produto_por_id(produto_id)
        if not produto_completo:
            continue
        r = atualizar_favorito(produto_completo)
        resultados.append({
            "id": produto_id,
            "codigoProduto": p.get("codigoProduto"),
            "descricao": p.get("descricao"),
            "status": r["status"],
            "resposta": r["resposta"]
        })
        time.sleep(0.3)

    fim = datetime.now()
    tempo_total = int((fim - inicio).total_seconds())

    relatorio = {
        "data_execucao": fim.strftime("%Y-%m-%d %H:%M:%S"),
        "tempo_total_segundos": tempo_total,
        "quantidade_total_produtos": len(todos_produtos),
        "quantidade_atualizados": len(produtos_para_atualizar),
        "resultados": resultados
    }

    caminho_relatorio = os.path.join(OUTPUT_DIR, f"favoritos_atualizados_{fim.strftime('%H%M%S')}.json")
    with open(caminho_relatorio, "w", encoding="utf-8") as f:
        json.dump(relatorio, f, ensure_ascii=False, indent=4)

    print(f"✅ Atualização concluída. Relatório salvo em:\n{caminho_relatorio}")

if __name__ == "__main__":
    main()
