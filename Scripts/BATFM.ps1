# BATFM_TeamViewer_SendKeys_RemoteExec_Adjusted.ps1
# PowerShell - Envia comandos para a janela do TeamViewer (SendKeys + Clipboard) e valida execução via arquivo remoto
# Ajustado: maiores delays, retries, fallback de envio, tentativa de leitura SMB com credenciais opcionais
# By: Herberth Amorim (adaptado)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public const int SW_RESTORE = 9;
}
"@

function Write-Log { param($t) $path="$env:USERPROFILE\logs\batfm_tv_exec.log"; $s="$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $t"; $s | Out-File -FilePath $path -Append -Encoding utf8 -ErrorAction SilentlyContinue }

function Find-TeamViewerWindow {
    # Tenta identificar janela TeamViewer por processo ou títulos comuns
    $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match 'TeamViewer' -or $_.ProcessName -match 'TeamViewer_Service' -or $_.ProcessName -match 'TeamViewer_Desktop' }
    foreach ($p in $procs) {
        try {
            if ($p.MainWindowHandle -and $p.MainWindowHandle -ne 0) { return [IntPtr]$p.MainWindowHandle }
        } catch { }7.98.145.68
    }
    # fallback por nome de janela (algumas versões)
    $names = @("TeamViewer", "TeamViewer - Remote control", "TeamViewer (Remote Control)", "TeamViewer - Remote Control")
    foreach ($n in $names) {
        try {
            $h = [WinAPI]::FindWindow($null, $n)
            if ($h -ne [IntPtr]::Zero) { return $h }
        } catch { }
    }
    return $null
}

function Bring-TeamViewerToFront {
    param([IntPtr]$hwnd)
    try {
        [WinAPI]::ShowWindow($hwnd, [WinAPI]::SW_RESTORE) | Out-Null
        Start-Sleep -Milliseconds 350
        [WinAPI]::SetForegroundWindow($hwnd) | Out-Null
        Start-Sleep -Milliseconds 450
        return $true
    } catch {
        return $false
    }
}

function Send-Keys-With-Clipboard {
    param([string]$text, [int]$postDelaySeconds = 2)
    # Copia para clipboard e envia Ctrl+V + ENTER
    try {
        [System.Windows.Forms.Clipboard]::SetText($text)
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.SendKeys]::SendWait("^v")
        Start-Sleep -Milliseconds 150
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep -Seconds $postDelaySeconds
        return $true
    } catch {
        return $false
    }
}

function Send-Keys-Fallback-CharByChar {
    param([string]$text, [int]$charDelayMs = 80, [int]$postDelaySeconds = 2)
    # envia caractere a caractere como fallback
    foreach ($c in $text.ToCharArray()) {
        $k = [string]$c
        [System.Windows.Forms.SendKeys]::SendWait($k)
        Start-Sleep -Milliseconds $charDelayMs
    }
    Start-Sleep -Milliseconds 120
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Seconds $postDelaySeconds
    return $true
}

