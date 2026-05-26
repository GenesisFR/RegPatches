@echo off
setlocal

rem You can find the latest version or report issues at https://github.com/GenesisFR/RegPatches.
set "_VERSION=1.57"
title Reg Patcher for Dungeon Siege 1 by Genesis (v%_VERSION%)
echo:

:linux_check
rem https://www.reddit.com/r/Batch/comments/odynta/check_whether_bat_is_run_from_wine
rem Check if run from Linux
fsutil | find "dirty" > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"
break > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"
dir /n > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"
dir /4 > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"
dpath > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"

:parse_args
rem Check and validate arguments
if "%~1"=="" (
	rem Do nothing
	break 2> nul
) else if /I "%~1"=="-c" (
	rem It must be a digit between 1 and 10 to match the choices below
	if "%~2"=="1" set "_CHOICE=%~2"
	if "%~2"=="2" set "_CHOICE=%~2"
	if "%~2"=="3" set "_CHOICE=%~2"
	if "%~2"=="4" set "_CHOICE=%~2"
	if "%~2"=="5" set "_CHOICE=%~2"
	if "%~2"=="6" set "_CHOICE=%~2"

	if not defined _LINUX (
		if "%~2"=="7" set "_CHOICE=%~2"
		if "%~2"=="8" set "_CHOICE=%~2"
		if "%~2"=="9" set "_CHOICE=%~2"
		if "%~2"=="10" set "_CHOICE=%~2"
	)

	if not defined _CHOICE goto usage
) else goto usage


rem https://web.archive.org/web/20251127131301/https://www.dostips.com/forum/viewtopic.php?f=3&t=8044&p=53478#p53478
rem Setup ANSI escape character for multi-color output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "cReset=%ESC%[0m"
set "cTitle=%ESC%[96m"
set "cMenu=%ESC%[93m"
set "cSuccess=%ESC%[92m"
set "cError=%ESC%[91m"
set "cInfo=%ESC%[94m"
set "cDim=%ESC%[90m"

if defined _LINUX (
	rem No multi-color output support
	set "cReset="
	set "cTitle="
	set "cMenu="
	set "cSuccess="
	set "cError="
	set "cInfo="
	set "cDim="

	rem Skip the admin check, otherwise we'll be stuck in an endless loop
	goto init
)

:admin_check
rem https://ss64.com/vb/syntax-elevate.html
rem Restart the script as admin if it wasn't the case already
cls
echo %cTitle%===============================================================================%cReset%
echo                      %cTitle%DUNGEON SIEGE 1 REGISTRY PATCHER%cReset%
echo %cTitle%===============================================================================%cReset%
echo %cInfo%[~] Checking if the script is run as admin...%cReset%
fsutil dirty query %SystemDrive% > nul

if %ERRORLEVEL%==0 (
    echo %cSuccess%[+] Administrator rights detected.%cReset%
	echo:
	ping -n 2 127.0.0.1 > nul
) else (
    echo %cError%[-] ERROR: administrator rights required.%cReset%
    echo %cInfo%[~] Attempting to elevate privileges via UAC...%cReset%

	echo set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\ElevateMe.vbs"
	echo UAC.ShellExecute """%~f0""", "%*", "", "runas", 1 >> "%TEMP%\ElevateMe.vbs"

	"%TEMP%\ElevateMe.vbs"
	del "%TEMP%\ElevateMe.vbs"

	exit /B
)

:init
rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct the current directory when a script is run as admin
cd /d "%~dp0"

rem Shortcuts for registry stuff
set "_MS_DS=HKLM\Software\Microsoft\Microsoft Games\DungeonSiege"
set "_MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft Games\DungeonSiege\1.0"
set "_MS_LOA=HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna"
set "_MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0"
set "_REG_ARG=/reg:32"
set "_REG_FILE=%~n0.reg"
set "_REG_KEY_CFA=HKLM\Software\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
set "_REG_KEY_GOG=HKLM\SOFTWARE\Wow6432Node\GOG.com\Games\1185868626"
set "_REG_KEY_SF=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
set "_REG_KEY_STEAM=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 39190"

