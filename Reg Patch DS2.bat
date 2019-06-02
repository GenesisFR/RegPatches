@echo off

title Reg Patcher for Dungeon Siege 2 by Genesis (v1.0)

rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct current directory when a script is run as admin
@setlocal enableextensions
@cd /d "%~dp0"

rem https://ss64.com/nt/syntax-64bit.html
echo Detecting OS bitness...
set _OS_BITNESS=64
if %PROCESSOR_ARCHITECTURE% == x86 (
    if not defined PROCESSOR_ARCHITEW6432 set _OS_BITNESS=32
)

echo Your OS is %_OS_BITNESS%-bit.
echo.

rem Shortcuts for registry keys
set _2K_BW="HKLM\Software\2K Games\Dungeon Siege 2 Broken World"
set _GPG_BW="HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000"
set _MS_DS2="HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2"

echo Adding registry entries for Dungeon Siege 2...

REG ADD %_MS_DS2% /v "AppPath" /t REG_SZ /d "%cd%" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "CDPath" /t REG_SZ /d "E:\\" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "DistroID" /t REG_DWORD /d "0x0000047c" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "DoubleHash" /t REG_BINARY /d "704f25e4d2b1f8ea" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "InstallationDirectory" /t REG_SZ /d "%cd%" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "InstalledGroup" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "LangID" /t REG_DWORD /d "9" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "Launched" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "PID" /t REG_SZ /d "77033-133-5335624-40332" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "Version" /t REG_SZ /d "2" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "VersionType" /t REG_SZ /d "RetailVersion" /f /reg:32 > nul

echo DONE
echo.

echo Adding registry entries for Dungeon Siege 2: Broken World...

REG ADD %_2K_BW% /v "DistroID" /t REG_DWORD /d "0x0000047c" /f /reg:32 > nul
REG ADD %_2K_BW% /v "InstalledGroup" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD %_2K_BW% /v "PID" /t REG_SZ /d "0204-993D-D268-A1E2" /f /reg:32 > nul

REG ADD %_GPG_BW% /v "DisplayIcon" /t REG_SZ /d "%cd%\DungeonSiege2.exe" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "DisplayName" /t REG_SZ /d "Dungeon Siege 2 Broken World" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "DisplayVersion" /t REG_SZ /d "1.00.0000" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "InstallDate" /t REG_SZ /d "20180204" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "InstallLocation" /t REG_SZ /d "%cd%" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "Language" /t REG_DWORD /d "9" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "LogMode" /t REG_DWORD /d "1" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "MajorVersion" /t REG_DWORD /d "1" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "MinorVersion" /t REG_DWORD /d "0" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "NoModify" /t REG_DWORD /d "1" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "NoRemove" /t REG_DWORD /d "0" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "NoRepair" /t REG_DWORD /d "1" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "ProductGuid" /t REG_SZ /d "{A563C4F4-BE36-4956-BA0B-E02BDD9F70D5}" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "Publisher" /t REG_SZ /d "Gas Powered Games" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "RegOwner" /t REG_SZ /d "Killah" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "URLInfoAbout" /t REG_SZ /d "http://www.gaspowered.com" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "Version" /t REG_DWORD /d "0x01000000" /f /reg:32 > nul

echo DONE
echo.

pause
endlocal
