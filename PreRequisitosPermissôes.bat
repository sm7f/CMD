icacls "C:\Maqplan" /grant "Todos":(OI)(CI)F /t /c

icacls "C:\MSoftware" /grant "Todos":(OI)(CI)F /t /c

icacls "C:\MaqplanNFe" /grant "Todos":(OI)(CI)F /t /c

netsh advfirewall set allprofiles state off