rem https://ss64.com/nt/syntax-64bit.html
rem Check if we're on a 32-bit system
set "_COMSPEC=%SystemRoot%\system32\cmd.exe"
set "_OS_BITNESS=64"
set "_PROGRAM_FILES=%ProgramFiles(x86)%"

if %PROCESSOR_ARCHITECTURE%==x86 (
	if not defined PROCESSOR_ARCHITEW6432 (
		set "_OS_BITNESS=32"
		set "_PROGRAM_FILES=%ProgramFiles%"
	)
)
				
rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS%==32 (
	set "_MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege\1.0"
	set "_MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0"
	set "_REG_ARG="
	set "_REG_KEY_GOG=HKLM\SOFTWARE\GOG.com\Games\1185868626"
)
rem Store the Windows version
if not defined _LINUX (
	for /f "tokens=4 delims=. " %%i in ('ver') do set _WINVER=%%i
)

:exe_check
echo %cInfo%[~] Current directory:%cReset% %CD%
echo %cInfo%[~] Scanning for game executables...%cReset%
echo %cDim%-------------------------------------------------------------------------------%cReset%

rem Check for game executables in the current directory
if exist DungeonSiege.exe (
	set "_INSTALL_LOCATION=%CD%"
    echo %cSuccess%[+] Found DungeonSiege.exe in the current directory.%cReset%
	ping -n 2 127.0.0.1 > nul
	goto menu
) else if exist DSLOA.exe (
	set "_INSTALL_LOCATION=%CD%"
    echo %cSuccess%[+] Found DSLOA.exe in the current directory.%cReset%
	ping -n 2 127.0.0.1 > nul
	goto menu
) else (
    echo %cError%[-] DungeonSiege.exe and DSLOA.exe not found in the current directory.%cReset%

	rem Steam/GOG don't update the Wine registry when installing games and its CMD sends errors to STDOUT so we skip the install detection
	if defined _LINUX (
		echo %cInfo%[i] Please place this script inside your Dungeon Siege game directory.%cReset%
		goto end
	)
)

rem Check for the game executables in the Steam installation directory, then GOG if not found
call :install_detection Steam "%_REG_KEY_STEAM%" InstallLocation
if %ERRORLEVEL%==1 (
	call :install_detection GOG "%_REG_KEY_GOG%" path
	if %ERRORLEVEL%==1 (
		echo %cError%[-] ERROR: could not locate the game installation directory.%cReset%
		echo %cInfo%[i] Please place this script inside your Dungeon Siege game directory.%cReset%
		goto end
	)
)

:menu
rem Selection menu
cls
echo %cTitle%===============================================================================%cReset%
echo                      %cTitle%DUNGEON SIEGE 1 REGISTRY PATCHER%cReset%
echo %cTitle%===============================================================================%cReset%
echo %cInfo%Installation directory:%cReset% %_INSTALL_LOCATION%
echo:
echo %cTitle%[ REGISTRY PATCHING ]%cReset%
echo %cMenu%[1]%cReset% Add registry entries for Dungeon Siege and Legends of Aranna
echo %cMenu%[2]%cReset% Add registry entries for Dungeon Siege (needed for DSMod and the DS1 Tool Kit)
echo %cMenu%[3]%cReset% Add registry entries for Legends of Aranna (needed for DSLOAMod)
echo %cMenu%[4]%cReset% Remove all registry entries for both games
echo %cMenu%[5]%cReset% Export registry entries to a REG file (to import them manually)
echo:
echo %cTitle%[ MULTIPLAYER ^& FIXES ]%cReset%
echo %cMenu%[6]%cReset% Redirect ZoneMatch to OpenZone (needed to play online through ZoneMatch)

