"Fechar Sistema Plus"
cmd /c "taskkill /f /im PoliSystemPDV.exe & taskkill /f /im PoliSystemADM.exe & taskkill /f /im MSNFE.exe & taskkill /f /im Integrador.exe"

"Fechar Sistema One"
cmd /c "taskkill /f /im PDV.exe & taskkill /f /im Agente.Sicronizacao.exe"

sc stop MSSQLSERVER
sc start MSSQLSERVER

"Desataxa
EXEC sp_detach_db 'PoliSystemServerSQLDB'

"Atacha PowerShell"
$DBNAME="PoliSystemServerSQLDB"; if ((sqlcmd -S . -U sa -P PoliSystemsapwd -h -1 -Q "SET NOCOUNT ON; IF EXISTS (SELECT name FROM sys.databases WHERE name=N'$DBNAME') PRINT 'EXISTS' ELSE PRINT 'NOTEXISTS'") -match "EXISTS") { Write-Host "⚠️  O banco $DBNAME já está anexado" -ForegroundColor Yellow } else { if (Test-Path "C:\Maqplan\BancoDados\$DBNAME.mdf") { sqlcmd -S . -U sa -P PoliSystemsapwd -Q "EXEC sp_attach_db @dbname=N'$DBNAME', @filename1=N'C:\Maqplan\BancoDados\$DBNAME.mdf', @filename2=N'C:\Maqplan\BancoDados\${DBNAME}_log.LDF'" } elseif (Test-Path "C:\Maqplan\BancoDados\${DBNAME}_Data.mdf") { sqlcmd -S . -U sa -P PoliSystemsapwd -Q "EXEC sp_attach_db @dbname=N'$DBNAME', @filename1=N'C:\Maqplan\BancoDados\${DBNAME}_Data.mdf', @filename2=N'C:\Maqplan\BancoDados\${DBNAME}_log.LDF'" } }; if ($LASTEXITCODE -eq 0) { $empresa=(sqlcmd -S . -U sa -P PoliSystemsapwd -d $DBNAME -h -1 -W -Q "SET NOCOUNT ON; SELECT NomeEmpresa FROM EMPRESA WHERE CdEmpresa=1").Trim(); $cnpj=(sqlcmd -S . -U sa -P PoliSystemsapwd -d $DBNAME -h -1 -W -Q "SET NOCOUNT ON; SELECT CNPJEmpresa FROM EMPRESA WHERE CdEmpresa=1").Trim(); $versao=(sqlcmd -S . -U sa -P PoliSystemsapwd -d $DBNAME -h -1 -W -Q "SET NOCOUNT ON; SELECT TOP 1 NrVersaoSistemaInstalado FROM VERSAO_SISTEMA").Trim(); Write-Host "✅ Banco $DBNAME pronto → Empresa: $empresa | CNPJ: $cnpj | Versão: $versao" -ForegroundColor Green } else { Write-Host "❌ ERRO ao anexar o banco $DBNAME" -ForegroundColor Red }

"Netframework"
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3,NetFx4-AdvSrvs,NetFx4Extended-ASPNET45,WCF-HTTP-Activation45,WCF-NonHTTP-Activation,WCF-MSMQ-Activation45,WCF-TCP-Activation45,WCF-Pipe-Activation45 -all

"Zera Licença"
sqlcmd -S . -Q "USE PoliSystemServerSQLDB; UPDATE CONFIG_GERAL_SYS SET NrSerieLicenca = '-1', BloqLicenca = '-1';"

"Integrador Vendas"
sqlcmd -S . -Q "USE PoliSystemServerSQLDB; update venda set statusexportacao = 1;"

C:\MSoftware
C:\Maqplan\Arquivos\BancoDados.ini
C:\Maqplan\Arquivos\Config.ini
C:\Maqplan\BancoDados
C:\Maqplan

"WIN 11 Impressoras"
explorer shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}

"Firewall"
netsh advfirewall set allprofiles state off

"REDE"
control /name Microsoft.NetworkAndSharingCenter

