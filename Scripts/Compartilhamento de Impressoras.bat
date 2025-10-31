@echo off
setlocal EnableDelayedExpansion
title COMPARTILHAMENTO DE IMPRESSORAS
color 0B

echo ===========================================
echo  CONFIGURACAO DE IMPRESSORAS
echo ===========================================

:: 1. Habilita compartilhamento de arquivos e impressoras no firewall
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

:: 2. Compartilha pastas de spool e drivers
set SHARELIST=^
PrintersSpool|%windir%\System32\spool\PRINTERS;^
PrintersDrivers|%windir%\System32\spool\drivers

for %%I in (%SHARELIST%) do (
  for /f "tokens=1,2 delims=|" %%A in ("%%~I") do (
    set "SHARENAME=%%~A"
    set "SHAREPATH=%%~B"
    set "SHAREPATH=!SHAREPATH:;=!"

    if exist "!SHAREPATH!" (
      net share "!SHARENAME!" /delete >nul 2>&1
      net share "!SHARENAME!=!SHAREPATH!" /GRANT:Everyone,FULL
      echo Compartilhamento criado: !SHARENAME! -> !SHAREPATH!
      ICACLS "!SHAREPATH!" /grant "Everyone:(OI)(CI)(F)" /T /C >nul 2>&1
    ) else (
      echo Caminho nao encontrado: !SHAREPATH!
    )
  )
)

echo ===========================================
echo  IMPRESSORAS COMPARTILHADAS COM SUCESSO
echo ===========================================
pause
endlocal
