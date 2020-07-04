@echo off

title Reg Patcher for Dungeon Siege 2 by Genesis (v1.4)

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
    echo UAC.ShellExecute """%~f0""", "", "", "runas", 1 >> "%TEMP%\ElevateMe.vbs"

    "%TEMP%\ElevateMe.vbs"
    del "%TEMP%\ElevateMe.vbs"
    
    exit /B
)

echo.

rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct current directory when a script is run as admin
@setlocal enableextensions
@cd /d "%~dp0"

rem https://alt.msdos.batch.narkive.com/LNB84uUc/replace-all-backslashes-in-a-string-with-double-backslash
rem Double backslashes in the current directory path
set _CD_DOUBLE_BACKSLASH=%CD:\=\\%

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
set _2K_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\WOW6432Node\2K Games\Dungeon Siege 2 Broken World
set _GPG_BW_BASE="HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World"
set _GPG_BW="HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000"
set _GPG_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\WOW6432Node\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000
set _MS_DS2="HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2"
set _MS_DS2_EXPORT=HKEY_LOCAL_MACHINE\Software\WOW6432Node\Microsoft\Microsoft Games\DungeonSiege2
set _REG_FILE="Reg_Patch_DS2.reg"

echo Please make a selection:
echo.
echo 1. Add registry entries for Dungeon Siege 2 (needed for BW, Elys DS2 and the DS2 Tool Kit)
echo 2. Add registry entries for Dungeon Siege 2 Broken World (needed for Elys DS2BW)
echo 3. Create a directory junction in Program Files (useful for GameRanger)
echo 4. Export registry entries to a REG file (useful on Linux)
echo 5. Remove registry entries for both games
echo 6. Exit
echo.
echo Note: if you're not sure which option to select, just press 1.
echo.
choice /c 123456 /N

IF %ERRORLEVEL% == 1 goto DS2
IF %ERRORLEVEL% == 2 goto DS2BW
IF %ERRORLEVEL% == 3 goto junction
IF %ERRORLEVEL% == 4 goto export
IF %ERRORLEVEL% == 5 goto cleanup
IF %ERRORLEVEL% == 6 exit /B

:DS2
echo Adding registry entries for Dungeon Siege 2...

REG ADD %_MS_DS2% /v "AppPath" /t REG_SZ /d "%CD%" /f /reg:32 > nul
REG ADD %_MS_DS2% /v "InstallationDirectory" /t REG_SZ /d "%CD%" /f /reg:32 > nul

echo DONE
goto end

:DS2BW
echo Adding registry entries for Dungeon Siege 2: Broken World...

REG ADD %_2K_BW% /v "AppPath" /t REG_SZ /d "%CD%" /f /reg:32 > nul
REG ADD %_2K_BW% /v "InstallationDirectory" /t REG_SZ /d "%CD%" /f /reg:32 > nul
REG ADD %_GPG_BW% /v "InstallLocation" /t REG_SZ /d "%CD%" /f /reg:32 > nul

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
    echo It can safely be renamed or deleted.
)

goto end

:export
echo REGEDIT4> %_REG_FILE%
echo.>> %_REG_FILE%

echo Exporting registry entries for Dungeon Siege 2...

echo [%_MS_DS2_EXPORT%]>> %_REG_FILE%
echo "AppPath"="%_CD_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo "InstallationDirectory"="%_CD_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE

echo Exporting registry entries for Dungeon Siege 2: Broken World...

echo [%_2K_BW_EXPORT%]>> %_REG_FILE%
echo "AppPath"="%_CD_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo "InstallationDirectory"="%_CD_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo [%_GPG_BW_EXPORT%]>> %_REG_FILE%
echo "InstallLocation"="%_CD_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE
echo.
echo A new file called %_REG_FILE% has been created in the current directory.

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
