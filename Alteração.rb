# BAT-FM-Kali-Style-VPN-MODE.ps1
# PowerShell "BAT-FM Kali Style" - Canivete Suíço para Manutenção Remota
# FLUXO: Técnico já conectou via TeamViewer → VPN já ativada manualmente → Script roda no PC do cliente
# By: Herberth Amorim

# ---------- Config ----------
$Server        = "."
$Database      = "PoliSystemServerSQLDB"
$LogDir        = Join-Path $env:USERPROFILE "logs"
if (-not (Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null }
$LogFile       = Join-Path $LogDir "config_kali.log"
$CustomMessage = " - User com Responsabilidade - Não confunda zera licença com zerar estoque OBG é Noix"

# Globals
$Global:TechnicianName = $null
$Global:ClientName = $env:COMPUTERNAME
$Global:VpnStatus = "Não detectada"

# ---------- Helpers ----------
function Write-Log {
    param([string]$text)
    try {
        "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $text" | Out-File -FilePath $LogFile -Append -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch { }
}

# ---------- Detectar VPN (opcional, só para info) ----------
function Get-VpnStatus {
    try {
        $adapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {
            ($_.InterfaceDescription -match "TeamViewer" -or $_.Name -match "TeamViewer") -and $_.Status -eq "Up"
        }
        if ($adapters) {
            $ip = Get-NetIPAddress -InterfaceIndex $adapters[0].ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($ip) {
                return "Ativa - IP: $($ip.IPAddress)"
            }
        }
        # Fallback: verifica IPs 7.x (TeamViewer usa esse range)
        $tvIp = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -match '^7\.' } | Select-Object -First 1
        if ($tvIp) {
            return "Ativa - IP: $($tvIp.IPAddress)"
        }
    } catch { }
    return "Não detectada (ou não configurada)"
}

# ---------- UI / Banner ----------
function Show-Intro {
    Clear-Host
    $host.UI.RawUI.WindowTitle = "BAT-FM Kali Style :: Identificação do Técnico"
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "    ███████╗████████╗ █████╗  ██████╗ ████████╗" -ForegroundColor Cyan
    Write-Host "    ██╔════╝╚══██╔══╝██╔══██╗ ██╔══██╗╚══██╔══╝" -ForegroundColor Cyan
    Write-Host "    ███████╗   ██║   ███████║ ██████╔╝   ██║   " -ForegroundColor Cyan
    Write-Host "    ╚════██║   ██║   ██╔══██║ ██╔═██║    ██║   " -ForegroundColor Cyan
    Write-Host "    ███████║   ██║   ██║  ██║ ██║ ██║    ██║   " -ForegroundColor Cyan
    Write-Host "    ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═╝ ╚═╝    ╚═╝   " -ForegroundColor Cyan
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   >>> START <<<" -ForegroundColor Green
    Write-Host ""
    Write-Host $CustomMessage -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Bem vindo ao BAT-FM-Kali-Style :: Sistema de Manutenção Remota" -ForegroundColor White
    Write-Host "Para prosseguir, identifique-se (nome do técnico)." -ForegroundColor Yellow
    Write-Host ""
}

function Show-AccessDenied {
    Clear-Host
    $host.UI.RawUI.WindowTitle = "🚫 ACESSO NEGADO"
    Write-Host "====================================================================" -ForegroundColor DarkGray
    Write-Host "    ███████║ ██████╗  ██████╗    ██████╗        " -ForegroundColor Red
    Write-Host "    ██║      ██╔══██╗ ██╔══██╗  ██╔═══██╗       " -ForegroundColor Red
    Write-Host "    █████    ██████╔╝ ██████╔╝  ██║   ██║       " -ForegroundColor Red
    Write-Host "    ██║      ██╔═██║  ██╔═██║   ██║   ██║       " -ForegroundColor Red
    Write-Host "    ███████║ ██║ ██║  ██║ ██║   ╚██████╔╝       " -ForegroundColor Red
    Write-Host "    ╚══════╝ ╚═╝ ╚═╝  ╚═╝ ╚═╝    ╚═════╝        " -ForegroundColor Red
    Write-Host "====================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "🚫 ACESSO NEGADO - Identificação inválida." -ForegroundColor Red
    Write-Host "ℹ Se precisar de ajuda, DESISTA KKKK !." -ForegroundColor Yellow
    Write-Host ""
}

function Show-Banner {
    Clear-Host
    $host.UI.RawUI.WindowTitle = "KALI-TERMINAL :: PoliSystem Config"
    Write-Host "      ______           ██████╗   █████╗  ████████╗          " -ForegroundColor Red
    Write-Host "   .-        -.        ██╔══██  ██╔══██╗    ██╔══╝          " -ForegroundColor Red
    Write-Host "  |            |       ██████╗  ███████║    ██║             " -ForegroundColor Red
    Write-Host " |,  .-.  .-.  ,|      ██╔══██  ██╔══██║    ██║             " -ForegroundColor Red
    Write-Host " | )(_o|  |o_)( |      ██████   ██║  ██║    ██║             " -ForegroundColor Red
    Write-Host " ||     /\     ||                                           " -ForegroundColor Red
    Write-Host " (_     ^^     _)      █████╗  ███╗      ███╗               " -ForegroundColor Red
    Write-Host "  \__|IIIIII|__/       ██╔══╝  ████     ████║               " -ForegroundColor Red
    Write-Host "   | \IIIIII/ |        █████╗  ██║ ████║  ██║               " -ForegroundColor Red
    Write-Host "   |          |        ██╔══╝  ██║  ██║   ██║               " -ForegroundColor Red
    Write-Host "                       ██║     ██║  ██║   ██║               " -ForegroundColor Red
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Técnico: $Global:TechnicianName" -ForegroundColor Cyan
    Write-Host "Cliente: $Global:ClientName   |   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray
    Write-Host "Status VPN: $Global:VpnStatus" -ForegroundColor $(if($Global:VpnStatus -match "Ativa") { "Green" } else { "Yellow" })
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host $CustomMessage -ForegroundColor Magenta
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
}

# ---------- Validação do Técnico (primeiro contato) ----------
while ($true) {
    Show-Intro
    $inputName = Read-Host "Nome do Técnico (mínimo 3 caracteres)"

    if ($inputName -and $inputName.Length -ge 3) {
        $Global:TechnicianName = $inputName
        Write-Log "INICIO Sessao - Tecnico: $Global:TechnicianName | Cliente: $Global:ClientName"
        Start-Sleep -Milliseconds 400
        break
    } else {
        Show-AccessDenied
        Write-Log "ACESSO_NEGADO TentativaNome='$inputName'"
        Read-Host "`nPressione ENTER para tentar novamente"
    }
}

# Detecta status da VPN
$Global:VpnStatus = Get-VpnStatus
Write-Log "Status VPN: $Global:VpnStatus"

# ---------- Utilitários SQL ----------
function Run-SqlCmd {
    param(
        [string]$Server,
        [string]$Database,
        [string]$Query,
        [string[]]$ExtraArgs = @()
    )
    if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
        Write-Host "`n[!] sqlcmd não foi encontrado no PATH." -ForegroundColor Red
        Write-Host "    Verifique se SQL Server tools estão instalados." -ForegroundColor Yellow
        Read-Host "`nPressione ENTER para voltar"
        throw "sqlcmd_not_found"
    }
    $outFile = Join-Path $env:TEMP ("sqlcmd_output_{0}.txt" -f ([guid]::NewGuid().ToString()))
    $argList = @("-S", $Server, "-E", "-d", $Database) + $ExtraArgs + @("-Q", $Query)
    try {
        & sqlcmd @argList 2>&1 | Tee-Object -FilePath $outFile
        $exit = $LASTEXITCODE
    } catch {
        Write-Host "`n[!] Exceção ao executar sqlcmd:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        $exit = 99
    }
    return @{ ExitCode = $exit; OutputFile = $outFile }
}

