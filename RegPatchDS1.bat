@echo off
setlocal

rem You can find the latest version or report issues at https://github.com/GenesisFR/RegPatches.
set "_VERSION=1.60"
title Reg Patcher for Dungeon Siege 1 by Genesis (v%_VERSION%)
echo:

rem ===============================================================================================
rem ======================================= PRE-MENU CHECKS =======================================
rem ===============================================================================================

:linux_check
rem https://www.reddit.com/r/Batch/comments/odynta/check_whether_bat_is_run_from_wine
rem Test a few commands to determine if we're on Linux
fsutil | find "dirty" > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"
break > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"
dir /N > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"
dir /4 > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"
dpath > nul 2>&1
if not %ERRORLEVEL%==0 set "_LINUX=1"

if defined _LINUX goto parse_args

:windows_version
rem Store the Windows version
for /F "tokens=2 delims=[]" %%G in ('ver') do set "_WINVER=%%G"

rem Merge the major and minor version (without the dot for numerical comparisons)
rem major=%%G minor=%%H build=%%I
for /F "tokens=2,3,4 delims=. " %%G in ('echo %_WINVER%') do set "_WINVER=%%G%%H" & set "_BUILD=%%I"

rem 50 = Windows 2000
rem 51 = Windows XP
rem 52 = Windows Server 2003
rem 60 = Windows Vista / Windows Server 2008
rem 61 = Windows 7 / Windows Server 2008 R2
rem 62 = Windows 8 / Windows Server 2012
rem 63 = Windows 8.1 / Windows Server 2012 R2
rem 1001xxxx = Windows 10 / Windows Server 2016/2019/2022
rem 1002xxxx = Windows 11

rem The script won't work properly before Windows 2000
if %_WINVER% LSS 50 echo [-] ERROR: Only Windows 2000 or later is supported! & goto end

rem Don't enable multi-color output on unsupported systems (before Windows 10 1909)
if %_WINVER% LSS 100 goto parse_args
if %_WINVER%==100 if %_BUILD% LSS 18363 goto parse_args

:multi_color
rem https://web.archive.org/web/20251127131301/https://www.dostips.com/forum/viewtopic.php?f=3&t=8044&p=53478#p53478
rem Set up ANSI escape character for multi-color output on Windows 10 or later
for /F %%G in ('echo prompt $E ^| cmd') do set "ESC=%%G"
set "cReset=%ESC%[0m"
set "cTitle=%ESC%[96m"
set "cMenu=%ESC%[93m"
set "cSuccess=%ESC%[92m"
set "cError=%ESC%[91m"
set "cInfo=%ESC%[94m"
set "cDim=%ESC%[90m"

:parse_args
rem Check and validate arguments
if "%~1"=="" goto admin_check
if /I not "%~1"=="-c" goto usage

rem Convert empty arguments or strings to 0
set /A "_CHOICE=%~2 + 0"

rem It must be a digit between 1 and 10 (6 on Linux) to match the choices below
if %_CHOICE% LSS 1 goto usage
if %_CHOICE% GTR 10 goto usage
if defined _LINUX if %_CHOICE% GTR 6 goto usage

:admin_check
call :display_header

rem Skip the admin check on Linux, otherwise we'll be stuck in an endless loop since there's no VBScript or UAC
if defined _LINUX goto init

rem https://ss64.com/vb/syntax-elevate.html
rem Restart the script as admin if it wasn't the case already
echo %cInfo%[~] Checking if the script is run as admin...%cReset%
ping -n 2 127.0.0.1 > nul
fsutil dirty query %SystemDrive% > nul

if not %ERRORLEVEL%==0 (
	echo %cError%[-] ERROR: administrator rights required.%cReset%
	ping -n 2 127.0.0.1 > nul
	echo %cInfo%[~] Attempting to elevate privileges via UAC...%cReset%

	echo set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\ElevateMe.vbs"
	echo UAC.ShellExecute """%~f0""", "%*", "", "runas", 1 >> "%TEMP%\ElevateMe.vbs"

	"%TEMP%\ElevateMe.vbs"
	del "%TEMP%\ElevateMe.vbs"

	exit /B
)

