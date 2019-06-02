@echo off

title Reg Patcher for Dungeon Siege 2 by Genesis (v1.0)

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
echo Adding registry entries for Dungeon Siege 2...

REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "AppPath" /t REG_SZ /d "%cd%" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "CDPath" /t REG_SZ /d "E:\\" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "DistroID" /t REG_DWORD /d "0x0000047c" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "DoubleHash" /t REG_BINARY /d "704f25e4d2b1f8ea" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "InstallationDirectory" /t REG_SZ /d "%cd%" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "InstalledGroup" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "LangID" /t REG_DWORD /d "9" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "Launched" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "PID" /t REG_SZ /d "77033-133-5335624-40332" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "Version" /t REG_SZ /d "2" /f /reg:32 > nul
REG ADD "HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2" /v "VersionType" /t REG_SZ /d "RetailVersion" /f /reg:32 > nul

echo DONE
echo.

echo Adding registry entries for Dungeon Siege 2: Broken World...

REG ADD "HKLM\Software\2K Games\Dungeon Siege 2 Broken World" /v "DistroID" /t REG_DWORD /d "0x0000047c" /f /reg:32 > nul
REG ADD "HKLM\Software\2K Games\Dungeon Siege 2 Broken World" /v "InstalledGroup" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\2K Games\Dungeon Siege 2 Broken World" /v "PID" /t REG_SZ /d "0204-993D-D268-A1E2" /f /reg:32 > nul

REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "DisplayIcon" /t REG_SZ /d "%cd%\DungeonSiege2.exe" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "DisplayName" /t REG_SZ /d "Dungeon Siege 2 Broken World" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "DisplayVersion" /t REG_SZ /d "1.00.0000" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "InstallDate" /t REG_SZ /d "20180204" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "InstallLocation" /t REG_SZ /d "%cd%" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "Language" /t REG_DWORD /d "9" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "LogMode" /t REG_DWORD /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "MajorVersion" /t REG_DWORD /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "MinorVersion" /t REG_DWORD /d "0" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "NoModify" /t REG_DWORD /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "NoRemove" /t REG_DWORD /d "0" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "NoRepair" /t REG_DWORD /d "1" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "ProductGuid" /t REG_SZ /d "{A563C4F4-BE36-4956-BA0B-E02BDD9F70D5}" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "Publisher" /t REG_SZ /d "Gas Powered Games" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "RegOwner" /t REG_SZ /d "Killah" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "URLInfoAbout" /t REG_SZ /d "http://www.gaspowered.com" /f /reg:32 > nul
REG ADD "HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000" /v "Version" /t REG_DWORD /d "0x01000000" /f /reg:32 > nul

echo DONE
echo.

pause
endlocal