# ---------- Funções de Manutenção ----------
function Reset-Licenca {
    $query = "UPDATE CONFIG_GERAL_SYS SET NrSerieLicenca='-1', BloqLicenca='-1'"
    Write-Host "`nroot@kali:~# Resetando Licenca..." -ForegroundColor Green
    $res = Run-SqlCmd -Server $Server -Database $Database -Query $query
    if ($res.ExitCode -eq 0) {
        Write-Host "✅ Licenca resetada com sucesso!" -ForegroundColor Green
        Write-Log "SUCESSO Reset-Licenca | Tecnico: $Global:TechnicianName"
    } else {
        Write-Host "❌ Erro ao resetar licenca. ExitCode: $($res.ExitCode)" -ForegroundColor Red
        Write-Log "ERRO Reset-Licenca ExitCode=$($res.ExitCode)"
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Integrador-Vendas {
    $query = "UPDATE VENDA SET StatusExportacao = 1"
    Write-Host "`nroot@kali:~# Integrador Vendas..." -ForegroundColor Green
    $res = Run-SqlCmd -Server $Server -Database $Database -Query $query
    if ($res.ExitCode -eq 0) {
        Write-Host "✅ Integrador Vendas executado com sucesso!" -ForegroundColor Green
        Write-Log "SUCESSO Integrador-Vendas | Tecnico: $Global:TechnicianName"
    } else {
        Write-Host "❌ Erro ao executar Integrador Vendas." -ForegroundColor Red
        Write-Log "ERRO Integrador-Vendas ExitCode=$($res.ExitCode)"
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Search-VendasByDate {
    param([string]$StartDate)
    if (-not $StartDate) {
        $StartDate = Read-Host "Informe a data (YYYY-MM-DD) (ex: 2025-01-15)"
    }
    if (-not ($StartDate -match '^\d{4}-\d{2}-\d{2}$')) {
        Write-Host "Formato de data inválido. Use: YYYY-MM-DD" -ForegroundColor Yellow
        Read-Host "`nPressione ENTER para voltar"
        return
    }
    $q = @"
SET NOCOUNT ON; 
SELECT CdVenda,
       CONVERT(varchar(19),DataHoraVenda,120) AS DataHoraVenda,
       ValorTotalVenda,
       IdentificacaoClienteVenda,
       SiglaTipoDocFiscal,
       SiglaStatusVenda,
       NrDocFiscalVenda
FROM VENDA
WHERE CAST(DataHoraVenda AS DATE) = '$StartDate'
  AND SiglaStatusVenda <> 'VF'
ORDER BY DataHoraVenda DESC;
"@
    $r = Run-SqlCmd -Server $Server -Database $Database -Query $q -ExtraArgs @("-h","-1","-s",",","-W")
    if ($r.ExitCode -ne 0) {
        Write-Host "❌ Erro na busca. ExitCode: $($r.ExitCode)" -ForegroundColor Red
        Write-Log "ERRO Search-Vendas ExitCode=$($r.ExitCode)"
        Read-Host "`nPressione ENTER para voltar"
        return
    }
    $lines = Get-Content $r.OutputFile -ErrorAction SilentlyContinue | Where-Object { $_.Trim().Length -gt 0 }
    if (-not $lines -or $lines.Count -eq 0) {
        Write-Host "`nℹ Nenhuma venda com status <> 'VF' encontrada em $StartDate" -ForegroundColor Yellow
        Read-Host "`nPressione ENTER para voltar"
        return
    }
    Write-Host "`n📊 Vendas encontradas:" -ForegroundColor Cyan
    $index = 0
    $saleMap = @{}
    foreach ($line in $lines) {
        $index++
        $cols = $line -split ","
        if ($cols.Count -lt 6) { continue }
        $CdVenda = $cols[0].Trim()
        $DataHora = $cols[1].Trim()
        $Valor = $cols[2].Trim()
        $Cliente = $cols[3].Trim()
        $Status = $cols[5].Trim()
        $NrDoc = if ($cols.Count -ge 7) { $cols[6].Trim() } else { "" }
        Write-Host "[$index] CdVenda: $CdVenda | Data: $DataHora | Valor: $Valor | Cliente: $Cliente | Status: $Status | NrDoc: $NrDoc" -ForegroundColor White
        $saleMap[$index] = $CdVenda
    }
    $sel = Read-Host "`nDigite o número da venda para corrigir (ou ENTER p/ cancelar)"
    if ([string]::IsNullOrWhiteSpace($sel)) { Read-Host "`nPressione ENTER para voltar"; return }
    if (-not $saleMap.ContainsKey([int]$sel)) {
        Write-Host "❌ Seleção inválida." -ForegroundColor Yellow
        Read-Host "`nPressione ENTER para voltar"
        return
    }
    $CdVendaChosen = $saleMap[[int]$sel]
    $conf = Read-Host "⚠️ Confirmar alteração para 'VF' da CdVenda $CdVendaChosen? (S/N)"
    if ($conf.ToUpper() -ne "S") { 
        Write-Host "Operação cancelada." -ForegroundColor Yellow
        Read-Host "`nPressione ENTER para voltar"
        return 
    }
    $updateQuery = "BEGIN TRANSACTION; UPDATE VENDA SET SiglaStatusVenda = 'VF' WHERE CdVenda = $CdVendaChosen; SELECT CdVenda, SiglaStatusVenda FROM VENDA WHERE CdVenda = $CdVendaChosen; COMMIT;"
    $resUpdate = Run-SqlCmd -Server $Server -Database $Database -Query $updateQuery
    if ($resUpdate.ExitCode -eq 0) {
        Write-Host "`n✅ Venda $CdVendaChosen atualizada para 'VF'." -ForegroundColor Green
        Write-Log "SUCESSO FixVenda CdVenda=$CdVendaChosen | Tecnico: $Global:TechnicianName"
    } else {
        Write-Host "❌ Erro ao atualizar CdVenda=$CdVendaChosen" -ForegroundColor Red
        Write-Log "ERRO FixVenda CdVenda=$CdVendaChosen"
        Get-Content $resUpdate.OutputFile -Tail 20 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_ -ForegroundColor DarkYellow }
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Excluir-Regedit {
    Write-Host "`nroot@kali:~# Excluindo chaves de registro..." -ForegroundColor Green
    $regKeys = @(
        "HKLM:\SOFTWARE\_Maqplan Software",
        "HKLM:\SOFTWARE\WOW6432Node\_Maqplan Software",
        "HKLM:\SOFTWARE\WOW6432Node\Maqplan"
    )
    $removidos = 0
    foreach ($key in $regKeys) {
        if (Test-Path $key) {
            try {
                Remove-Item -Path $key -Recurse -Force
                Write-Host "☠ Chave removida: '$key'" -ForegroundColor Red
                Write-Log "SUCESSO Removeu chave: $key | Tecnico: $Global:TechnicianName"
                $removidos++
            } catch {
                Write-Host "❌ Erro ao remover '$key': $($_.Exception.Message)" -ForegroundColor Yellow
                Write-Log "ERRO Remover chave $key"
            }
        } else {
            Write-Host "ℹ Chave não encontrada: '$key'" -ForegroundColor DarkGray
        }
    }
    if ($removidos -gt 0) {
        Write-Host "`n✅ Total de $removidos chave(s) removida(s)." -ForegroundColor Green
    } else {
        Write-Host "`nℹ Nenhuma chave foi removida." -ForegroundColor Yellow
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Permissao-Maqplan {
    Write-Host "`nroot@kali:~# Aplicando permissões na pasta C:\Maqplan..." -ForegroundColor Green
    if (-not (Test-Path "C:\Maqplan")) {
        Write-Host "❌ Pasta C:\Maqplan não encontrada!" -ForegroundColor Red
        Read-Host "`nPressione ENTER para voltar"
        return
    }
    try {
        $job = Start-Job -ScriptBlock { 
            icacls "C:\Maqplan" /grant "Todos":(OI)(CI)F /t /c 2>&1 | Out-Null
        }
        for ($i = 0; $i -le 100; $i += 5) {
            Write-Progress -Activity "Aplicando permissões" -Status "$i% concluído" -PercentComplete $i
            Start-Sleep -Milliseconds 120
        }
        Write-Progress -Activity "Aplicando permissões" -Completed
        $job | Wait-Job -Timeout 15 | Out-Null
        Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-Null
        Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
        Write-Host "`n✅ Permissões aplicadas com sucesso!" -ForegroundColor Green
        Write-Log "SUCESSO Permissao-Maqplan | Tecnico: $Global:TechnicianName"
    } catch {
        Write-Host "❌ Erro ao aplicar permissões: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "ERRO Permissao-Maqplan: $($_.Exception.Message)"
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Desativar-Firewall {
    Write-Host "`nroot@kali:~# Desativando firewall do Windows..." -ForegroundColor Green
    Write-Host "⚠️ ATENÇÃO: Isso desativa a proteção do firewall!" -ForegroundColor Yellow
    $confirm = Read-Host "Deseja continuar? (S/N)"
    if ($confirm.ToUpper() -ne "S") {
        Write-Host "Operação cancelada." -ForegroundColor Yellow
        Read-Host "`nPressione ENTER para voltar"
        return
    }
    try {
        netsh advfirewall set allprofiles state off 2>&1 | Out-Null
        Write-Host "☠ Firewall DESATIVADO em todos os perfis!" -ForegroundColor Red
        Write-Log "SUCESSO Firewall-Off | Tecnico: $Global:TechnicianName"
    } catch {
        Write-Host "❌ Erro ao desativar firewall: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "ERRO Firewall-Off: $($_.Exception.Message)"
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Test-SqlConnection {
    Write-Host "`nroot@kali:~# Testando conexão com SQL Server..." -ForegroundColor Green
    try {
        $query = "SELECT @@VERSION AS [SQL Server Version], DB_NAME() AS [Database]"
        $res = Run-SqlCmd -Server $Server -Database $Database -Query $query
        if ($res.ExitCode -eq 0) {
            Write-Host "`n✅ Conexão estabelecida com sucesso!" -ForegroundColor Green
            Write-Host "`n📄 Resultado:" -ForegroundColor Cyan
            Get-Content $res.OutputFile -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_ -ForegroundColor White }
            Write-Log "SUCESSO Test-SqlConnection | Tecnico: $Global:TechnicianName"
        } else {
            Write-Host "`n❌ Falha na conexão. ExitCode: $($res.ExitCode)" -ForegroundColor Red
            Write-Log "ERRO Test-SqlConnection ExitCode=$($res.ExitCode)"
        }
    } catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "ERRO Test-SqlConnection: $($_.Exception.Message)"
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

# ---------- Testes ----------
function Open-Notepad {
    Write-Host "`nroot@kali:~# Abrindo Bloco de Notas..." -ForegroundColor Green
    try {
        Start-Process notepad.exe
        Write-Log "SUCESSO Open-Notepad | Tecnico: $Global:TechnicianName"
        Write-Host "✅ Notepad iniciado." -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "ERRO Open-Notepad: $($_.Exception.Message)"
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Play-Jingle {
    param([int]$Repeat = 1)
    Write-Host "`nroot@kali:~# 🎵 Tocando musiquinha..." -ForegroundColor Green
    $melody = @(
        @{f=659; d=150}, @{f=659; d=150}, @{f=0; d=100},
        @{f=659; d=150}, @{f=0; d=100}, @{f=523; d=150},
        @{f=659; d=150}, @{f=784; d=300}, @{f=0; d=300}, @{f=392; d=300}
    )
    try {
        for ($r=1; $r -le $Repeat; $r++) {
            foreach ($note in $melody) {
                if ($note.f -gt 0) { 
                    try { [console]::beep($note.f, $note.d) } 
                    catch { Start-Sleep -Milliseconds $note.d } 
                } else { 
                    Start-Sleep -Milliseconds $note.d 
                }
            }
            if ($r -lt $Repeat) { Start-Sleep -Milliseconds 200 }
        }
        Write-Log "SUCESSO Play-Jingle Repeat=$Repeat"
        Write-Host "✅ Musiquinha tocada ($Repeat vez(es))." -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "ERRO Play-Jingle: $($_.Exception.Message)"
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Play-Click { 
    try { 
        try { [console]::Beep(1200,45) } catch { }
    } catch { }
}

function Show-SystemInfo {
    Write-Host "`nroot@kali:~# Informações do Sistema" -ForegroundColor Green
    Write-Host "`n📋 Computador: $env:COMPUTERNAME" -ForegroundColor Cyan
    Write-Host "👤 Usuário: $env:USERNAME" -ForegroundColor Cyan
    Write-Host "💻 SO: $([Environment]::OSVersion.VersionString)" -ForegroundColor Cyan
    Write-Host "🖥️ Arquitetura: $env:PROCESSOR_ARCHITECTURE" -ForegroundColor Cyan
    
    try {
        $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254\.)' } | Select-Object -First 1).IPAddress
        Write-Host "🌐 IP Principal: $ip" -ForegroundColor Cyan
    } catch {
        Write-Host "🌐 IP Principal: Não detectado" -ForegroundColor Yellow
    }
    
    Write-Host "`n📁 Pasta atual: $(Get-Location)" -ForegroundColor Cyan
    
    if (Test-Path "C:\Maqplan") {
        Write-Host "✅ Pasta C:\Maqplan: Existe" -ForegroundColor Green
    } else {
        Write-Host "❌ Pasta C:\Maqplan: NÃO encontrada" -ForegroundColor Red
    }
    
    Read-Host "`nPressione ENTER para voltar ao menu"
}

# ---------- Menu Principal ----------
while ($true) {
    Show-Banner
    Write-Host ""
    Write-Host "════════════════ MANUTENÇÃO SQL ════════════════" -ForegroundColor Cyan
    Write-Host "[1] Resetar Licenca" -ForegroundColor White
    Write-Host "[2] Integrador Vendas" -ForegroundColor White
    Write-Host "[3] Buscar e Corrigir Vendas do Dia" -ForegroundColor White
    Write-Host "[T] Testar Conexão SQL" -ForegroundColor White
    Write-Host ""
    Write-Host "═════════════════ SISTEMA ══════════════════════" -ForegroundColor Cyan
    Write-Host "[4] Excluir Chaves de Registro (Maqplan)" -ForegroundColor White
    Write-Host "[5] Permissão na Pasta C:\Maqplan" -ForegroundColor White
    Write-Host "[6] Desativar Firewall do Windows" -ForegroundColor White
    Write-Host "[I] Informações do Sistema" -ForegroundColor White
    Write-Host ""
    Write-Host "═════════════════ TESTES ═══════════════════════" -ForegroundColor Cyan
    Write-Host "[8] Abrir Bloco de Notas" -ForegroundColor DarkGray
    Write-Host "[9] Tocar Musiquinha 🎵" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "[0] Sair" -ForegroundColor Red
    Write-Host ""
    $choice = Read-Host "Escolha uma opcao"

    Play-Click

    switch ($choice.ToUpper()) {
        "1" { Reset-Licenca }
        "2" { Integrador-Vendas }
        "3" { $sd = Read-Host "Digite a data (YYYY-MM-DD)"; Search-VendasByDate -StartDate $sd }
        "4" { Excluir-Regedit }
        "5" { Permissao-Maqplan }
        "6" { Desativar-Firewall }
        "7" { Start-TeamViewerVPNRemote }
        "8" { Open-Notepad }
        "9" {
            $times = Read-Host "Quantas vezes tocar a musiquinha? (padrão 1)"
            if (-not [int]::TryParse($times,[ref]$null)) { $times = 1 }
            Play-Jingle -Repeat $times
        }
        "A" {
            $cmd = Read-Host "Informe o comando a executar no remoto (ex: hostname & ipconfig /all)"
            if (-not [string]::IsNullOrWhiteSpace($cmd)) { Execute-RemoteCommand -Command $cmd }
        }
        "0" { break }
        default {
            Write-Host "Opcao inválida." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}

Write-Host "`nSaindo..." -ForegroundColor Red
Write-Log "SAIDA do script"