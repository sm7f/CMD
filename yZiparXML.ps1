# CONFIGURAÇÕES (AJUSTE ANTES DE EXECUTAR)
$pastaOrigem = "C:\MaqplanNFe\NFCe\XMLDestinatario"  # Verifique se este caminho existe
$mesAlvo = 3   # Mês desejado (1-12)
$anoAlvo = 2025 # Ano desejado
$arquivo7z = "C:\xml_${mesAlvo}_${anoAlvo}.7z"

# 1. VERIFICAÇÃO INICIAL
if (-not (Test-Path $pastaOrigem)) {
    Write-Host "ERRO: Pasta não encontrada!`nVerifique o caminho: $pastaOrigem" -ForegroundColor Red
    exit
}

# 2. INSTALAÇÃO DO MÓDULO (SE NECESSÁRIO)
if (-not (Get-Module -Name 7Zip4PowerShell -ErrorAction SilentlyContinue)) {
    try {
        Install-Module -Name 7Zip4PowerShell -Force -Scope CurrentUser -ErrorAction Stop
        Import-Module 7Zip4PowerShell -ErrorAction Stop
        Write-Host "Módulo 7Zip instalado com sucesso!" -ForegroundColor Cyan
    } catch {
        Write-Host "FALHA AO INSTALAR MÓDULO:`n$_" -ForegroundColor Red
        exit
    }
}

# 3. BUSCA DE ARQUIVOS
Write-Host "`nBuscando arquivos de $mesAlvo/$anoAlvo em $pastaOrigem..." -ForegroundColor Yellow
$arquivos = @(Get-ChildItem -Path $pastaOrigem -File -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.LastWriteTime.Month -eq $mesAlvo -and $_.LastWriteTime.Year -eq $anoAlvo })

# 4. VERIFICAÇÃO DE ARQUIVOS ENCONTRADOS
if ($arquivos.Count -eq 0) {
    Write-Host "NENHUM ARQUIVO ENCONTRADO para $mesAlvo/$anoAlvo!`nVerifique:" -ForegroundColor Red
    Write-Host "- Datas de modificação dos arquivos" -ForegroundColor Yellow
    Write-Host "- Permissões na pasta" -ForegroundColor Yellow
    exit
} else {
    Write-Host "Encontrados $($arquivos.Count) arquivos para compactação!" -ForegroundColor Green
    # Mostrar os 3 primeiros arquivos como exemplo
    $arquivos | Select-Object -First 3 | Format-Table Name, LastWriteTime -AutoSize
}

# 5. COMPACTAÇÃO
$contador = 0
if (Test-Path $arquivo7z) { 
    Remove-Item $arquivo7z -Force 
    Write-Host "Arquivo existente removido: $arquivo7z" -ForegroundColor Magenta
}

Write-Host "`nINICIANDO COMPACTAÇÃO..." -ForegroundColor Cyan
foreach ($arquivo in $arquivos) {
    $contador++
    $porcentagem = [math]::Round(($contador / $arquivos.Count) * 100, 2)
    Write-Progress -Activity "Compactando: $($arquivo.Name)" `
                  -Status "$porcentagem% ($contador de $($arquivos.Count))" `
                  -PercentComplete $porcentagem
    
    try {
        if ($contador -eq 1) {
            Compress-7Zip -ArchiveFileName $arquivo7z -Path $arquivo.FullName -Format SevenZip -CompressionLevel Ultra
        } else {
            Compress-7Zip -ArchiveFileName $arquivo7z -Path $arquivo.FullName -Format SevenZip -CompressionLevel Ultra -Append
        }
    } catch {
        Write-Host "ERRO ao compactar $($arquivo.Name): $_" -ForegroundColor Red
    }
}

# 6. VERIFICAÇÃO FINAL
if (Test-Path $arquivo7z) {
    $tamanho = (Get-Item $arquivo7z).Length / 1MB
    Write-Host "`n✅ COMPACTAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
    Write-Host "📅 Período: $mesAlvo/$anoAlvo" -ForegroundColor Cyan
    Write-Host "📦 Arquivo: $arquivo7z" -ForegroundColor Cyan
    Write-Host "📂 Tamanho: $($tamanho.ToString('0.00')) MB" -ForegroundColor Cyan
    Write-Host "🔢 Arquivos compactados: $($arquivos.Count)" -ForegroundColor Cyan
    
    # Abrir pasta do arquivo criado
    explorer /select,$arquivo7z
} else {
    Write-Host "ERRO: O arquivo compactado não foi gerado!" -ForegroundColor Red
}