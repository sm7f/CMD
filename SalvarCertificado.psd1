# Listar todos os certificados no repositório do usuário atual (CurrentUser\My)
$currentUserCertificates = Get-ChildItem -Path Cert:\CurrentUser\My

# Listar todos os certificados no repositório de máquina local (LocalMachine\My)
$localMachineCertificates = Get-ChildItem -Path Cert:\LocalMachine\My

# Caminho da pasta da área de trabalho
$desktopFolderPath = [Environment]::GetFolderPath("Desktop")

# Senha para proteger os certificados exportados
$exportPassword = ConvertTo-SecureString -String "123456" -AsPlainText -Force

# Função para exportar o certificado com senha para a área de trabalho
function Export-CertificateToDesktopWithPassword($certificate) {
    $outputFileName = Join-Path -Path $desktopFolderPath -ChildPath "$($certificate.Subject).pfx"
    Export-PfxCertificate -Cert $certificate -FilePath $outputFileName -Password $exportPassword
    Write-Host "Certificado exportado para $outputFileName com senha."
}

# Exportar os certificados do usuário atual para a área de trabalho
foreach ($cert in $currentUserCertificates) {
    Export-CertificateToDesktopWithPassword $cert
}

# Exportar os certificados da máquina local para a área de trabalho
foreach ($cert in $localMachineCertificates) {
    Export-CertificateToDesktopWithPassword $cert
}