rem Hide Windows-specific options on Linux
if not defined _LINUX (
    echo %cMenu%[7]%cReset% Create a directory junction in Program Files ^(useful for GameRanger^)
    echo %cMenu%[8]%cReset% Whitelist the game executable^(s^) in Controlled Folder Access ^(useful on Windows 10/11^)
    echo:
    echo %cTitle%[ MODDING ]%cReset%
    echo %cMenu%[9]%cReset% Add the environment variable for Gmax ^(useful when installing SiegeMax^)
	echo:
    echo %cTitle%[ OTHER ]%cReset%
    echo %cMenu%[0]%cReset% Check for updates
	echo:
	echo %cError%[a] Exit%cReset%
) else (
	echo:
	echo %cError%[7] Exit%cReset%
)

echo:
echo %cMenu%[Note]%cReset% If you're not sure which option to select, just press 1.
echo %cDim%-------------------------------------------------------------------------------%cReset%

rem Automatically make a selection if arguments were passed
if not defined _LINUX (
	if defined _CHOICE (
		choice /C:1234567890 /N /T 0 /D %_CHOICE%
	) else (
		echo %cTitle%Please make a selection [0-a]: %cReset%
		choice /C:1234567890a /N
	)
) else (
	if defined _CHOICE (
		choice /C:123456 /N /T 0 /D %_CHOICE%
	) else (
		echo %cTitle%Please make a selection [0-7]: %cReset%
		choice /C:1234567 /N
	)
)

cls
echo %cTitle%===============================================================================%cReset%
echo                              %cTitle%PROCESSING SELECTION%cReset%
echo %cTitle%===============================================================================%cReset%
echo:

if %ERRORLEVEL%==0 goto menu
if %ERRORLEVEL%==1 call :ds1 & echo: & call :ds1loa & goto end
if %ERRORLEVEL%==2 call :ds1 & goto end
if %ERRORLEVEL%==3 call :ds1loa & goto end
if %ERRORLEVEL%==4 goto cleanup
if %ERRORLEVEL%==5 goto export
if %ERRORLEVEL%==6 goto openzone

rem Don't handle Windows-specific options on Linux
if not defined _LINUX (
	if %ERRORLEVEL%==7 goto junction
	if %ERRORLEVEL%==8 goto controlled
	if %ERRORLEVEL%==9 goto gmax
	if %ERRORLEVEL%==10 goto update
	if %ERRORLEVEL%==11 exit /B
) else (
	if %ERRORLEVEL%==7 exit /B
)

rem This is only here to help with development since we should never reach this in practice
echo %cError%[-] Invalid choice detected.%cReset% & goto end

:install_detection
rem Check where the game is installed from the registry
echo:
echo %cInfo%[~] Searching for the %1 installation directory...%cReset%

for /F "tokens=2*" %%A in ('reg query %2 /v %3 2^>nul') do set "_INSTALL_LOCATION=%%B"

if "%_INSTALL_LOCATION%"=="" (
    echo %cError%[-] %1 installation directory not found.%cReset%
	exit /B 1
) else (
	echo %cSuccess%[+] %1 installation directory found: %_INSTALL_LOCATION%%cReset%
	ping -n 2 127.0.0.1 > nul
    echo %cInfo%[~] Scanning for game executables...%cReset%
	echo %cDim%-------------------------------------------------------------------------------%cReset%

	rem Check for game executables in the installation directory
	if exist "%_INSTALL_LOCATION%\DungeonSiege.exe" (
		echo %cSuccess%[+] Found DungeonSiege.exe in the %1 installation directory.%cReset%
		ping -n 2 127.0.0.1 > nul
		exit /B
	) else if exist "%_INSTALL_LOCATION%\DSLOA.exe" (
		echo %cSuccess%[+] Found DSLOA.exe in the %1 installation directory.%cReset%
		ping -n 2 127.0.0.1 > nul
		exit /B
	) else (
		echo %cError%[-] DungeonSiege.exe and DSLOA.exe not found in the %1 installation directory.%cReset%
		exit /B 1
	)
)

