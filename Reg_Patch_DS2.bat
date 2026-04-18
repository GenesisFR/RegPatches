@echo off
setlocal

title Reg Patcher for Dungeon Siege 2 by Genesis (v1.54)
echo You can find the latest version or report issues at https://github.com/GenesisFR/RegPatches.
echo:

:linux_check
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
	rem It must be a digit between 1 and 7 to match the choices below
	if "%~2"=="1" set "_CHOICE=%~2"
	if "%~2"=="2" set "_CHOICE=%~2"
	if "%~2"=="3" set "_CHOICE=%~2"
	if "%~2"=="4" set "_CHOICE=%~2"
	if "%~2"=="5" set "_CHOICE=%~2"

	if not defined _LINUX (
		if "%~2"=="6" set "_CHOICE=%~2"
		if "%~2"=="7" set "_CHOICE=%~2"
	)

	if not defined _CHOICE goto usage
) else goto usage

rem Skip the admin check on Linux, otherwise we'll be stuck in an endless loop
if defined _LINUX goto init

:admin_check
rem https://ss64.com/vb/syntax-elevate.html
rem Restart the script as admin if it wasn't the case already
echo Checking if the script is run as admin...
fsutil dirty query %SystemDrive% > nul

if %ERRORLEVEL%==0 (
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
set "_PROGRAM_FILES=%ProgramFiles(x86)%"

if %PROCESSOR_ARCHITECTURE%==x86 (
	if not defined PROCESSOR_ARCHITEW6432 (
		set "_OS_BITNESS=32"
		set "_PROGRAM_FILES=%ProgramFiles%"
	)
)

rem Shortcuts for registry stuff
set "_2K_BW=HKLM\Software\2K Games\Dungeon Siege 2 Broken World"
set "_2K_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\2K Games\Dungeon Siege 2 Broken World"
set "_GPG_BW=HKLM\Software\Gas Powered Games\Dungeon Siege 2 Broken World"
set "_GPG_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000"
set "_MS_DS2=HKLM\Software\Microsoft\Microsoft Games\DungeonSiege2"
set "_MS_DS2_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Microsoft Games\DungeonSiege2"
set "_REG_ARG=/reg:32"
set "_REG_FILE=%~n0.reg"
set "_REG_KEY_GOG=HKLM\SOFTWARE\Wow6432Node\GOG.com\Games\1837106902"
set "_REG_KEY_STEAM=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 39200"

rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS%==32 (
	set "_2K_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\2K Games\Dungeon Siege 2 Broken World"
	set "_GPG_BW_EXPORT=HKEY_LOCAL_MACHINE\Software\Gas Powered Games\Dungeon Siege 2 Broken World\1.00.0000"
	set "_MS_DS2_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege2"
	set "_REG_ARG="
	set "_REG_KEY_GOG=HKLM\SOFTWARE\GOG.com\Games\1837106902"
)

:exe_check
rem Check for the game executable in the current directory
echo Current directory: %CD%
echo:
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
echo:
echo Searching for the game Steam installation directory...

for /F "tokens=2*" %%A in ('reg query "%_REG_KEY_STEAM%" /v InstallLocation 2^>nul') do set "_INSTALL_LOCATION=%%B"

if "%_INSTALL_LOCATION%"=="" (
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
echo:
echo Searching for the game GOG installation directory...

for /F "tokens=2*" %%A in ('reg query "%_REG_KEY_GOG%" /v path 2^>nul') do set "_INSTALL_LOCATION=%%B"

if "%_INSTALL_LOCATION%"=="" (
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
echo:
echo Please make a selection:
echo:
echo 1. Add registry entries for Dungeon Siege 2 and Dungeon Siege 2: Broken World
echo 2. Add registry entries for Dungeon Siege 2 (needed for BW, Elys DS2 and the DS2 Tool Kit)
echo 3. Add registry entries for Dungeon Siege 2: Broken World (needed for Elys DS2BW and OpenSpy)
echo 4. Remove registry entries for both games
echo 5. Export registry entries to a REG file (to import them manually)

if not defined _LINUX (
	echo 6. Create a directory junction in Program Files ^(useful for GameRanger^)
	echo 7. Add the game executable^(s^) to the list of allowed applications in Controlled Folder Access ^(useful on Windows 10/11^)
	echo 8. Exit
) else (
	echo 6. Exit
)

echo:
echo Note: if you're not sure which option to select, just press 1.
echo:

rem Automatically make a selection if arguments were passed
if not defined _LINUX (
	if defined _CHOICE (
		choice /C:1234567 /N /T 0 /D %_CHOICE%
	) else (
		choice /C:12345678 /N
	)
) else (
	if defined _CHOICE (
		choice /C:12345 /N /T 0 /D %_CHOICE%
	) else (
		choice /C:123456 /N
	)
)

echo:

if %ERRORLEVEL%==1 call :ds2 & echo: & call :ds2bw & goto end
if %ERRORLEVEL%==2 call :ds2 & goto end
if %ERRORLEVEL%==3 call :ds2bw & goto end
if %ERRORLEVEL%==4 goto cleanup
if %ERRORLEVEL%==5 goto export
if not defined _LINUX (
	if %ERRORLEVEL%==6 goto junction
	if %ERRORLEVEL%==7 goto controlled
	if %ERRORLEVEL%==8 exit /B
) else (
	if %ERRORLEVEL%==6 exit /B
)

:ds2
echo Adding registry entries for Dungeon Siege 2...

(
	reg add "%_MS_DS2%" /v "AppPath" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG%
	reg add "%_MS_DS2%" /v "InstallationDirectory" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG%
	reg add "%_MS_DS2%" /v "PID" /t REG_SZ /d "00000-000-0000000-00000" /f %_REG_ARG%
) > nul

echo DONE
exit /B

:ds2bw
echo Adding registry entries for Dungeon Siege 2: Broken World...

(
	reg add "%_2K_BW%" /v "AppPath" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG%
	reg add "%_2K_BW%" /v "InstallationDirectory" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG%
	reg add "%_2K_BW%" /v "PID" /t REG_SZ /d "0000-0000-0000-0000" /f %_REG_ARG%
	reg add "%_GPG_BW%\1.00.0000" /v "InstallLocation" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG%
) > nul

echo DONE
exit /B

:cleanup
echo Removing registry entries for Dungeon Siege 2 and Broken World...
reg delete "%_MS_DS2%" /f %_REG_ARG% > nul 2>&1
reg delete "%_2K_BW%" /f %_REG_ARG% > nul 2>&1
reg delete "%_GPG_BW%" /f %_REG_ARG% > nul 2>&1
echo DONE
goto end

:export
rem https://alt.msdos.batch.narkive.com/LNB84uUc/replace-all-backslashes-in-a-string-with-double-backslash
rem Double backslashes in the install directory path
set "_INSTALL_LOCATION_DOUBLE_BACKSLASH=%_INSTALL_LOCATION:\=\\%"

echo Exporting registry entries for Dungeon Siege 2 and Broken World...

(
	echo REGEDIT4
	echo:
	echo [%_MS_DS2_EXPORT%]
	echo "AppPath"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
	echo "InstallationDirectory"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
	echo "PID"="0000-0000-0000-0000"
	echo:
	echo [%_2K_BW_EXPORT%]
	echo "AppPath"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
	echo "InstallationDirectory"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
	echo "PID"="0000-0000-0000-0000"
	echo:
	echo [%_GPG_BW_EXPORT%]
	echo "InstallLocation"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%"
) > %_REG_FILE%

echo DONE
echo:
echo A new file called "%_REG_FILE%" has been created in the current directory.

goto end

:junction
rem https://stackoverflow.com/a/8071683
rem Get the install directory name
for %%a in ("%_INSTALL_LOCATION%") do set "_INSTALL_DIRECTORY_NAME=%%~nxa"

if exist "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" rmdir /Q "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" > nul
mklink /J "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" "%_INSTALL_LOCATION%"

if %ERRORLEVEL%==0 (
	echo:
	echo You can now select the game's executable from "%_PROGRAM_FILES%\%_INSTALL_DIRECTORY_NAME%" to add the game to GameRanger.
	echo:
	echo Warning: do NOT move the directory junction somewhere else as it will also move your entire game directory!
	echo It can safely be renamed or deleted.
)

goto end

:controlled
echo Adding the game executable(s) to the list of allowed applications in Controlled Folder Access...

if not defined WINEPREFIX (
	if exist "%_INSTALL_LOCATION%\DS2VideoConfig.exe" (
			echo Adding DS2VideoConfig.exe...
			PowerShell Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DS2VideoConfig.exe' > nul 2>&1
			pwsh Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DS2VideoConfig.exe' > nul 2>&1
	)

	if exist "%_INSTALL_LOCATION%\DungeonSiege2.exe" (
		echo Adding DungeonSiege2.exe...
		PowerShell Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DungeonSiege2.exe' > nul 2>&1
		pwsh Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DungeonSiege2.exe' > nul 2>&1
	)

	if exist "%_INSTALL_LOCATION%\DungeonSiege2Mod.exe" (
		echo Adding DungeonSiege2Mod.exe...
		PowerShell Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DungeonSiege2Mod.exe' > nul 2>&1
		pwsh Add-MpPreference -ControlledFolderAccessAllowedApplications '%_INSTALL_LOCATION%\DungeonSiege2Mod.exe' > nul 2>&1
	)
)

echo DONE
goto end

:usage
echo Usage:
echo:
if not defined _LINUX (
	echo %~0 -c X ^(where X is a number between 1 and 7^)
) else (
	echo %~0 -c X ^(where X is a number between 1 and 5^)
)

:end
echo:
pause
