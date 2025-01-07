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
"Sincroniza"
sqlcmd -S . -Q "USE PoliSystemServerSQLDB; UPDATE NFE SET StatusNFEEnviadaServidor = 1 WHERE StatusNFEEnviadaServidor = 0; UPDATE NFE SET StatusEmailEnviado = 1 WHERE StatusEmailEnviado = 0; UPDATE NFE SET STATUSANDAMENTO = 'NN' WHERE STATUSANDAMENTO = 'NV'; UPDATE NFE SET StatusEmailEnviado = 1; UPDATE NFE SET StatusXMLEnviadoFtp = 1; UPDATE NFE SET StatusNFEEnviadaServidor = 1; UPDATE NFE SET StatusEnvioEmailXMLCancelamento = 1; UPDATE NFE SET StatusXMLCancelamentoFTP = 1; UPDATE NFE SET StatusNFEEnviadaServidor = 1; UPDATE NFE_cce SET StatusEmailEnviadoCCe = 1; UPDATE NFE_cce SET StatusEnvioXMLCCeFTP = 1; UPDATE NFE_cce SET StatusEnviadaServidorNFE = 1;"
"Integrador Vendas"
sqlcmd -S . -Q "USE PoliSystemServerSQLDB; update venda set statusexportacao = 1;"

C:\MSoftware
C:\Maqplan\Arquivos\BancoDados.ini
C:\Maqplan\Arquivos\Config.ini
C:\Maqplan\BancoDados
C:\Maqplan
C:\UsersDESKTOP-BFOQVU2

"Firewall"
netsh advfirewall set allprofiles state off

USER05-PC
"Netframework"
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3,NetFx4-AdvSrvs,NetFx4Extended-ASPNET45,WCF-HTTP-Activation45,WCF-NonHTTP-Activation,WCF-MSMQ-Activation45,WCF-TCP-Activation45,WCF-Pipe-Activation45 -all

"SCI"
REG ADD "HKCU\SOFTWARE\VB and VBA Program Settings\Psylicn\Controle" /v CdEmpCntCtr /d 12051

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

icacls "C:\MaqplanNFe" /grant "Todos":(OI)(CI)F /t /c

DICASA-CAIXA

92991023446