Abrir no PowerShell:
DISM /Online /Add-Capability /CapabilityName:Language.Basic~~~pt-BR~0.0.1.0

Opcional:
DISM /Online /Add-Capability /CapabilityName:Language.Handwriting~~~pt-BR~0.0.1.0
DISM /Online /Add-Capability /CapabilityName:Language.OCR~~~pt-BR~0.0.1.0
DISM /Online /Add-Capability /CapabilityName:Language.Speech~~~pt-BR~0.0.1.0

Verificar se está disponivel: Abra o CMD(Administrador) Execute:
DISM /Online /Get-Capabilities | findstr "Language"

Para confirmar se Português (Brasil) está instalado, use:
DISM /Online /Get-Capabilities | findstr "pt-BR"

Verificar o idioma atual do sistema (PowerShell):
Get-WinUserLanguageList
  
Outra opção:
Get-WinUILanguageOverride

(Powershell)
Se o idioma estiver instalado, mas o sistema ainda não estiver em Português (Brasil), defina como padrão com:
Set-WinUserLanguageList pt-BR -Force
Set-WinUILanguageOverride -Language pt-BR

Reinicar o computador após executar os comandos. 


Caso não mude, vai em pesquisar, digite "Language" ira aparecer as configurações de linguagem, dessa forma você define a linguagem PT-BR
Após deixar tudo em PT-BR reinicie o computador.

