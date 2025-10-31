# ==============================================
# EXTRAÇÃO DE ITENS IGNORADOS E ITENS ENTRE ASPAS SIMPLES ('...')
# PROCURA AUTOMATICAMENTE O ARQUIVO .LOG MAIS RECENTE NA PASTA
# ==============================================

# Pasta onde estão os arquivos .log
$pasta = "C:\Users\Maqplan\Downloads\INSTALAÇÃO\Ajuda\CMD\Extracao"

# Procurar o arquivo .log mais recente
$arquivoMaisRecente = Get-ChildItem -Path $pasta -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $arquivoMaisRecente) {
    Write-Host "❌ Nenhum arquivo .log encontrado em $pasta" -ForegroundColor Red
    exit
}

$origem = $arquivoMaisRecente.FullName
Write-Host "📂 Arquivo encontrado: $origem" -ForegroundColor Cyan

# Caminho do arquivo de destino
$dataHora = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$destino = Join-Path $pasta "resultado_extracao_$dataHora.log"

# Ler o arquivo detectando codificação automaticamente
$bytes = [System.IO.File]::ReadAllBytes($origem)

# Detectar codificação (UTF-8 / UTF-16 / ANSI)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
    $encodingOrigem = [System.Text.Encoding]::UTF8
}
elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 255 -and $bytes[1] -eq 254) {
    $encodingOrigem = [System.Text.Encoding]::Unicode
}
elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 254 -and $bytes[1] -eq 255) {
    $encodingOrigem = [System.Text.Encoding]::BigEndianUnicode
}
else {
    $encodingOrigem = [System.Text.Encoding]::GetEncoding(1252)
}

# Converter para texto
$conteudo = $encodingOrigem.GetString($bytes)

# ----------------------------------------------------
# 1️⃣ Padrão novo: Item ignorado: ... (Código: ####)
# ----------------------------------------------------
$regexItemIgnorado = "Item ignorado:\s*(.+?)\s*\(C[oó]digo:\s*(\d+)\)"
$matchesItemIgnorado = [regex]::Matches($conteudo, $regexItemIgnorado)

# ----------------------------------------------------
# 2️⃣ Padrão antigo: 'texto entre aspas simples'
# ----------------------------------------------------
$regexAspas = "[‘']([^‘']*)[’']"
$matchesAspas = [regex]::Matches($conteudo, $regexAspas)

# ----------------------------------------------------
# Juntar todos os resultados encontrados
# ----------------------------------------------------
$resultados = @()

# Adicionar itens do padrão novo
foreach ($m in $matchesItemIgnorado) {
    $resultados += "$($m.Groups[1].Value) - Código: $($m.Groups[2].Value)"
}

# Adicionar itens do padrão antigo
foreach ($m in $matchesAspas) {
    $texto = $m.Groups[1].Value.Trim()
    if ($texto -ne "") {
        $resultados += $texto
    }
}

# ----------------------------------------------------
# Verificar se há resultados
# ----------------------------------------------------
if ($resultados.Count -eq 0) {
    Write-Host "⚠️ Nenhum item encontrado nos padrões pesquisados." -ForegroundColor Yellow
    exit
}

# Criar codificação UTF-8 sem BOM para o arquivo de saída
$utf8SemBOM = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($destino, $resultados, $utf8SemBOM)

# Exibir resumo
Write-Host ""
Write-Host "✅ Extração concluída com sucesso!" -ForegroundColor Green
Write-Host "Arquivo processado: $origem" -ForegroundColor Cyan
Write-Host "Itens encontrados: $($resultados.Count)" -ForegroundColor Yellow
Write-Host "Arquivo salvo em: $destino" -ForegroundColor Cyan
Write-Host ""
