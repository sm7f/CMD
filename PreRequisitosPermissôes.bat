echo off
taskkill /f /im PoliSystemPDV.exe
taskkill /f /im PoliSystemADM.exe
taskkill /f /im MSNFe.exe
taskkill /f /im Integrador.exe

taskkill /f /im PDV.exe
sc stop MSSQLSERVER
sc start MSSQLSERVER
EXEC sp_detach_db 'PoliSystemServerSQLDB'

C:\Maqplan\Arquivos\BancoDados.ini
C:\Maqplan\Arquivos\Config.ini
C:\Maqplan\BancoDados
C:\Maqplan
C:\Users

netsh advfirewall set allprofiles state off

Enable-WindowsOptionalFeature -Online -FeatureName NetFx3,NetFx4-AdvSrvs,NetFx4Extended-ASPNET45,WCF-HTTP-Activation45,WCF-NonHTTP-Activation,WCF-MSMQ-Activation45,WCF-TCP-Activation45,WCF-Pipe-Activation45 -all

REG ADD "HKCU\SOFTWARE\VB and VBA Program Settings\Psylicn\Controle" /v CdEmpCntCtr /d 2001
Computador\HKEY_CLASSES_ROOT\VirtualStore\MACHINE\SOFTWARE\WOW6432Node\_Maqplan Software

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

icacls "C:\Maqplan" /grant "Todos":(OI)(CI)F /t /c
icacls "C:\MSoftware" /grant "Todos":(OI)(CI)F /t /c
icacls "C:\MaqplanNFe" /grant "Todos":(OI)(CI)F /t /c

PowerShell
Get-Printer
Remove-Printer -Name "Nome da Impressora"



C:\Users\Maqplan\AppData\Local\MicroSIP\microsip.exe

