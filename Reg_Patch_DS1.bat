@echo off
setlocal

title Reg Patcher for Dungeon Siege 1 by Genesis (v1.53)
echo You can find the latest version or report issues at https://github.com/GenesisFR/RegPatches.
echo:

:parse_args
rem Check and validate arguments
if "%~1"=="" goto linux_check
if /I "%~1"=="-c" (
	rem It must be a digit between 1 and 8 to match the choices below
	if "%~2"=="1" set "_CHOICE=%~2"
	if "%~2"=="2" set "_CHOICE=%~2"
	if "%~2"=="3" set "_CHOICE=%~2"
	if "%~2"=="4" set "_CHOICE=%~2"
	if "%~2"=="5" set "_CHOICE=%~2"
	if "%~2"=="6" set "_CHOICE=%~2"
	if "%~2"=="7" set "_CHOICE=%~2"
	if "%~2"=="8" set "_CHOICE=%~2"
	if not defined _CHOICE goto usage
) else goto usage

:linux_check
rem Check if run from Linux
if defined WINEPREFIX goto init

:admin_check
rem https://ss64.com/vb/syntax-elevate.html
rem Restart the script as admin if it wasn't the case already
echo Checking if the script is run as admin...
fsutil dirty query %SYSTEMDRIVE% > nul

if %ERRORLEVEL% == 0 (
	echo OK
) else (
	echo ERROR: admin rights not detected.
	echo:
	echo The script will now restart as admin.

	echo set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\ElevateMe.vbs"
	echo UAC.ShellExecute """%~f0""", "%*", "", "runas", 1 >> "%TEMP%\ElevateMe.vbs"

	"%TEMP%\ElevateMe.vbs"
	del "%TEMP%\ElevateMe.vbs"

	exit /B
)

echo:

:init
rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct the current directory when a script is run as admin
cd /d "%~dp0"

rem https://ss64.com/nt/syntax-64bit.html
set "_OS_BITNESS=64"
set "_PROGRAM_FILES=%PROGRAMFILES(X86)%"

if %PROCESSOR_ARCHITECTURE% == x86 (
	if not defined PROCESSOR_ARCHITEW6432 (
		set "_OS_BITNESS=32"
		set "_PROGRAM_FILES=%PROGRAMFILES%"
	)
)

rem Shortcuts for registry stuff
set "_MS_DS=HKLM\Software\Microsoft\Microsoft Games\DungeonSiege"
set "_MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft Games\DungeonSiege\1.0"
set "_MS_LOA=HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna"
set "_MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0"
set "_REG_ARG=/reg:32"
set "_REG_FILE=%~n0.reg"
set "_REG_KEY_GOG=HKLM\SOFTWARE\Wow6432Node\GOG.com\Games\1185868626"
set "_REG_KEY_STEAM=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 39190"

rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS% == 32 (
	set "_MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege\1.0"
	set "_MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0"
	set "_REG_ARG="
	set "_REG_KEY_GOG=HKLM\SOFTWARE\GOG.com\Games\1185868626"
)

:exe_check
rem Check for game executables in the current directory
echo Current directory: %CD%
echo:
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

:steam_install_detection
rem Check where the game is installed from the registry
echo:
echo Searching for the game Steam installation directory...

for /F "tokens=2*" %%A in ('reg query "%_REG_KEY_STEAM%" /v InstallLocation 2^>nul') do set "_INSTALL_LOCATION=%%B"

