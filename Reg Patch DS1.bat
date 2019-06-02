@echo off

title Reg Patcher for Dungeon Siege 1 by Genesis (v1.0)

rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct current directory when a script is run as admin
@setlocal enableextensions
@cd /d "%~dp0"

rem https://ss64.com/nt/syntax-64bit.html
echo Detecting OS bitness...
set _os_bitness=64
if %PROCESSOR_ARCHITECTURE% == x86 (
    if not defined PROCESSOR_ARCHITEW6432 set _os_bitness=32
)

echo Your OS is %_os_bitness%-bit.
echo.
echo Adding registry entries for Dungeon Siege...

REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege\1.0" /v "EXE Path" /t REG_SZ /d "%cd%" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege\1.0" /v "PID" /t REG_SZ /d "75165-442-1792475-18588" /f /reg:32 > nul

echo DONE
echo.

echo Adding registry entries for Dungeon Siege: Legends of Aranna...
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "CDPath" /t REG_SZ /d "E:\\" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "DigitalProductID" /t REG_BINARY /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "EXE Path" /t REG_SZ /d "%cd%" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "InstalledGroup" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "LangID" /t REG_DWORD /d "9" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "Launched" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "PID" /t REG_SZ /d "75165-442-1792475-18588" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "Version" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "VersionType" /t REG_SZ /d "RetailVersion" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0" /v "Zone" /t REG_SZ /d "http://www.zone.com/asp/script/Default.asp?Game=GenericSetup&password=Password" /f /reg:32 > nul

echo DONE
echo.

pause
endlocal