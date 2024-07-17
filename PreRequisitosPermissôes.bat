icacls "C:\Maqplan" /grant "Todos":(OI)(CI)F /t /c
icacls "C:\MSoftware" /grant "Todos":(OI)(CI)F /t /c
icacls "C:\MaqplanNFe" /grant "Todos":(OI)(CI)F /t /c

echo off
taskkill /f /im PoliSystemPDV.exe
taskkill /f /im PoliSystemADM.exe
taskkill /f /im MSNFe.exe

taskkill /f /im PDV.exe
sc stop MSSQLSERVER
sc start MSSQLSERVER

C:\Maqplan\Arquivos\BancoDados.ini
C:\Maqplan\Arquivos\Config.ini
C:\Maqplan\BancoDados
C:\Maqplan
C:\Users

netsh advfirewall set allprofiles state off

REG ADD "HKCU\SOFTWARE\VB and VBA Program Settings\Psylicn\Controle" /v CdEmpCntCtr /d 8384

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