echo %cSuccess%[+] Administrator rights detected.%cReset%
echo:
ping -n 2 127.0.0.1 > nul

:init
rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct the current directory when a script is run as admin
cd /D "%~dp0"

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

rem Other important variables
set "_COMSPEC=%SystemRoot%\system32\cmd.exe"
set "_PROGRAM_FILES=%ProgramFiles(x86)%"

rem https://ss64.com/nt/syntax-64bit.html
rem Check if we're on a 32-bit system
if %PROCESSOR_ARCHITECTURE%==x86 (
	if not defined PROCESSOR_ARCHITEW6432 (
		set "_PROGRAM_FILES=%ProgramFiles%"

		rem WOW6432Node and /reg:32 aren't present on 32-bit systems
		set "_MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege\1.0"
		set "_MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0"
		set "_REG_ARG="
		set "_REG_KEY_GOG=HKLM\SOFTWARE\GOG.com\Games\1185868626"
	)
)

:exe_check
echo %cInfo%[~] Current directory:%cReset% %CD%
echo %cInfo%[~] Scanning for game executables...%cReset%
echo %cDim%--------------------------------------------------------------------------------%cReset%
ping -n 2 127.0.0.1 > nul

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
	echo %cError%[-] ERROR: DungeonSiege.exe and DSLOA.exe not found in the current directory.%cReset%
	ping -n 2 127.0.0.1 > nul

	rem Steam/GOG don't update the Wine registry when installing games so we skip the install detection
	if defined _LINUX echo %cInfo%[i] Please place this script inside your Dungeon Siege installation directory.%cReset% & goto end
)

rem Check for the game executables in the Steam installation directory, then GOG if not found
call :install_detection Steam "%_REG_KEY_STEAM%" InstallLocation
if %ERRORLEVEL%==1 call :install_detection GOG "%_REG_KEY_GOG%" path

if %ERRORLEVEL%==1 (
	echo %cError%[-] ERROR: could not locate the game installation directory.%cReset%
	ping -n 2 127.0.0.1 > nul
	echo %cInfo%[i] Please place this script inside your Dungeon Siege installation directory.%cReset%
	goto end
)

:menu
rem Double the trailing backslash of the installation directory as it's interpreted as an escape character by the REG commands, which causes them
rem to not work correctly when the game is installed at the root of a drive
set "_INSTALL_LOCATION_DOUBLE_TRAILING_BACKSLASH=%_INSTALL_LOCATION%"
if "%_INSTALL_LOCATION:~-1%"=="\" set "_INSTALL_LOCATION_DOUBLE_TRAILING_BACKSLASH=%_INSTALL_LOCATION%\"

rem Automatically make a selection if arguments were passed
if defined _CHOICE goto process_choice

rem Selection menu
call :display_header
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
echo %cDim%--------------------------------------------------------------------------------%cReset%

rem List of valid choices
set "_CHOICES=1234567890a"
if defined _LINUX set "_CHOICES=1234567"

echo %cTitle%Please make a selection [1-%_CHOICES:~-1%]:%cReset%
choice /C:%_CHOICES% /N > nul 2>&1

rem choice is missing
if %ERRORLEVEL%==9009 echo %cError%[-] ERROR: Make sure you have the choice command installed.%cReset% & goto end

set "_CHOICE=%ERRORLEVEL%"

:process_choice
call :display_header
echo:

rem That's the result of a Ctrl+C
if %_CHOICE%==0 goto menu

if %_CHOICE%==1 call :ds1 & ping -n 2 127.0.0.1 > nul & echo: & call :ds1loa & goto end
if %_CHOICE%==2 call :ds1 & goto end
if %_CHOICE%==3 call :ds1loa & goto end
if %_CHOICE%==4 goto cleanup
if %_CHOICE%==5 goto export
if %_CHOICE%==6 goto openzone

rem Don't handle Windows-specific options on Linux
if defined _LINUX exit /B

