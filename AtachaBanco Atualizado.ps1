$DBNAME = "PoliSystemServerSQLDB"

# Verifica se o banco já está anexado
$check = sqlcmd -S . -U sa -P "PoliSystemsapwd" -h -1 -Q "SET NOCOUNT ON; IF EXISTS (SELECT name FROM sys.databases WHERE name = N'$DBNAME') PRINT 'EXISTS' ELSE PRINT 'NOTEXISTS'"

if ($check -match "EXISTS") {
    Write-Host "⚠️  O banco $DBNAME já está anexado" -ForegroundColor Yellow
}
else {
    # Verifica os caminhos possíveis
    $path1 = "C:\Maqplan\BancoDados\$DBNAME.mdf"
    $path2 = "C:\Maqplan\BancoDados\${DBNAME}_Data.mdf"
    $log   = "C:\Maqplan\BancoDados\${DBNAME}_log.LDF"

    if (Test-Path $path1) {
        sqlcmd -S . -U sa -P "PoliSystemsapwd" -Q "EXEC sp_attach_db @dbname = N'$DBNAME', @filename1 = N'$path1', @filename2 = N'$log'"
    }
    elseif (Test-Path $path2) {
        sqlcmd -S . -U sa -P "PoliSystemsapwd" -Q "EXEC sp_attach_db @dbname = N'$DBNAME', @filename1 = N'$path2', @filename2 = N'$log'"
    }
    else {
        Write-Host "❌ Arquivos MDF não encontrados em C:\Maqplan\BancoDados" -ForegroundColor Red
        exit
    }

    if ($LASTEXITCODE -eq 0) {
        $empresa = (sqlcmd -S . -U sa -P "PoliSystemsapwd" -d $DBNAME -h -1 -W -Q "SET NOCOUNT ON; SELECT NomeEmpresa FROM EMPRESA WHERE CdEmpresa = 1").Trim()
        $cnpj    = (sqlcmd -S . -U sa -P "PoliSystemsapwd" -d $DBNAME -h -1 -W -Q "SET NOCOUNT ON; SELECT CNPJEmpresa FROM EMPRESA WHERE CdEmpresa = 1").Trim()
        $versao  = (sqlcmd -S . -U sa -P "PoliSystemsapwd" -d $DBNAME -h -1 -W -Q "SET NOCOUNT ON; SELECT TOP 1 NrVersaoSistemaInstalado FROM VERSAO_SISTEMA").Trim()
        
        Write-Host "✅ Banco $DBNAME pronto → Empresa: $empresa | CNPJ: $cnpj | Versão: $versao" -ForegroundColor Green
    }
    else {
        Write-Host "❌ ERRO ao anexar o banco $DBNAME" -ForegroundColor Red
    }
}