if "%_INSTALL_LOCATION%" == "" (
	echo No Steam installation directory found!
) else (
	echo Steam installation directory found: %_INSTALL_LOCATION%

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

:gog_install_detection
rem Check where the game is installed from the registry
echo:
echo Searching for the game GOG installation directory...

for /F "tokens=2*" %%A in ('reg query "%_REG_KEY_GOG%" /v path 2^>nul') do set "_INSTALL_LOCATION=%%B"

if "%_INSTALL_LOCATION%" == "" (
	echo No GOG installation directory found!
	goto end
) else (
	echo GOG installation directory found: %_INSTALL_LOCATION%

	rem Check for the game executable in the installation directory
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
echo:
echo Please make a selection:
echo:
echo 1. Add registry entries for Dungeon Siege and Legends of Aranna
echo 2. Add registry entries for Dungeon Siege (needed for DSMod and the DS1 Tool Kit)
echo 3. Add registry entries for Dungeon Siege: Legends of Aranna (needed for DSLOAMod)
echo 4. Create a directory junction in Program Files (useful for GameRanger)
echo 5. Export registry entries to a REG file (to import them manually)
echo 6. Remove registry entries for both games
echo 7. Redirect ZoneMatch to OpenZone (needed to play online through ZoneMatch)
echo 8. Add environment variable for Gmax (useful for modders installing SiegeMax)
echo 9. Exit
echo:

rem Automatically make a selection if arguments were passed
if defined _CHOICE (
	choice /C:123456789 /N /T 0 /D %_CHOICE%
) else (
	choice /C:123456789 /N
)

echo:

if %ERRORLEVEL% == 1 call :ds1 & echo: & call :ds1loa & goto end
if %ERRORLEVEL% == 2 call :ds1 & goto end
if %ERRORLEVEL% == 3 call :ds1loa & goto end
if %ERRORLEVEL% == 4 goto junction
if %ERRORLEVEL% == 5 goto export
if %ERRORLEVEL% == 6 goto cleanup
if %ERRORLEVEL% == 7 goto openzone
if %ERRORLEVEL% == 8 goto gmax
if %ERRORLEVEL% == 9 exit /B

:ds1
echo Adding registry entries for Dungeon Siege...
reg add "%_MS_DS%\1.0" /v "EXE Path" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
echo DONE
exit /B

:ds1loa
echo Adding registry entries for Dungeon Siege: Legends of Aranna...
reg add "%_MS_LOA%\1.0" /v "EXE Path" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
echo DONE
exit /B

:junction
rem https://stackoverflow.com/a/8071683
rem Get the install directory name
for %%A in ("%_INSTALL_LOCATION%") do set "_INSTALL_DIRECTORY_NAME=%%~nxA"

if exist "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" rmdir /Q "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" > nul
mklink /J "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" "%_INSTALL_LOCATION%"

if %ERRORLEVEL% == 0 (
	echo:
	echo You can now select the game's executable from "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" to add the game to GameRanger.
	echo:
	echo Warning: do NOT move the directory junction somewhere else as it will also move your entire game directory!
	echo It can safely be renamed or deleted.
)

echo:
echo DONE
goto end

:export
rem https://alt.msdos.batch.narkive.com/LNB84uUc/replace-all-backslashes-in-a-string-with-double-backslash
rem Double backslashes in the install directory path
set "_INSTALL_LOCATION_DOUBLE_BACKSLASH=%_INSTALL_LOCATION:\=\\%"

echo Exporting registry entries for Dungeon Siege and Legends of Aranna...

(
	echo REGEDIT4
	echo:
	echo [%_MS_DS_EXPORT%]
	echo "EXE Path"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
	echo:
	echo [%_MS_LOA_EXPORT%]
	echo "EXE Path"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
) > %_REG_FILE%

echo DONE
echo:
echo A new file called "%_REG_FILE%" has been created in the current directory.

goto end

:cleanup
echo Removing registry entries for Dungeon Siege and Legends of Aranna...
reg delete "%_MS_DS%" /f %_REG_ARG% > nul 2>&1 
reg delete "%_MS_LOA%" /f %_REG_ARG% > nul 2>&1
echo DONE
goto end

:openzone
echo Redirecting the ZoneMatch server to OpenZone...

rem https://serverfault.com/a/701644
rem Get the path to My Documents
for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal" 2^>nul') do set "_MY_DOCUMENTS=%%B"

set "_CFG_FILE_DS=%_MY_DOCUMENTS%\Dungeon Siege\DungeonSiege.ini"
set "_CFG_FILE_LOA=%_MY_DOCUMENTS%\Dungeon Siege LOA\DungeonSiege.ini"
set "_CFG_FILE_FOUND=0"

rem Update the DS config file if it exists
if exist "%_CFG_FILE_DS%" (
	set "_CFG_FILE_FOUND=1"

	setlocal EnableDelayedExpansion
	call :read_ini "%_CFG_FILE_DS%"
	setlocal DisableDelayedExpansion

	call :append_mp_section "%_CFG_FILE_DS%"
)

rem Update the LOA config file if it exists
if exist "%_CFG_FILE_LOA%" (
	set "_CFG_FILE_FOUND=1"

	setlocal EnableDelayedExpansion
	call :read_ini "%_CFG_FILE_LOA%"
	setlocal DisableDelayedExpansion

	call :append_mp_section "%_CFG_FILE_LOA%"
)

if %_CFG_FILE_FOUND% EQU 0 (
	echo No config file found! Make sure to run the game at least once to generate it.
) else (
	echo DONE
)

goto end

rem https://tutorialreference.com/batch-scripting/examples/faq/batch-script-how-to-read-and-write-to-an-ini-file
rem Store the beginning of the config file to a temp file
:read_ini
set "_CFG_FILE=%~1"
set "_CFG_FILE_TEMP=%~1.tmp"
set "_TARGET_SECTION=multiplayer"

if exist "%_CFG_FILE_TEMP%" del "%_CFG_FILE_TEMP%"
set "_IN_SECTION=0"

rem Read the config file line by line
rem By default, "for /f" skips commented lines, however using "eol=" creates a weird syntax error on Linux, hence the # character 
for /F "usebackq eol=# delims=" %%L in ("%_CFG_FILE%") do (
	set "_LINE=%%L"

	rem Section detection logic
	if "!_LINE:~0,1!"=="[" if "!_LINE:~-1!"=="]" (
		for /F "delims=[]" %%S in ("!_LINE!") do (
			if /I "%%S"=="%_TARGET_SECTION%" ( set "_IN_SECTION=1" )
		)
	)

	rem Write the current line to the temp file until we reach the MP section
	if !_IN_SECTION! EQU 0 (
		if "!_LINE!" == "" (
			echo:>> "%_CFG_FILE_TEMP%"
		) else (
			echo !line!>> "%_CFG_FILE_TEMP%"
		)
	) else (
		exit /B
	)
)

exit /B

rem Append the MP section to the temp file
:append_mp_section
set "_CFG_FILE=%~1"
set "_CFG_FILE_TEMP=%~1.tmp"

rem echo append_mp_section _CFG_FILE = %_CFG_FILE%
rem echo append_mp_section _CFG_FILE_TEMP = %_CFG_FILE_TEMP%

(
	echo [multiplayer]
	echo gun_server = gz.exsurge.net
	echo gun_server_port = 2300
	echo news_server = gz.exsurge.net
	echo news_server_port = 2301
	echo news_server_file = news.txt
	echo autoupdate_server = gz.exsurge.net
	echo autoupdate_proxy = gz.exsurge.net
	echo:
	echo [debug]
) >> "%_CFG_FILE_TEMP%"

rem Overwrite the original config file
move /Y "%_CFG_FILE_TEMP%" "%_CFG_FILE%" > nul

exit /B

:gmax
echo Checking for the Gmax executable...

if exist gmax.exe (
	echo OK
	echo:
	echo Adding the environment variable for Gmax...
	setx GMAXLOC "%CD%" > nul
) else (
	echo gmax.exe not found in the current directory!
	echo:
	set "_CHOICE="
	pause
	cls
	goto menu
)

echo DONE
goto end

:usage
echo Usage:
echo:
echo %~0 -c X (where X is a number between 1 and 8)

:end
echo:
pause
endlocal
