@echo off
@setlocal enableextensions

title Reg Patcher for Dungeon Siege 2 by Genesis (v1.50)

:argument_check
rem Check and validate arguments
if "%1" == "-c" (
	rem It must be a digit between 1 and 6 to match the choices below
	if "%2" GEQ "1" (
		if "%2" LEQ "6" (
			set _CHOICE=%2
		) else (
			goto usage
		)
	) else (
		goto usage
	)
) else if not "%1" == "" (
	goto usage
)

:linux_check
rem Check if run from Linux
if defined WINEPREFIX goto init

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
set _PROGRAM_FILES="%PROGRAMFILES(X86)%"

if %PROCESSOR_ARCHITECTURE% == x86 (
    if not defined PROCESSOR_ARCHITEW6432 (
        set _OS_BITNESS=32
        set _PROGRAM_FILES="%PROGRAMFILES%"
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
set _REG_KEY_GOG=HKLM\SOFTWARE\Wow6432Node\GOG.com\Games\1837106902
set _REG_KEY_STEAM=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 39200

rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS% == 32 (
    set _2K_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\2K Games\Dungeon Siege 2 Broken World
    set _GPG_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000
    set _MS_DS2_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege2
    set _REG_ARG=
	set _REG_KEY_GOG=HKLM\SOFTWARE\GOG.com\Games\1837106902
)

rem Or on Linux
if defined WINEPREFIX (
    set _2K_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\2K Games\Dungeon Siege 2 Broken World
    set _GPG_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000
    set _MS_DS2_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege2
    set _REG_ARG=
	set _REG_KEY_GOG=HKLM\SOFTWARE\GOG.com\Games\1837106902
)

:exe_check
rem Check for the game executable in the current directory
echo Current directory: %CD%
echo.
echo Checking for the game executable...

if exist DungeonSiege2.exe (
    set "_INSTALL_LOCATION=%CD%"
    echo OK
    goto menu
) else (
    echo DungeonSiege2.exe not found in the current directory!
)

:steam_install_detection
rem Check where the game is installed from the registry
echo.
echo Searching for the game Steam installation directory...

for /F "tokens=2* delims=	 " %%A in (' REG QUERY "%_REG_KEY_STEAM%" /v InstallLocation 2^>nul') do set "_INSTALL_LOCATION=%%B"

if "%_INSTALL_LOCATION%" == "" (
    echo No Steam installation directory found!
) else (
    echo Steam installation directory found: %_INSTALL_LOCATION%

    rem Check for the game executable in the installation directory
    echo Checking for the game executable...

    if exist "%_INSTALL_LOCATION%\DungeonSiege2.exe" (
        echo OK
        goto menu
    ) else (
        echo DungeonSiege2.exe not found in the installation directory!
    )
)

:gog_install_detection
rem Check where the game is installed from the registry
echo.
echo Searching for the game GOG installation directory...

for /F "tokens=2* delims=	 " %%A in (' REG QUERY "%_REG_KEY_GOG%" /v path 2^>nul') do set "_INSTALL_LOCATION=%%B"

if "%_INSTALL_LOCATION%" == "" (
    echo No GOG installation directory found!
    goto end
) else (
    echo GOG installation directory found: %_INSTALL_LOCATION%

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
echo.
echo Please make a selection:
echo.
echo 1. Add registry entries for both games
echo 2. Add registry entries for Dungeon Siege 2 (needed for BW, Elys DS2 and the DS2 Tool Kit)
echo 3. Add registry entries for Dungeon Siege 2 Broken World (needed for Elys DS2BW and OpenSpy)
echo 4. Create a directory junction in Program Files (useful for GameRanger)
echo 5. Export registry entries to a REG file (useful on Linux)
echo 6. Remove registry entries for both games
echo 7. Exit
echo.
echo Note: if you're not sure which option to select, just press 1.
echo.

rem Automatically make a selection if arguments were passed
if defined _CHOICE (
    choice /C:1234567 /N /T 0 /D %_CHOICE%
) else (
    choice /C:1234567 /N
)

echo.

if %ERRORLEVEL% == 1 call :DS2 & echo. & call :DS2BW & goto end
if %ERRORLEVEL% == 2 call :DS2 & goto end
if %ERRORLEVEL% == 3 call :DS2BW & goto end
if %ERRORLEVEL% == 4 goto junction
if %ERRORLEVEL% == 5 goto export
if %ERRORLEVEL% == 6 goto cleanup
if %ERRORLEVEL% == 7 exit /B

:DS2
echo Adding registry entries for Dungeon Siege 2...

REG ADD "%_MS_DS2%" /v "AppPath" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
REG ADD "%_MS_DS2%" /v "InstallationDirectory" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
REG ADD "%_MS_DS2%" /v "PID" /t REG_SZ /d "00000-000-0000000-00000" /f %_REG_ARG% > nul

echo DONE
exit /B

:DS2BW
echo Adding registry entries for Dungeon Siege 2: Broken World...

REG ADD "%_2K_BW%" /v "AppPath" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
REG ADD "%_2K_BW%" /v "InstallationDirectory" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
REG ADD "%_2K_BW%" /v "PID" /t REG_SZ /d "0000-0000-0000-0000" /f %_REG_ARG% > nul
REG ADD "%_GPG_BW%\1.00.0000" /v "InstallLocation" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul

echo DONE
exit /B

:junction
rem https://stackoverflow.com/a/8071683
rem Get the install directory name
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

echo DONE
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
echo "PID"="0000-0000-0000-0000">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE
echo.
echo Exporting registry entries for Dungeon Siege 2: Broken World...

echo [%_2K_BW_EXPORT%]>> %_REG_FILE%
echo "AppPath"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo "InstallationDirectory"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo "PID"="0000-0000-0000-0000">> %_REG_FILE%
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

:end
echo.
pause
endlocal
