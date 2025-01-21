"Fechar Sistema Plus"
cmd /c "taskkill /f /im PoliSystemPDV.exe & taskkill /f /im PoliSystemADM.exe & taskkill /f /im MSNFE.exe & taskkill /f /im Integrador.exe"

"Fechar Sistema One"
cmd /c "taskkill /f /im PDV.exe & taskkill /f /im Agente.Sicronizacao.exe"


sc stop MSSQLSERVER
sc start MSSQLSERVER

"Desataxa
EXEC sp_detach_db 'PoliSystemServerSQLDB'

"Atacha"
EXEC sp_attach_db @dbname = N'PoliSystemServerSQLDB', @filename1 = N'C:\Maqplan\BancoDados\PoliSystemServerSQLDB.mdf', @filename2 = N'C:\Maqplan\BancoDados\PoliSystemServerSQLDB_log.LDF'
EXEC sp_attach_db @dbname = N'PoliSystemServerSQLDB', @filename1 = N'C:\Maqplan\BancoDados\PoliSystemServerSQLDB_Data.mdf', @filename2 = N'C:\Maqplan\BancoDados\PoliSystemServerSQLDB_log.LDF'

"Zera Licença"
sqlcmd -S . -Q "USE PoliSystemServerSQLDB; UPDATE CONFIG_GERAL_SYS SET NrSerieLicenca = '-1', BloqLicenca = '-1';"
"Integrador Vendas"
sqlcmd -S . -Q "USE PoliSystemServerSQLDB; update venda set statusexportacao = 1;"

C:\MSoftware
C:\Maqplan\Arquivos\BancoDados.ini
C:\Maqplan\Arquivos\Config.ini
C:\Maqplan\BancoDados
C:\Maqplan

"Firewall"
netsh advfirewall set allprofiles state off

USER05-PC
"Netframework"
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3,NetFx4-AdvSrvs,NetFx4Extended-ASPNET45,WCF-HTTP-Activation45,WCF-NonHTTP-Activation,WCF-MSMQ-Activation45,WCF-TCP-Activation45,WCF-Pipe-Activation45 -all

"SCI"
REG ADD "HKCU\SOFTWARE\VB and VBA Program Settings\Psylicn\Controle" /v CdEmpCntCtr /d 9802

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
Remove-Printer -Name "ELGIN i9(USB)"

DESKTOP-3AKSLVP

\\DESKTOP-3AKSLVP\TM-T20

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
Get-WHOIS -Domain portal.maqplan.com.br


"Liberar Porta Entrada"
New-NetFirewallRule -DisplayName "Allow TCP 1230" -Direction Inbound -Protocol TCP -LocalPort 1230 -Action Allow

"Liberar Porta Sainda"
New-NetFirewallRule -DisplayName "Allow Outbound TCP 1230" -Direction Outbound -Protocol TCP -LocalPort 1230 -Action Allow

Liberar o PowerShell WIN11
Get-ExecutionPolicy -List
Set-ExecutionPolicy Unrestricted -Scope LocalMachine
Set-ExecutionPolicy Unrestricted -Scope Process
