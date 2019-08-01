@echo off

title Reg Patcher for Dungeon Siege 2 by Genesis (v1.3)

rem https://ss64.com/vb/syntax-elevate.html
echo Checking if the script is run as admin...

fsutil dirty query %SYSTEMDRIVE% > nul

if %ERRORLEVEL%% == 0 (
    echo OK
) else (
    echo ERROR: admin rights not detected.
    echo.
    echo The script will now restart as admin.

    echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\ElevateMe.vbs"
    echo UAC.ShellExecute """%~s0""", "", "", "runas", 1 >> "%TEMP%\ElevateMe.vbs"

    "%TEMP%\ElevateMe.vbs"
    del "%TEMP%\ElevateMe.vbs"
    
    exit /B
)

echo.

rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct current directory when a script is run as admin
@setlocal enableextensions
@cd /d "%~dp0"

rem https://ss64.com/nt/syntax-64bit.html
echo Detecting OS bitness...
set _OS_BITNESS=64
set _PROGRAM_FILES=%PROGRAMFILES(X86)%

if %PROCESSOR_ARCHITECTURE% == x86 (
    if not defined PROCESSOR_ARCHITEW6432 (
        set _OS_BITNESS=32
        set _PROGRAM_FILES=%PROGRAMFILES%
    )
)

echo Your OS is %_OS_BITNESS%-bit.
echo.

rem Shortcuts for registry keys
set _2K_BW="HKLM\Software\2K Games\Dungeon Siege 2 Broken World"
set _GPG_BW_BASE="HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World"
set _GPG_BW="HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000"
set _MS_DS2="HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2"

echo Please make a selection:
echo.
echo 1. Add registry entries for Dungeon Siege 2 (needed for BW, Elys DS2 and the DS2 Tool Kit)
echo 2. Add registry entries for Dungeon Siege 2 Broken World (needed for Elys DS2BW)
echo 3. Create a directory junction in Program Files (useful for GameRanger)
echo 4. Remove registry entries for both games
echo.
echo Note: if you're not sure which option to select, just press 1.
echo.
choice /c 1234 /N

IF %ERRORLEVEL% == 1 goto DS2
IF %ERRORLEVEL% == 2 goto DS2BW
IF %ERRORLEVEL% == 3 goto junction
IF %ERRORLEVEL% == 4 goto cleanup

:DS2
echo Adding registry entries for Dungeon Siege 2...

REG ADD %_MS_DS2% /v "AppPath" /t REG_SZ /d "%CD%" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "CDPath" /t REG_SZ /d "E:\\" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "DistroID" /t REG_DWORD /d "0x0000047c" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "DoubleHash" /t REG_BINARY /d "704f25e4d2b1f8ea" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "InstallationDirectory" /t REG_SZ /d "%CD%" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "InstalledGroup" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "LangID" /t REG_DWORD /d "9" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "Launched" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "PID" /t REG_SZ /d "77033-133-5335624-40332" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "Version" /t REG_SZ /d "2" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "VersionType" /t REG_SZ /d "RetailVersion" /f /reg:32 > nul

echo DONE
goto end

:DS2BW
echo Adding registry entries for Dungeon Siege 2: Broken World...

REG ADD %_2K_BW% /v "AppPath" /t REG_SZ /d "%CD%" /f /reg:32 > nul
REG ADD %_2K_BW% /v "DistroID" /t REG_DWORD /d "0x0000047c" /f /reg:32 > nul
REG ADD %_2K_BW% /v "InstallationDirectory" /t REG_SZ /d "%CD%" /f /reg:32 > nul
REG ADD %_2K_BW% /v "InstalledGroup" /t REG_SZ /d "1" /f /reg:32 > nul
REG ADD %_2K_BW% /v "PID" /t REG_SZ /d "0204-993D-D268-A1E2" /f /reg:32 > nul

REG ADD %_GPG_BW% /v "DisplayIcon" /t REG_SZ /d "%CD%\DungeonSiege2.exe" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "DisplayName" /t REG_SZ /d "Dungeon Siege 2 Broken World" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "DisplayVersion" /t REG_SZ /d "1.00.0000" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "InstallDate" /t REG_SZ /d "20180204" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "InstallLocation" /t REG_SZ /d "%CD%" /f /reg:32 > nul
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
goto end

:junction
rem https://stackoverflow.com/a/8071683
rem Get the current directory name
for %%a in (.) do set _CURRENT_DIRECTORY=%%~nxa

if exist "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" rmdir /Q "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" > nul
mklink /J "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" "%CD%"

IF %ERRORLEVEL% == 0 (
    echo.
    echo You can now select the game's executable from "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" to add the game to GameRanger.
    echo.
    echo Warning: do NOT move the directory junction somewhere else as it will also move your entire game directory!
    echo If can safely be renamed or deleted though.
)

goto end

:cleanup
echo Removing registry entries for Dungeon Siege 2...
REG DELETE %_MS_DS2% /f /reg:32 > nul
echo DONE
echo.

echo Removing registry entries for Dungeon Siege 2: Broken World...
REG DELETE %_2K_BW% /f /reg:32 > nul
REG DELETE %_GPG_BW_BASE% /f /reg:32 > nul

echo DONE

:end
echo.
pause
endlocal
