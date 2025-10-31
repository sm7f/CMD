<#
.SYNOPSIS
Corrige erro 0x00000709 de compartilhamento de impressoras no Windows 11 (sem domínio).
.DESCRIPTION
Garante que os recursos e módulos de impressão estejam instalados,
corrige configurações RPC locais, e reinicia o spooler.
#>

Write-Host "=== Iniciando correção do erro 0x00000709 ===" -ForegroundColor Cyan

# --- 1. Instalar pré-requisitos de impressão ---
Write-Host "`n[1/4] Verificando e habilitando recursos de impressão..." -ForegroundColor Yellow

$features = @(
    "Printing-Foundation-Features",
    "Printing-Foundation-InternetPrinting-Client",
    "Printing-Foundation-UserDriverRegistration"
)

foreach ($feature in $features) {
    $status = (Get-WindowsOptionalFeature -Online -FeatureName $feature).State
    if ($status -ne "Enabled") {
        Write-Host "Ativando $feature ..." -ForegroundColor Gray
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart | Out-Null
    } else {
        Write-Host "$feature já está habilitado." -ForegroundColor Green
    }
}

# --- 2. Garantir módulo PrintManagement ---
Write-Host "`n[2/4] Garantindo módulo PrintManagement..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable -Name PrintManagement)) {
    try {
        Add-WindowsCapability -Online -Name "Print.Management.Console~~~~0.0.1.0" | Out-Null
        Write-Host "Módulo PrintManagement instalado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Falha ao instalar PrintManagement. Erro: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Módulo PrintManagement já disponível." -ForegroundColor Green
}

# --- 3. Corrigir políticas RPC locais (compatibilidade) ---
Write-Host "`n[3/4] Corrigindo políticas RPC de impressão..." -ForegroundColor Yellow

$rpcPath = "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\RPC"
New-Item -Path $rpcPath -Force | Out-Null

Set-ItemProperty -Path $rpcPath -Name "RpcUseNamedPipeProtocol" -Type DWord -Value 1
Set-ItemProperty -Path $rpcPath -Name "RpcAuthentication" -Type DWord -Value 0

Write-Host "Política RPC ajustada para compatibilidade com impressoras compartilhadas." -ForegroundColor Green

# --- 4. Reiniciar spooler ---
Write-Host "`n[4/4] Reiniciando serviço de spooler..." -ForegroundColor Yellow
Restart-Service Spooler -Force
Start-Sleep 3

Write-Host "`nServiço de impressão reiniciado com sucesso." -ForegroundColor Green
Write-Host "`n=== Correção concluída. Tente adicionar novamente a impressora compartilhada. ===" -ForegroundColor Cyan
