icacls "C:\Maqplan" /grant "Todos":(OI)(CI)F /t /c

icacls "C:\MSoftware" /grant "Todos":(OI)(CI)F /t /c

icacls "C:\MaqplanNFe" /grant "Todos":(OI)(CI)F /t /c

C:\Maqplan\Arquivos\BancoDados

netsh advfirewall set allprofiles state off

REG ADD "HKCU\SOFTWARE\VB and VBA Program Settings\Psylicn\Controle" /v CdEmpCntCtr /d 12014

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
