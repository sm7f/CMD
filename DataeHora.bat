@echo off
:: Define a nova data e hora (ajuste de acordo com a necessidade)
set nova_data=12/09/2024
set novo_horario=9:49:00

:: Define o novo fuso horário (ajuste de acordo com a necessidade)
set novo_fuso=-03:00

:: Define a data e hora atual do computador
for /f "tokens=2" %%i in ('wmic os get localdatetime ^| findstr /r /c:"^[0-9]"') do set atual_data_hora=%%i

:: Define a data atual
set atual_data=%atual_data_hora:~6,2%/%atual_data_hora:~4,2%/%atual_data_hora:~0,4%

:: Define a hora atual
set atual_hora=%atual_data_hora:~8,2%:%atual_data_hora:~10,2%:%atual_data_hora:~12,2%

:: Define o fuso horário atual
for /f "tokens=2 delims==" %%x in ('wmic timezone get /value') do set %%x
set atual_fuso=%Bias%

:: Corrige a data
if not "%atual_data%"=="%nova_data%" (
    echo Corrigindo data...
    date %nova_data%
)

:: Corrige a hora
if not "%atual_hora%"=="%novo_horario%" (
    echo Corrigindo hora...
    time %novo_horario%
)

:: Corrige o fuso horário
if not "%atual_fuso%"=="%novo_fuso%" (
    echo Corrigindo fuso horário...
    tzutil.exe /s "%novo_fuso%"
)