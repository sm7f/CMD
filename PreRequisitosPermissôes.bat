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

REG ADD "HKCU\SOFTWARE\VB and VBA Program Settings\Psylicn\Controle" /v CdEmpCntCtr /d 3663
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

echo off
reg add hklm\system\currentcontrolset\services\lanmanserver\parameters /v OptionalNames /t REG_SZ /d "aliasname"
reg add hklm\system\currentcontrolset\control\print /v DnsOnWire /t REG_DWORD /d 1
reg add hklm\system\currentcontrolset\services\lanmanserver\parameters /v DisableStrictNameChecking /t REG_DWORD /d 1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\Client Side Rendering Print Provider" /v InactiveGuidPrinterAge /t REG_DWORD /d 1200
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\Client Side Rendering Print Provider" /v InactiveGuidPrinterTrim /t REG_DWORD /d 3600

echo off
net stop spooler
net start spooler