function Send-Command-To-TeamViewer {
    param([string]$commandToRun, [int]$tries = 3)
    $hwnd = Find-TeamViewerWindow
    if (-not $hwnd) { Write-Host "Janela do TeamViewer não encontrada. Abra a sessão de Remote Control primeiro." -ForegroundColor Red; Write-Log "WindowNotFound"; return $false }

    if (-not (Bring-TeamViewerToFront -hwnd $hwnd)) { Write-Host "Não foi possível focar a janela do TeamViewer."; Write-Log "BringFrontFailed"; return $false }

    # Comando remoto deve criar arquivo de confirmação com marcador
    $marker = '---REMOTE_OK---'
    $escaped = $commandToRun.Replace('"','\"')
    # formata comando a ser colado no Run: usar cmd /c "comando & echo ---REMOTE_OK--- > C:\Windows\Temp\batfm_remote_ok.txt & echo EXIT_CODE:%ERRORLEVEL%"
    $remoteCmd = "cmd /c `"$escaped & echo $marker > C:\Windows\Temp\batfm_remote_ok.txt & echo EXIT_CODE:%ERRORLEVEL%`""

    # Primeiro: abrir Run via Start Menu + 'r' (mais confiável que enviar Win key)
    # Abre Start Menu (Ctrl+Esc) e depois 'r' para abrir Executar
    [System.Windows.Forms.SendKeys]::SendWait("^{ESC}")
    Start-Sleep -Milliseconds 350
    [System.Windows.Forms.SendKeys]::SendWait("r")
    Start-Sleep -Milliseconds 400

    # tentativa de colar via clipboard
    $sent = $false
    for ($i=1; $i -le $tries; $i++) {
        $ok = Send-Keys-With-Clipboard -text $remoteCmd -postDelaySeconds 2
        if ($ok) { $sent = $true; break }
        Start-Sleep -Milliseconds 200
    }
    if (-not $sent) {
        # fallback char-by-char
        $sent = Send-Keys-Fallback-CharByChar -text $remoteCmd -charDelayMs 90 -postDelaySeconds 2
    }

    if ($sent) { Write-Log "Sent command to TeamViewer (tries=$tries)"; return $true }
    else { Write-Log "Failed to send to TeamViewer"; return $false }
}

function Try-Fetch-RemoteMarker {
    param([string]$targetIp, [pscredential]$cred = $null, [int]$retries = 6, [int]$waitSeconds = 2)
    if (-not $targetIp) { return $null }
    $remotePath = "\\$targetIp\C$\Windows\Temp\batfm_remote_ok.txt"
    for ($i=1; $i -le $retries; $i++) {
        try {
            if ($cred) {
                $user = $cred.GetNetworkCredential().UserName; $pw = $cred.GetNetworkCredential().Password
                net use "\\$targetIp\C$" /user:$user $pw 2>&1 | Out-Null
            }
            Start-Sleep -Seconds 1
            if (Test-Path $remotePath) {
                $text = Get-Content $remotePath -ErrorAction SilentlyContinue | Out-String
                if ($cred) { net use "\\$targetIp\C$" /delete 2>&1 | Out-Null }
                return $text
            } else {
                if ($cred) { net use "\\$targetIp\C$" /delete 2>&1 | Out-Null }
                Start-Sleep -Seconds $waitSeconds
            }
        } catch {
            if ($cred) { net use "\\$targetIp\C$" /delete 2>&1 | Out-Null }
            Start-Sleep -Seconds $waitSeconds
        }
    }
    return $null
}

# ---- fluxo principal ----
Clear-Host
Write-Host "=== BAT-FM TeamViewer Remote Exec (AJUSTADO) ===" -ForegroundColor Cyan
Write-Host "ATENÇÃO: a janela do TeamViewer deve estar aberta e a sessão remota ativa; não mova o mouse/teclado no seu PC durante o envio." -ForegroundColor Yellow
$partnerIp = Read-Host "Informe o IP do parceiro (opcional, usado para validação via SMB)"
$cmd = Read-Host "Comando que deseja executar no remoto (ex: ipconfig /all OR start notepad.exe)"

$confirm = Read-Host "Vou enviar as teclas para a janela do TeamViewer. Confirmar? (S/N)"
if ($confirm.ToUpper() -ne 'S') { Write-Host "Cancelado."; exit }

$sent = Send-Command-To-TeamViewer -commandToRun $cmd -tries 4
if (-not $sent) { Write-Host "Falha no envio das teclas para a janela do TeamViewer." -ForegroundColor Red; exit }

Write-Host "Comando enviado. Aguardando criação do arquivo de confirmação no remoto..." -ForegroundColor Cyan
Start-Sleep -Seconds 4

# se IP informado, tentar buscar o arquivo remoto com retries (permite credenciais)
$askCred = $false
if ($partnerIp) {
    $askCred = Read-Host "Deseja fornecer credenciais para tentar ler o arquivo via SMB? (S/N)"
}
$cred = $null
if ($askCred.ToUpper() -eq 'S') {
    $cred = Get-Credential -Message "Credenciais administrativas para \\$partnerIp\C$"
}

$text = $null
if ($partnerIp) {
    $text = Try-Fetch-RemoteMarker -targetIp $partnerIp -cred $cred -retries 8 -waitSeconds 2
}

if ($text) {
    if ($text -match '---REMOTE_OK---') {
        Write-Host "✅ Comando executado no remoto (marker encontrado)." -ForegroundColor Green
        Write-Host "Conteúdo do arquivo remoto:`n$text"
        Write-Log "SUCCESS Remote marker found on $partnerIp"
    } else {
        Write-Host "⚠ Arquivo remoto sem marker. Conteúdo:`n$text" -ForegroundColor Yellow
        Write-Log "WARN Remote file no marker"
    }
} else {
    Write-Host "⚠ Não foi possível ler o arquivo remoto. Se não tem SMB/credenciais, peça ao parceiro para checar C:\Windows\Temp\batfm_remote_ok.txt." -ForegroundColor Yellow
    Write-Log "WARN Could not fetch remote file or file not created yet"
}

Write-Host "`nFim do processo." -ForegroundColor Cyan
