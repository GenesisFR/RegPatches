@echo off
setlocal

title Reg Patcher for Beyond Good and Evil by Genesis (v1.1)

:linux_check
rem Check if run from Linux
fsutil | find "dirty" > nul
if %ERRORLEVEL%==1 goto init

:admin_check
rem https://ss64.com/vb/syntax-elevate.html
rem Restart the script as admin if it wasn't the case already
echo Checking if the script is run as admin...
fsutil dirty query %SYSTEMDRIVE% > nul

if %ERRORLEVEL%% == 0 (
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
rem Correct current directory when a script is run as admin
cd /d "%~dp0"

rem https://ss64.com/nt/syntax-64bit.html
rem Check if we're on a 32-bit system
set "_OS_BITNESS=64"
set "_PROGRAM_FILES=%ProgramFiles(x86)%"

if %PROCESSOR_ARCHITECTURE%==x86 (
	if not defined PROCESSOR_ARCHITEW6432 (
		set "_OS_BITNESS=32"
		set "_PROGRAM_FILES=%ProgramFiles%"
	)
)

rem Shortcuts for registry keys
set "_BGE=HKLM\Software\ubisoft\Beyond Good ^& Evil"
set "_BGE_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\ubisoft\Beyond Good ^^^& Evil"
set "_REG_ARG=/reg:32"
set "_REG_FILE=%~n0.reg"
set "_REG_KEY_STEAM=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 15130"

rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS% == 32 (
	set "_BGE_EXPORT=HKEY_LOCAL_MACHINE\Software\ubisoft\Beyond Good ^^^& Evil"
	set "_REG_ARG="
)

:exe_check
rem Check for game executables in the current directory
echo Current directory: %CD%
echo:
echo Checking for the game executable...

if exist BGE.exe (
	set "_INSTALL_LOCATION=%CD%"
	echo OK
	goto menu
) else (
	echo BGE.exe not found in the current directory!
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

	rem Check for game executables in the installation directory
	echo Checking for the game executable...

	if exist "%_INSTALL_LOCATION%\BGE.exe" (
		echo OK
		goto menu
	) else (
		echo BGE.exe not found in the installation directory!
		goto end
	)
)

rem Selection menu
echo Please make a selection:
echo:
echo 1. Add registry entries for Beyond Good and Evil (needed for SettingsApplication.exe)
echo 2. Remove registry entries
echo 3. Export registry entries to a REG file (to import them manually)
echo 4. Exit
echo:

choice /C:1234 /N

if %ERRORLEVEL% == 1 goto bge
if %ERRORLEVEL% == 2 goto cleanup
if %ERRORLEVEL% == 3 goto export
if %ERRORLEVEL% == 4 exit /B

:bge
echo Adding registry entries for Beyond Good and Evil...
reg add "%_BGE%" /v "Install Path" /t REG_SZ /d "%_INSTALL_LOCATION%" /f %_REG_ARG% > nul
echo DONE
goto end

:cleanup
echo Removing registry entries for Beyond Good and Evil...
reg delete "%_BGE%" /f %_REG_ARG% > nul 2>&1
echo DONE
goto end

:export
rem https://alt.msdos.batch.narkive.com/LNB84uUc/replace-all-backslashes-in-a-string-with-double-backslash
rem Double backslashes in the install directory path
set "_INSTALL_LOCATION_DOUBLE_BACKSLASH=%_INSTALL_LOCATION:\=\\%"

echo Exporting registry entries for Beyond Good and Evil...

(
	echo REGEDIT4
	echo:
	echo [%_BGE_EXPORT%]
	echo "Install Path"="%_INSTALL_LOCATION_DOUBLE_BACKSLASH%">> %_REG_FILE%
) > %_REG_FILE%

echo DONE
echo:
echo A new file called "%_REG_FILE%" has been created in the current directory.

goto end

:end
echo:
pause
endlocal