if %_CHOICE%==7 goto junction
if %_CHOICE%==8 goto cfa_whitelist_all
if %_CHOICE%==9 goto gmax
if %_CHOICE%==10 goto update
if %_CHOICE%==11 exit /B

rem This is only here to help with development since we should never reach this in practice
echo %cError%[-] Invalid choice detected.%cReset% & goto end

rem ===============================================================================================
rem ======================================== CHOICE LABELS ========================================
rem ===============================================================================================

:cfa_whitelist_all
if %_WINVER% LSS 100 echo %cInfo%[i] You're not on Windows 10 or newer.%cReset% & goto end

call :cfa_check
if %_IS_CFA_ENABLED%==0 echo %cInfo%[i] Controlled Folder Access is disabled.%cReset% & goto end

call :powershell_check
if not defined _PWSH_CMD echo %cError%[-] ERROR: Powershell is not installed.%cReset% & goto end

echo %cInfo%[~] Whitelisting the game executable^(s^) in Controlled Folder Access...%cReset%
echo %cDim%--------------------------------------------------------------------------------%cReset%
ping -n 2 127.0.0.1 > nul

for %%G in (DSLOA.exe,DSLOAMod.exe,DSMod.exe,DSVideoConfig.exe,DungeonSiege.exe) do call :cfa_whitelist %%G

echo %cSuccess%[+] Game executable^(s^) successfully whitelisted.%cReset%
goto end

:cleanup
echo %cInfo%[~] Removing registry entries for Dungeon Siege and Legends of Aranna...%cReset%
ping -n 2 127.0.0.1 > nul

(
	reg delete "%_MS_DS%" /F %_REG_ARG%
	reg delete "%_MS_LOA%" /F %_REG_ARG%
) > nul 2>&1

if %ERRORLEVEL%==1 (
	echo %cError%[-] ERROR: failed to remove registry entries.%cReset%
) else (
	echo %cSuccess%[+] SUCCESS: registry entries removed.%cReset%
)

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

if exist %_REG_FILE% (
	echo %cSuccess%[+] SUCCESS: registry entries exported.%cReset%
	echo:
	ping -n 2 127.0.0.1 > nul
	echo %cInfo%[i] They can be imported from the "%_REG_FILE%" file in the current directory.%cReset%
) else (
	echo %cError%[-] ERROR: failed to export registry entries.%cReset%
)

goto end

:gmax
echo %cInfo%[~] Checking for the Gmax executable...%cReset%
echo %cDim%--------------------------------------------------------------------------------%cReset%
ping -n 2 127.0.0.1 > nul

if exist gmax.exe (
	echo %cInfo%[~] Adding the environment variable for Gmax...%cReset%
	setx GMAXLOC "%CD%" > nul
	ping -n 2 127.0.0.1 > nul
	echo %cSuccess%[+] Gmax environment variable successfully added.%cReset%
) else (
	echo %cError%[-] ERROR: gmax.exe not found in the current directory.%cReset%
	ping -n 2 127.0.0.1 > nul
	echo %cInfo%[i] Make sure to run the reg patch from your Gmax installation directory.%cReset%
)

goto end

:junction
rem https://stackoverflow.com/a/8071683
rem Get the install directory name
rem for %%G in ("%_INSTALL_LOCATION%") do set "_INSTALL_DIRECTORY_NAME=%%~nxG"

echo %cInfo%[~] Creating a directory junction for Dungeon Siege...%cReset%
ping -n 2 127.0.0.1 > nul

rem Windows Vista or later
if %_WINVER% GTR 52 (
	if exist "%_PROGRAM_FILES%\Dungeon Siege 1" rmdir /Q "%_PROGRAM_FILES%\Dungeon Siege 1" > nul
	mklink /J "%_PROGRAM_FILES%\Dungeon Siege 1" "%_INSTALL_LOCATION%" > nul 2>&1
rem Windows 2000/XP/Server 2003
) else (
	rem https://learn.microsoft.com/en-us/sysinternals/downloads/junction
	junction -d "%_PROGRAM_FILES%\Dungeon Siege 1" > nul 2>&1
	junction "%_PROGRAM_FILES%\Dungeon Siege 1" "%_INSTALL_LOCATION%" > nul 2>&1
)