:cfa_check
rem Check in the registry if Controlled Folder Access is enabled
set "_IS_CFA_ENABLED=0"

if %_WINVER% GEQ 10 (
	for /f "tokens=2*" %%A in ('reg query "%_REG_KEY_CFA%" /v "EnableControlledFolderAccess" 2^>nul') do set "_IS_CFA_ENABLED=%%B"
)

rem The value above is hexadecimal so we need to convert it to decimal
set /A "_IS_CFA_ENABLED=%_IS_CFA_ENABLED%"

exit /B

:powershell_check
rem Check if Powershell is installed (we could use the where command but it's not included by default on XP)
for %%A in (powershell.exe) do @echo %%~$PATH:A% | find "powershell" > nul 2>&1

if %ERRORLEVEL%==0 (
	set "_PWSH_CMD=powershell"
) else (
	for %%A in (pwsh.exe) do @echo %%~$PATH:A | find "pwsh" > nul 2>&1

	if !ERRORLEVEL!==0 (
		set "_PWSH_CMD=pwsh"
	) else (
        echo %cMenu%[!] WARNING: PowerShell not found, some options may fail.%cReset%
		echo Make sure it's installed and is in your PATH environment variable.
		echo:
	)
)

exit /B

:ds1
echo %cInfo%[~] Adding registry entries for Dungeon Siege...%cReset%
ping -n 2 127.0.0.1 > nul
reg add "%_MS_DS%\1.0" /v "EXE Path" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
echo %cSuccess%[+] SUCCESS: registry entries updated.%cReset%
ping -n 2 127.0.0.1 > nul
exit /B

:ds1loa
echo %cInfo%[~] Adding registry entries for Dungeon Siege: Legends of Aranna...%cReset%
ping -n 2 127.0.0.1 > nul
reg add "%_MS_LOA%\1.0" /v "EXE Path" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
echo %cSuccess%[+] SUCCESS: registry entries updated.%cReset%
ping -n 2 127.0.0.1 > nul
exit /B

:cleanup
echo %cInfo%[~] Removing registry entries for Dungeon Siege and Legends of Aranna...%cReset%
ping -n 2 127.0.0.1 > nul
reg delete "%_MS_DS%" /f %_REG_ARG% > nul 2>&1
reg delete "%_MS_LOA%" /f %_REG_ARG% > nul 2>&1
echo %cSuccess%[+] SUCCESS: registry entries removed.%cReset%
ping -n 2 127.0.0.1 > nul
goto end

:export
rem https://alt.msdos.batch.narkive.com/LNB84uUc/replace-all-backslashes-in-a-string-with-double-backslash
rem Double backslashes in the install directory path
set "_INSTALL_LOCATION_DOUBLE_BACKSLASH=%_INSTALL_LOCATION:\=\\%"

echo %cInfo%[~] Exporting registry entries for Dungeon Siege and Legends of Aranna...%cReset%
ping -n 2 127.0.0.1 > nul

(
	echo REGEDIT4
	echo:
	echo [%_MS_DS_EXPORT%]
	echo "EXE Path"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
	echo:
	echo [%_MS_LOA_EXPORT%]
	echo "EXE Path"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
) > %_REG_FILE%

echo %cSuccess%[+] SUCCESS: registry entries exported.%cReset%
echo %cInfo%[i] A new file called "%_REG_FILE%" has been created in the current directory.%cReset%
ping -n 2 127.0.0.1 > nul

goto end

:openzone
setlocal EnableDelayedExpansion
echo %cInfo%[~] Redirecting the ZoneMatch server to OpenZone...%cReset%
ping -n 2 127.0.0.1 > nul

rem Add cmd.exe to the Controlled Folder Access whitelist (otherwise the attrib/move commands won't work)
if not defined _LINUX (
	call :cfa_check
	call :powershell_check

	if !_WINVER! GEQ 10 (
		if !_IS_CFA_ENABLED!==1 (
			if defined _PWSH_CMD (
				rem Check in the registry if it's already been whitelisted
				for /f "tokens=2*" %%A in ('reg query "%_REG_KEY_CFA%\AllowedApplications" /v "%_COMSPEC%" 2^>nul') do set "_IS_CMD_ALLOWED=%%B"

				if not defined _IS_CMD_ALLOWED (
                    echo %cInfo%[~] Controlled Folder Access requires whitelisting your system shell terminal environment.%cReset%
					echo:
					pause
					echo:
					
					!_PWSH_CMD! Add-MpPreference -ControlledFolderAccessAllowedApplications '%_COMSPEC%' > nul 2>&1

					echo %cSuccess%[+] Whitelisting successful.%cReset%
                    echo %cInfo%[i] The reg patch will now restart for changes to take effect.%cReset%
					ping -n 2 127.0.0.1 > nul
					call :end
					cls

					rem Restart the reg patch using the same option because Controlled Folder Access changes don't come into effect in the current session
					cmd /c "%~f0" -c 6
					exit /B
				)
			) else (
                echo %cError%[-] Execution aborted: Powershell is not installed.%cReset%
				goto end
			)
		)
	)
)

rem https://serverfault.com/a/701644
rem Get the path to My Documents
for /f "tokens=2*" %%A in ('reg query "%_REG_KEY_SF%" /v "Personal" 2^>nul') do set "_MY_DOCUMENTS=%%B"

set "_CFG_FILE_DS=%_MY_DOCUMENTS%\Dungeon Siege\DungeonSiege.ini"
set "_CFG_FILE_LOA=%_MY_DOCUMENTS%\Dungeon Siege LOA\DungeonSiege.ini"
set "_CFG_FILE_FOUND=0"

rem Update the DS config file if it exists
if exist "%_CFG_FILE_DS%" (
	set "_CFG_FILE_FOUND=1"
	call :edit_ini "%_CFG_FILE_DS%"

	rem Overwrite the original config file (even if it was read-only)
	attrib -R "%_CFG_FILE_DS%"
	move /Y "%_CFG_FILE_DS%.tmp" "%_CFG_FILE_DS%" > nul
)

rem Update the LOA config file if it exists
if exist "%_CFG_FILE_LOA%" (
	set "_CFG_FILE_FOUND=1"
	call :edit_ini "%_CFG_FILE_LOA%"

	rem Overwrite the original config file (even if it was read-only)
	attrib -R "%_CFG_FILE_LOA%"
	move /Y "%_CFG_FILE_LOA%.tmp" "%_CFG_FILE_LOA%" > nul
)

if %_CFG_FILE_FOUND%==0 (
	echo %cError%[-] No config file found! Make sure to run the game at least once to generate it.%cReset%
) else (
    echo %cSuccess%[+] SUCCESS: ZoneMatch server redirected to OpenZone.%cReset%
	ping -n 2 127.0.0.1 > nul
)

setlocal DisableDelayedExpansion
goto end

:edit_ini
rem https://tutorialreference.com/batch-scripting/examples/faq/batch-script-how-to-read-and-write-to-an-ini-file
rem Store the beginning of the config file to a temp file
set "_CFG_FILE=%~1"
set "_CFG_FILE_TEMP=%~1.tmp"
set "_TARGET_SECTION=multiplayer"

if exist "%_CFG_FILE_TEMP%" del "%_CFG_FILE_TEMP%"
set "_IN_SECTION=0"

rem Read the config file line by line
rem By default, "for /f" skips commented lines, however using "eol=" creates a weird syntax error on Linux, hence the * character that's usually unused
for /F "usebackq eol=* delims=" %%L in ("%_CFG_FILE%") do (
	set "_LINE=%%L"

	rem Section detection logic
	if "!_LINE:~0,1!"=="[" if "!_LINE:~-1!"=="]" (
		for /F "delims=[]" %%S in ("!_LINE!") do (
			if /I "%%S"=="%_TARGET_SECTION%" (set "_IN_SECTION=1")
		)
	)

	rem Write the current line to the temp file until we reach the MP section
	if !_IN_SECTION!==0 (
		if not "!_LINE!"=="" (echo !_LINE!>> "%_CFG_FILE_TEMP%")
	) else (
		rem Append the MP section to the temp file
		(
			echo:
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

		exit /B
	)
)

rem No MP section was found
if !_IN_SECTION!==0 (
	rem Append the MP section to the temp file
	(
		echo:
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
)

exit /B

:junction
rem https://stackoverflow.com/a/8071683
rem Get the install directory name
for %%A in ("%_INSTALL_LOCATION%") do set "_INSTALL_DIRECTORY_NAME=%%~nxA"

echo %cInfo%[~] Creating a directory junction for Dungeon Siege...%cReset%
ping -n 2 127.0.0.1 > nul

if exist "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" rmdir /Q "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" > nul
mklink /J "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" "%_INSTALL_LOCATION%" > nul

if %ERRORLEVEL%==0 (
    echo %cSuccess%[+] SUCCESS: directory junction created.%cReset%
    echo %cInfo%[i] You can now select the game executable from "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" to add the game to GameRanger.%cReset%
    echo %cMenu%[!] WARNING: do NOT move the directory junction somewhere else as it will also move your entire game directory.%cReset%
    echo %cInfo%[i] It can safely be renamed or deleted.%cReset%
	ping -n 2 127.0.0.1 > nul
) else (
    echo %cError%[-] Failed to create directory junction.%cReset%
)

goto end

:controlled
setlocal EnableDelayedExpansion

if not defined _LINUX (
	call :cfa_check
	call :powershell_check

	if !_WINVER! GEQ 10 (
		if !_IS_CFA_ENABLED!==1 (
			if defined _PWSH_CMD (
                echo %cInfo%[~] Whitelisting the game executable^(s^) in Controlled Folder Access...%cReset%

				if exist "%_INSTALL_LOCATION%\DSLOA.exe" (
					echo Whitelisting DSLOA.exe...
					!_PWSH_CMD! Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DSLOA.exe' > nul 2>&1
				)

				if exist "%_INSTALL_LOCATION%\DSLOAMod.exe" (
					echo Whitelisting DSLOAMod.exe...
					!_PWSH_CMD! Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DSLOAMod.exe' > nul 2>&1
				)

				if exist "%_INSTALL_LOCATION%\DSMod.exe" (
					echo Whitelisting DSMod.exe...
					!_PWSH_CMD! Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DSMod.exe' > nul 2>&1
				)

				if exist "%_INSTALL_LOCATION%\DSVideoConfig.exe" (
					echo Whitelisting DSVideoConfig.exe...
					!_PWSH_CMD! Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DSVideoConfig.exe' > nul 2>&1
				)

				if exist "%_INSTALL_LOCATION%\DungeonSiege.exe" (
					echo Whitelisting DungeonSiege.exe...
					!_PWSH_CMD! Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DungeonSiege.exe' > nul 2>&1
				)
				
                echo %cSuccess%[+] Game executable^(s^) successfully whitelisted.%cReset%
				ping -n 2 127.0.0.1 > nul
			) else (
                echo %cError%[-] Execution aborted: Powershell is not installed.%cReset%
			)
		) else (
            echo %cInfo%[i] Controlled Folder Access is disabled, nothing to do.%cReset%
		)
	) else (
        echo %cInfo%[i] You're not on Windows 10 or newer, nothing to do.%cReset%
	)
)

setlocal DisableDelayedExpansion
goto end

:gmax
echo %cInfo%[~] Checking for the Gmax executable...%cReset%

if exist gmax.exe (
    echo %cInfo%[~] Adding the environment variable for Gmax...%cReset%
	setx GMAXLOC "%CD%" > nul
	echo %cSuccess%[+] Gmax environment variable successfully added.%cReset%
	ping -n 2 127.0.0.1 > nul
) else (
    echo %cError%[-] ERROR: gmax.exe not found in the current directory.%cReset%
    echo %cInfo%[i] Make sure to run the reg patch from your Gmax installation directory.%cReset%
	echo:
	set "_CHOICE="
	pause
	cls
	goto menu
)

goto end

:update
echo %cInfo%[i] Comparing the local version against the version on GitHub...%cReset%
ping -n 2 127.0.0.1 > nul

rem Download repo version file
set "_URL=https://raw.githubusercontent.com/GenesisFR/RegPatches/refs/heads/master/RegPatchDS1_version.txt"
curl --connect-timeout 3 -o "%TEMP%\RegPatchDS1_version.txt" "%_URL%" > nul 2>&1
for /f %%G in ('type "%TEMP%\RegPatchDS1_version.txt"') do set _REPO_VERSION=%%G
del %TEMP%\RegPatchDS1_version.txt

rem Compare version numbers (without dots)
if %_VERSION:.=% LSS %_REPO_VERSION:.=% (
    echo %cInfo%[i] A new version ^(%_REPO_VERSION%^) is available.%cReset%
	echo:
) else (
    echo %cInfo%[i] You already have the latest version.%cReset%
	goto end
)

set "_URL=https://raw.githubusercontent.com/GenesisFR/RegPatches/refs/heads/master/RegPatchDS1.bat"
echo %cTitle%Would you like to download it? [Y,N]: %cReset%
choice > nul

if %ERRORLEVEL%==1 (
    echo %cInfo%[~] Downloading the new reg patch...%cReset%
	rem curl was added in Windows 10 (1803)
	curl --connect-timeout 5 -o "%TEMP%\RegPatchDS1.bat" "%_URL%" > nul 2>&1

	rem Fall back to bitsadmin if curl failed or isn't installed
	if %ERRORLEVEL% NEQ 0 (
		rem Requires Support Tools on XP
		rem https://www.majorgeeks.com/files/details/microsoft_windows_xp_service_pack_2_support_tools.html
		bitsadmin /transfer updateJob /download /priority foreground "%_URL%" "%TEMP%\RegPatchDS1.bat" > nul 2>&1
		rem bitsadmin /create /download updateJob
		rem bitsadmin /addfile updateJob "%_URL%" "%TEMP%\RegPatchDS1.bat"
		rem bitsadmin /setmaxdownloadtime updateJob 5
		rem bitsadmin /resume updateJob
		rem bitsadmin /reset
	)

	if exist "%TEMP%\RegPatchDS1.bat" (
		echo %cSuccess%[+] Update complete.%cReset%
		ping -n 2 127.0.0.1 > nul
		rem After replacing the BAT, execution seems to stop so we call :end beforehand
		call :end
		move /Y "%~f0" "%~dpn0.v%_VERSION%.bat.bak" > nul
		move /Y "%TEMP%\RegPatchDS1.bat" "%~f0" > nul
	) else (
		echo %cError%[-] Update failed: you probably don't have an internet connection..%cReset%
		echo %cInfo%[i] If you're on Windows XP, make sure you have Support Tools installed.%cReset%
		echo %cInfo%[~] The repository will now be opened in your web browser.%cReset%
		pause
		start "" https://github.com/GenesisFR/RegPatches
	)
)

goto end

:usage
echo Usage:
echo:
if not defined _LINUX (
	echo %~0 -c X ^(where X is a number between 1 and 10^)
) else (
	echo %~0 -c X ^(where X is a number between 1 and 7^)
)

:end
echo:
echo %cTitle%===============================================================================%cReset%
echo %cInfo%[~] Exiting...%cReset%
echo %cTitle%===============================================================================%cReset%
echo:
pause
endlocal
