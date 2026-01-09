@echo off
@setlocal enableextensions

title Reg Patcher for Dungeon Siege 1 by Genesis (v1.48)

:linux_check
rem Check if run from Linux
if defined WINEPREFIX goto init

:argument_check
rem Check and validate arguments
if "%1" == "-c" (
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
) else if not "%1" == "" (
	goto usage
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
rem Correct the current directory when a script is run as admin
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
set _MS_DS=HKLM\Software\Microsoft\Microsoft Games\DungeonSiege
set _MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft Games\DungeonSiege\1.0
set _MS_LOA=HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna
set _MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0
set _REG_ARG=/reg:32
set _REG_FILE=%~n0.reg

rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS% == 32 (
    set _MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege\1.0
    set _MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0
    set _REG_ARG=
)

rem Or on Linux
if defined WINEPREFIX (
    set _MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege\1.0
    set _MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0
    set _REG_ARG=
)

:exe_check
rem Check for game executables in the current directory
echo Current directory: %CD%
echo.
echo Checking for the game executable...

if exist DungeonSiege.exe (
    set "_INSTALL_LOCATION=%CD%"
    echo OK
    goto menu
) else if exist DSLOA.exe (
    set "_INSTALL_LOCATION=%CD%"
    echo OK
    goto menu
) else (
    echo DungeonSiege.exe and DSLOA.exe not found in the current directory!
)

:install_detection
rem Check where the game is installed from the registry
echo.
echo Searching for the game installation directory from the registry...

for /F "tokens=2* delims=	 " %%A in (' REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 39190" /v InstallLocation 2^>nul') do set _INSTALL_LOCATION=%%B

if "%_INSTALL_LOCATION%" == "" (
    echo.
    echo No game installation directory found!
    goto end
) else (
    echo Game installation directory found: %_INSTALL_LOCATION%

    rem Check for game executables in the installation directory
    echo Checking for the game executable...

    if exist "%_INSTALL_LOCATION%\DungeonSiege.exe" (
        echo OK
        goto menu
    ) else if exist "%_INSTALL_LOCATION%\DSLOA.exe" (
        echo OK
        goto menu
    ) else (
        echo DungeonSiege.exe and DSLOA.exe not found in the installation directory!
        goto end
    )
)

:menu
rem Selection menu
echo.
echo Please make a selection:
echo.
echo 1. Add registry entries for Dungeon Siege 1 (needed for DSMod and the DS1 Tool Kit)
echo 2. Add registry entries for Dungeon Siege 1 Legends of Aranna (needed for DSLOAMod)
echo 3. Create a directory junction in Program Files (useful for GameRanger)
echo 4. Export registry entries to a REG file (useful on Linux)
echo 5. Remove registry entries for both games
echo 6. Exit
echo.

rem Automatically make a selection if arguments were passed
if defined _CHOICE (
    choice /C:123456 /N /T 0 /D %_CHOICE% 
) else (
    choice /C:123456 /N
)

echo.

if %ERRORLEVEL% == 1 goto DS1
if %ERRORLEVEL% == 2 goto DS1LOA
if %ERRORLEVEL% == 3 goto junction
if %ERRORLEVEL% == 4 goto export
if %ERRORLEVEL% == 5 goto cleanup
if %ERRORLEVEL% == 6 exit /B

:DS1
echo Adding registry entries for Dungeon Siege 1...

REG ADD "%_MS_DS%\1.0" /v "EXE Path" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul

echo DONE
goto end

:DS1LOA
echo Adding registry entries for Dungeon Siege 1: Legends of Aranna...

REG ADD "%_MS_LOA%\1.0" /v "EXE Path" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul

echo DONE
goto end

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

echo Exporting registry entries for Dungeon Siege 1...

echo [%_MS_DS_EXPORT%]>> %_REG_FILE%
echo "EXE Path"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE
echo.
echo Exporting registry entries for Dungeon Siege 1: Legends of Aranna...

echo [%_MS_LOA_EXPORT%]>> %_REG_FILE%
echo "EXE Path"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE
echo.
echo A new file called "%_REG_FILE%" has been created in the current directory.

goto end

:cleanup
echo Removing registry entries for Dungeon Siege 1...
REG DELETE "%_MS_DS%" /f %_REG_ARG% > nul
echo DONE
echo.

echo Removing registry entries for Dungeon Siege 1: Legends of Aranna...
REG DELETE "%_MS_LOA%" /f %_REG_ARG% > nul

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