if %ERRORLEVEL%==0 (
	echo %cSuccess%[+] SUCCESS: directory junction created.%cReset%
	echo:
	ping -n 2 127.0.0.1 > nul
	echo %cInfo%[i] You can now select the game executable from "%_PROGRAM_FILES%\Dungeon Siege 1" to add the game to GameRanger.%cReset%
	echo %cInfo%[i] It can safely be renamed or deleted.%cReset%
	echo %cMenu%[!] WARNING: do NOT move the directory junction somewhere else as it will also move your entire game directory! %cReset%
) else (
	echo %cError%[-] Failed to create directory junction.%cReset%
)

goto end

:openzone
echo %cInfo%[~] Redirecting the ZoneMatch server to OpenZone...%cReset%
ping -n 2 127.0.0.1 > nul

rem Whitelist the command prompt in Controlled Folder Access (otherwise the ATTRIB and MOVE commands won't work)
call :cfa_whitelist_cmd
if %ERRORLEVEL%==1 goto end
rem Restart the reg patch if necessary (using the same option)
if %ERRORLEVEL%==2 call :end & cls & cmd /C "%~f0" -c %_CHOICE% & exit /B

rem https://serverfault.com/a/701644
rem Get the path to My Documents
for /F "tokens=2*" %%G in ('reg query "%_REG_KEY_SF%" /V "Personal" 2^>nul') do set "_MY_DOCUMENTS=%%H"

if not defined _MY_DOCUMENTS echo %cError%[-] ERROR: couldn't locate the path to My Documents.%cReset% & goto end

set "_CFG_FILE_DS=%_MY_DOCUMENTS%\Dungeon Siege\DungeonSiege.ini"
set "_CFG_FILE_LOA=%_MY_DOCUMENTS%\Dungeon Siege LOA\DungeonSiege.ini"

setlocal EnableDelayedExpansion

rem Update the config files if they exist
for %%G in ("%_CFG_FILE_DS%","%_CFG_FILE_LOA%") do (
	set "_CFG_FILE=%%~G"

	if exist "!_CFG_FILE!" (
		set "_CFG_FILE_FOUND=1"
		call :openzone_edit_ini "!_CFG_FILE!"

		rem Overwrite the config file (even if it was read-only)
		attrib -R "!_CFG_FILE!"
		move /Y "!_CFG_FILE!.tmp" "!_CFG_FILE!" > nul
	)
)

setlocal DisableDelayedExpansion

if defined _CFG_FILE_FOUND (
	echo %cSuccess%[+] SUCCESS: ZoneMatch server redirected to OpenZone.%cReset%
) else (
	echo %cError%[-] No config file found! Make sure to run the game at least once to generate it.%cReset%
	if %_IS_CFA_ENABLED%==1 echo %cError%[-] The game executable should be whitelisted in Controlled Folder Access beforehand.%cReset%
)

goto end

:update
call :powershell_check

rem Create an empty file to check if we have write permissions in the current directory
copy nul empty > nul 2>&1

if not exist empty (
	echo %cError%[-] ERROR: The Windows Command Prompt cannot write to the current directory.%cReset%
	ping -n 2 127.0.0.1 > nul

	setlocal EnableDelayedExpansion
	rem Whitelist the command prompt in Controlled Folder Access (otherwise the COPY and MOVE commands won't work)
	call :cfa_whitelist_cmd
	if !ERRORLEVEL!==1 goto end
	rem Restart the reg patch if necessary (using the same option)
	if !ERRORLEVEL!==2 call :end & cls & cmd /C "%~f0" -c %_CHOICE% & exit /B
	setlocal DisableDelayedExpansion
)

del empty
echo %cInfo%[~] Downloading the version file from GitHub...%cReset%
ping -n 2 127.0.0.1 > nul

rem Download the version file from the repo
set "_URL=https://raw.githubusercontent.com/GenesisFR/RegPatches/refs/heads/master/RegPatchDS1_version.txt"
set "_FILE=%TEMP%\RegPatchDS1_version.txt"
call :download "%_URL%" "%_FILE%"

rem No internet connection
if %ERRORLEVEL%==404 goto end
rem All download methods failed, open the repo
if %ERRORLEVEL%==1 call :open_repo & goto end

echo %cDim%--------------------------------------------------------------------------------%cReset%
ping -n 2 127.0.0.1 > nul
echo %cInfo%[~] Comparing the local version against the version on GitHub...%cReset%
ping -n 2 127.0.0.1 > nul

rem Store the file content into a variable
for /F "usebackq" %%G in ("%_FILE%") do set _REPO_VERSION=%%G
del "%_FILE%"

rem Compare version numbers (without dots)
if %_VERSION:.=% GEQ %_REPO_VERSION:.=% echo %cInfo%[i] You already have the latest version.%cReset% & goto end

echo %cInfo%[i] A new version ^(%_REPO_VERSION%^) is available! %cReset%
echo:
echo %cTitle%Would you like to update? [Y,N]%cReset%
choice /N > nul 2>&1

rem choice is missing
if %ERRORLEVEL%==9009 echo %cError%[-] ERROR: Make sure you have the choice command installed.%cReset%

if not %ERRORLEVEL%==1 goto end

echo %cDim%--------------------------------------------------------------------------------%cReset%
echo %cInfo%[~] Downloading the new reg patch...%cReset%
ping -n 2 127.0.0.1 > nul

rem Download the reg patch from the repo
set "_URL=https://raw.githubusercontent.com/GenesisFR/RegPatches/refs/heads/master/RegPatchDS1.bat"
set "_FILE=%TEMP%\RegPatchDS1.bat"
call :download "%_URL%" "%_FILE%"

rem No internet connection
if %ERRORLEVEL%==404 goto end
rem All download methods failed, open the repo
if %ERRORLEVEL%==1 call :open_repo & goto end

rem Back up the old reg patch
copy /Y "%~f0" "%~dpn0.v%_VERSION%.bat" > nul 2>&1
ping -n 2 127.0.0.1 > nul
if exist "%~dpn0.v%_VERSION%.bat" echo %cInfo%[i] A copy of the old reg patch was created as "%~dpn0.v%_VERSION%.bat".%cReset%

rem And replace it with the new one
attrib -R "%~0" > nul 2>&1
ping -n 2 127.0.0.1 > nul
move /Y "%_FILE%" "%~f0" > nul 2>&1 && echo %cSuccess%[+] Update complete.%cReset% & call :end & exit /B

rem ===============================================================================================
rem ========================================= SUBROUTINES =========================================
rem ===============================================================================================

:cfa_check
rem Check in the registry if Controlled Folder Access is enabled
for /F "tokens=2*" %%G in ('reg query "%_REG_KEY_CFA%" /V "EnableControlledFolderAccess" 2^>nul') do set "_IS_CFA_ENABLED=%%H"

if not defined _IS_CFA_ENABLED set "_IS_CFA_ENABLED=0" & exit /B

rem Avoids a problem on Linux since error messages are sent to STDOUT (1) instead of STDERR (2)
if defined _LINUX set "_IS_CFA_ENABLED=0" & exit /B

rem The value in the registry is hexadecimal so we need to convert it to decimal
set /A "_IS_CFA_ENABLED=%_IS_CFA_ENABLED%"

exit /B

:cfa_whitelist [exe]
if exist "%_INSTALL_LOCATION%\%1" (
	echo %cInfo%[~] Whitelisting %1... %cReset%
	%_PWSH_CMD% Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\%1' > nul 2>&1
)

exit /B

:cfa_whitelist_cmd
call :cfa_check
if %_IS_CFA_ENABLED%==0 exit /B 0

rem Controlled Folder Access doesn't exist on Linux
if defined _LINUX exit /B 0
rem Or before Windows 10
if %_WINVER% LSS 100 exit /B 0

rem Check in the registry if the command prompt has already been whitelisted
for /F "tokens=2*" %%G in ('reg query "%_REG_KEY_CFA%\AllowedApplications" /V "%_COMSPEC%" 2^>nul') do exit /B 0

call :powershell_check
if not defined _PWSH_CMD echo %cError%[-] ERROR: Powershell is not installed.%cReset% & exit /B 1

echo %cInfo%[i] The Windows Command Prompt needs to be whitelisted in Controlled Folder Access.%cReset%
echo:
ping -n 2 127.0.0.1 > nul
pause
echo:

%_PWSH_CMD% Add-MpPreference -ControlledFolderAccessAllowedApplications '%_COMSPEC%' > nul 2>&1

echo %cSuccess%[+] Whitelisting successful.%cReset%
ping -n 2 127.0.0.1 > nul
echo %cInfo%[i] The reg patch will now restart for changes to take effect.%cReset%
ping -n 2 127.0.0.1 > nul

rem This will let us know we need to restart the reg patch because Controlled Folder Access changes don't come into effect until the next session
exit /B 2

:display_header
cls
echo %cTitle%================================================================================%cReset%
echo %cTitle%                 DUNGEON SIEGE 1 REGISTRY PATCHER (v%_VERSION%)                 %cReset%
echo %cTitle%================================================================================%cReset%
exit /B

:download [url] [file_path]
rem Check if we have an internet connection
ping google.com -n 1 -w 1000 > nul
if %ERRORLEVEL%==1 echo %cError%[-] ERROR: no internet connection detected.%cReset% & exit /B 404

rem Requires https://curl.se/windows (installed by default starting from Windows 10)
echo %cInfo%[i] Downloading using curl...%cReset%
curl --connect-timeout 3 -o "%2" "%1" > nul 2>&1

rem Fall back to powershell (installed by default starting from Windows 7)
if not exist "%2" (
	if defined _PWSH_CMD (
		echo %cInfo%[i] Falling back to Powershell...%cReset%
		%_PWSH_CMD% -Command "(New-Object System.Net.WebClient).DownloadFile('%1', '%2')" > nul 2>&1
	)
)

rem Fall back to bitsadmin (may not work on Vista, won't work on older systems)
if not exist "%2" (
	echo %cInfo%[i] Falling back to bitsadmin...%cReset%
	bitsadmin /transfer %~f0 /download /priority foreground "%1" "%2" > nul 2>&1
)

rem We could also try with VBScript as a last resort but this is overkill at this point

if not exist "%2" (
	echo %cError%[-] ERROR: download failed.%cReset%
	ping -n 2 127.0.0.1 > nul
	echo %cInfo%[i] Make sure you have cURL or Powershell 2.0+ installed.%cReset%
	exit /B 1
)

echo %cSuccess%[+] Download complete.%cReset%
exit /B

:ds1
echo %cInfo%[~] Adding registry entries for Dungeon Siege...%cReset%
ping -n 2 127.0.0.1 > nul

reg add "%_MS_DS%\1.0" /V "EXE Path" /t REG_SZ /D "%_INSTALL_LOCATION_DOUBLE_TRAILING_BACKSLASH%" /F %_REG_ARG% > nul

if %ERRORLEVEL%==1 (
	echo %cError%[-] ERROR: failed to add registry entries.%cReset%
) else (
	echo %cSuccess%[+] SUCCESS: registry entries updated.%cReset%
)

exit /B

:ds1loa
echo %cInfo%[~] Adding registry entries for Legends of Aranna...%cReset%
ping -n 2 127.0.0.1 > nul

reg add "%_MS_LOA%\1.0" /V "EXE Path" /t REG_SZ /D "%_INSTALL_LOCATION_DOUBLE_TRAILING_BACKSLASH%" /F %_REG_ARG% > nul

if %ERRORLEVEL%==1 (
	echo %cError%[-] ERROR: failed to add registry entries.%cReset%
) else (
	echo %cSuccess%[+] SUCCESS: registry entries updated.%cReset%
)

exit /B

:install_detection [platform] [reg_key] [reg_value]
rem Check where the game is installed from the registry
echo:
echo %cInfo%[~] Searching for the %1 installation directory...%cReset%
ping -n 2 127.0.0.1 > nul

for /F "tokens=2*" %%G in ('reg query %2 /V %3 2^>nul') do set "_INSTALL_LOCATION=%%H"

if not defined _INSTALL_LOCATION echo %cError%[-] ERROR: %1 installation directory not found.%cReset% & exit /B 1

echo %cSuccess%[+] %1 installation directory found: %_INSTALL_LOCATION%%cReset%
echo:
ping -n 2 127.0.0.1 > nul
echo %cInfo%[~] Scanning for game executables...%cReset%
echo %cDim%--------------------------------------------------------------------------------%cReset%
ping -n 2 127.0.0.1 > nul

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
	ping -n 2 127.0.0.1 > nul
	exit /B 1
)

:open_repo
echo %cInfo%[i] The repository will now be opened in your web browser.%cReset%
pause
start "" https://github.com/GenesisFR/RegPatches
exit /B

:openzone_edit_ini [ini]
rem https://tutorialreference.com/batch-scripting/examples/faq/batch-script-how-to-read-and-write-to-an-ini-file
rem Store the beginning of the config file to a temp file
set "_CFG_FILE=%~1"
set "_CFG_FILE_TEMP=%~1.tmp"
set "_IN_SECTION=0"

del /F "%_CFG_FILE_TEMP%" > nul 2>&1

rem https://tutorialreference.com/batch-scripting/examples/faq/batch-script-for-f-loop-reading-file-content-command-output#problem-the-loop-skips-empty-lines
rem We use findstr to preserve empty lines
if not defined _LINUX (
	for /F "eol= tokens=1,* delims=:" %%K in ('findstr /N "^" "%_CFG_FILE%"') do call :openzone_edit_ini_parse_line "%%L"
rem The Wine reimplementation of findstr is missing the /N switch, so we have to use another way. "eol=" creates a weird syntax error on Linux,
rem hence the '*' character that's usually unused
) else (
	for /F "usebackq eol=* delims=" %%L in ("%_CFG_FILE%") do call :openzone_edit_ini_parse_line "%%L"
)

rem We're done parsing the file, append the MP section
call :openzone_edit_ini_append_mp_section "%_CFG_FILE_TEMP%"

exit /B

:openzone_edit_ini_append_mp_section [file]
rem Append the MP section to the file specified
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
) >> "%~1"

exit /B

:openzone_edit_ini_parse_line [line]
rem Read the config file, line by line
set "_LINE=%~1"

rem Parse until we reach the multiplayer section
if "!_LINE:~0,1!"=="[" if "!_LINE:~-1!"=="]" (
	for /F "delims=[]" %%S in ("!_LINE!") do (
		if /I "%%S"=="multiplayer" set "_IN_SECTION=1"
	)
)

rem Write the current line to the temp file until we reach the MP section
if !_IN_SECTION!==0 echo:!_LINE!>> "%_CFG_FILE_TEMP%"

exit /B

:powershell_check
rem Check if Powershell is installed (we could use the WHERE command but it's not included by default on 2000/XP/Server 2003)
for %%G in (powershell.exe) do echo %%~$PATH:G | find "powershell" > nul 2>&1
if %ERRORLEVEL%==0 set "_PWSH_CMD=powershell" & exit /B

for %%H in (pwsh.exe) do echo %%~$PATH:H | find "pwsh" > nul 2>&1
if %ERRORLEVEL%==0 set "_PWSH_CMD=pwsh"

exit /B

:usage
rem Display usage information
call :display_header

set "_LAST_OPTION_ID=10"
if defined _LINUX set "_LAST_OPTION_ID=6"

echo %cInfo%Usage:%cReset%
echo:
echo %cInfo%%~0 -c X ^(where X is a number between 1 and %_LAST_OPTION_ID%^)%cReset%
goto end

:end
ping -n 2 127.0.0.1 > nul
echo:
echo %cTitle%================================================================================%cReset%
echo %cInfo%[~] Exiting...%cReset%
echo %cTitle%================================================================================%cReset%
echo:
pause
endlocal