"SCI"
REG ADD "HKCU\SOFTWARE\VB and VBA Program Settings\Psylicn\Controle" /v CdEmpCntCtr /d 10600

"Local Regedit"
Computador\HKEY_CLASSES_ROOT\VirtualStore\MACHINE\SOFTWARE\WOW6432Node\_Maqplan Software

"Excluir Regedit"
$regKeys = @(
    "HKLM:\SOFTWARE\_Maqplan Software",
    "HKLM:\SOFTWARE\WOW6432Node\_Maqplan Software",
    "HKLM:\SOFTWARE\WOW6432Node\Maqplan"
)
foreach ($key in $regKeys) {
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force
        Write-Output "A chave de registro '$key' foi removida."
    } else {
        Write-Output "A chave de registro '$key' não foi encontrada."
    }
}

"Permissão"
icacls "C:\Maqplan" /grant "Todos":(OI)(CI)F /t /c
icacls "C:\MaqplanNFe" /grant "Todos":(OI)(CI)F /t /c
icacls "C:\MSoftware" /grant "Todos":(OI)(CI)F /t /c
icacls "Program Files\PostgreSQL" 
icacls "C:\Client TEF" /grant "Todos":(OI)(CI)F /t /c

PowerShell
Get-Printer
Remove-Printer -Name "MP-4200 TH"

"Teste Ping"
nfce.svrs.rs.gov.br

C:\Users\Maqplan\AppData\Local\MicroSIP\microsip.exe

"Bloqueio Postgres"
host    all             all             fe80::/10               md5

"Pasta"
New-Item -ItemType Directory -Path ''

"Arquivos"
New-Item -ItemType File -Path

Validar Dominio
nslookup nfe.sefazvirtual.rs.gov.br
nslookup portal.maqplan.com.br

Rastrear Rota
tracert nfe.sefazvirtual.rs.gov.br
tracert portal.maqplan.com.br
tracert directdrive.maqplan.com.br
Get-WHOIS -Domain portal.maqplan.com.br


"Liberar Porta Entrada"
New-NetFirewallRule -DisplayName "Allow TCP 1230" -Direction Inbound -Protocol TCP -LocalPort 1230 -Action Allow

"Liberar Porta Sainda"
New-NetFirewallRule -DisplayName "Allow Outbound TCP 1230" -Direction Outbound -Protocol TCP -LocalPort 1230 -Action Allow

"Liberar o PowerShell WIN11"
Get-ExecutionPolicy -List
Set-ExecutionPolicy Unrestricted -Scope LocalMachine
Set-ExecutionPolicy Unrestricted -Scope Process

"Validar porta"
function Invoke-PortScan {
    param([string]$target, [int[]]$ports)
    foreach ($port in $ports) {
        $test = Test-NetConnection -ComputerName $target -Port $port -InformationLevel Quiet
        if ($test) {
            Write-Host "Port $port is open on $target"
        } else {
            Write-Host "Port $port is closed on $target"
        }
    }
}
Invoke-PortScan -target "10.0.0.109" -ports @(80,1433,443,1230)

function Invoke-PingSweep {
    param([string]$subnet)
    1..254 | ForEach-Object { Test-Connection -ComputerName "$subnet.$_" -Count 1 -ErrorAction SilentlyContinue }
}
Invoke-PingSweep -subnet "192.168.0.15"

Get-computerInfo


Adicionar ADM
net user administrator /active:yes

Atualizar drivers
pnputil /scan-devices
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Force -AllowClobber
Import-Module PSWindowsUpdate
Get-WindowsUpdate
Get-WindowsUpdate -Install -MicrosoftUpdate -IgnoreReboot


"Instalar o Basic"
Invoke-WebRequest "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile "$env:TEMP\vc_redist.x64.exe"; Start-Process "$env:TEMP\vc_redist.x64.exe" -ArgumentList "/install","/quiet","/norestart" -Wait; Remove-Item "$env:TEMP\vc_redist.x64.exe"; Write-Host "`n✅ Visual C++ Redistributable x64 instalado com sucesso!"

parcerias.maq@maqplan.com.br
$UQK*5H6RFnpdF7
 