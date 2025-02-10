@echo off
@setlocal enableextensions

title Reg Patcher for Dungeon Siege 2 by Genesis (v1.45)

:linux_check
rem Check if run from Linux
if defined WINEPREFIX goto init

rem Check and validating arguments
if not "%1" == "" (
    rem If one argument is specified, it must be "-c"
    if "%1" == "-c" (
        rem If the first argument is valid, a second argument must be specified
        if not "%2" == "" (
            rem It must be a digit between 1 and 5 to match the choices below
            if "%2" GEQ "1" (
                if "%2" LEQ "5" (
                    set _CHOICE=%2
                ) else (
                    goto usage
                )
            ) else (
                goto usage
            )
        ) else (
            goto usage
        )
    ) else (
        goto usage
    )
)

:admin_check
rem https://ss64.com/vb/syntax-elevate.html
rem Restart the script as admin if it wasn't the case already
echo Checking if the script is run as admin...
fsutil dirty query %SYSTEMDRIVE% > nul

if %ERRORLEVEL%% == 0 (
    echo OK
) else (
    echo ERROR: admin rights not detected.
    echo.
    echo The script will now restart as admin.

    echo set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\ElevateMe.vbs"
    echo UAC.ShellExecute """%~f0""", "%*", "", "runas", 1 >> "%TEMP%\ElevateMe.vbs"

    "%TEMP%\ElevateMe.vbs"
    del "%TEMP%\ElevateMe.vbs"
    
    exit /B
)

echo.

:init
rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct current directory when a script is run as admin
@cd /d "%~dp0"

rem https://ss64.com/nt/syntax-64bit.html
set _OS_BITNESS=64
set _PROGRAM_FILES=%PROGRAMFILES(X86)%

if %PROCESSOR_ARCHITECTURE% == x86 (
    if not defined PROCESSOR_ARCHITEW6432 (
        set _OS_BITNESS=32
        set _PROGRAM_FILES=%PROGRAMFILES%
    )
)

rem Shortcuts for registry stuff
set _2K_BW=HKLM\Software\2K Games\Dungeon Siege 2 Broken World
set _2K_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\2K Games\Dungeon Siege 2 Broken World
set _GPG_BW=HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World
set _GPG_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000
set _MS_DS2=HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2
set _MS_DS2_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft Games\DungeonSiege2
set _REG_ARG=/reg:32
set _REG_FILE=%~n0.reg

rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS% == 32 (
    set _2K_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\2K Games\Dungeon Siege 2 Broken World
    set _GPG_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000
    set _MS_DS2_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege2
    set _REG_ARG=
)

if defined WINEPREFIX (
    set _2K_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\2K Games\Dungeon Siege 2 Broken World
    set _GPG_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000
    set _MS_DS2_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege2
    set _REG_ARG=
)

:exe_check
rem Check for the game executable in the current directory
echo Checking for the game executable...

if exist DungeonSiege2.exe (
    set _INSTALL_LOCATION=%CD%
    echo OK
    goto menu
) else (
    echo DungeonSiege2.exe not found in the current directory!
)

:install_detection
rem Check where the game is installed from the registry
echo.
echo Searching for the game installation directory...

for /F "tokens=2* delims=	 " %%A in (' REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 39200" /v InstallLocation 2^>nul') do set _INSTALL_LOCATION=%%B

if "%_INSTALL_LOCATION%" == "" (
    echo.
    echo No game installation directory found!
    goto end
) else (
    echo Game installation directory found: %_INSTALL_LOCATION%

    rem Check for the game executable in the installation directory
    echo Checking for the game executable...

    if exist "%_INSTALL_LOCATION%\DungeonSiege2.exe" (
        echo OK
        goto menu
    ) else (
        echo DungeonSiege2.exe not found in the installation directory!
        goto end
    )
)

:menu
rem Selection menu
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

rem Automatically make a selection in case of arguments
if defined _CHOICE (
    choice /C:123456 /N /T 0 /D %_CHOICE% 
) else (
    choice /C:123456 /N
)

if %ERRORLEVEL% == 1 goto DS2
if %ERRORLEVEL% == 2 goto DS2BW
if %ERRORLEVEL% == 3 goto junction
if %ERRORLEVEL% == 4 goto export
if %ERRORLEVEL% == 5 goto cleanup
if %ERRORLEVEL% == 6 exit /B

:DS2
echo Adding registry entries for Dungeon Siege 2...

REG ADD "%_MS_DS2%" /v "AppPath" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
REG ADD "%_MS_DS2%" /v "InstallationDirectory" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
REG ADD "%_MS_DS2%" /v "PID" /t REG_SZ /d "77033-133-5335624-40332" /f %_REG_ARG% > nul

echo DONE
goto end

:DS2BW
echo Adding registry entries for Dungeon Siege 2: Broken World...

REG ADD "%_2K_BW%" /v "AppPath" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
REG ADD "%_2K_BW%" /v "InstallationDirectory" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
REG ADD "%_2K_BW%" /v "PID" /t REG_SZ /d "0204-993D-D268-A1E2" /f %_REG_ARG% > nul
REG ADD "%_GPG_BW%\1.00.0000" /v "InstallLocation" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul

echo DONE
goto end

:junction
rem https://stackoverflow.com/a/8071683
rem Get the current directory name
for %%a in ("%_INSTALL_LOCATION%") do set _CURRENT_DIRECTORY=%%~nxa

if exist "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" rmdir /Q "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" > nul
mklink /J "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" "%_INSTALL_LOCATION%"

if %ERRORLEVEL% == 0 (
    echo.
    echo You can now select the game's executable from "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" to add the game to GameRanger.
    echo.
    echo Warning: do NOT move the directory junction somewhere else as it will also move your entire game directory!
    echo It can safely be renamed or deleted.
)

goto end

:export
rem https://alt.msdos.batch.narkive.com/LNB84uUc/replace-all-backslashes-in-a-string-with-double-backslash
rem Double backslashes in the install directory path
set _INSTALL_LOCATION_DOUBLE_BACKSLASH=%_INSTALL_LOCATION:\=\\%

echo REGEDIT4> %_REG_FILE%
echo.>> %_REG_FILE%

echo Exporting registry entries for Dungeon Siege 2...

echo [%_MS_DS2_EXPORT%]>> %_REG_FILE%
echo "AppPath"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo "InstallationDirectory"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE
echo.
echo Exporting registry entries for Dungeon Siege 2: Broken World...

echo [%_2K_BW_EXPORT%]>> %_REG_FILE%
echo "AppPath"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo "InstallationDirectory"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo [%_GPG_BW_EXPORT%]>> %_REG_FILE%
echo "InstallLocation"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE
echo.
echo A new file called "%_REG_FILE%" has been created in the current directory.

goto end

:cleanup
echo Removing registry entries for Dungeon Siege 2...
REG DELETE "%_MS_DS2%" /f %_REG_ARG% > nul
echo DONE
echo.

echo Removing registry entries for Dungeon Siege 2: Broken World...
REG DELETE "%_2K_BW%" /f %_REG_ARG% > nul
REG DELETE "%_GPG_BW%" /f %_REG_ARG% > nul

echo DONE
goto end

:usage
echo Usage:
echo.
echo %~0 -c X (where X is a number between 1 and 5)
goto end

:end
echo.
pause
endlocal
