@echo off
@setlocal enableextensions

title Reg Patcher for Beyond Good and Evil by Genesis (v1.0)

rem Checking if run from Linux
if defined WINEPREFIX goto init

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
set _BGE=HKLM\Software\ubisoft\Beyond Good ^& Evil
set _BGE_EXPORT=HKEY_LOCAL_MACHINE\Software\Wow6432Node\ubisoft\Beyond Good ^^^& Evil
set _REG_ARG=/reg:32
set _REG_FILE=%~n0.reg

rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS% == 32 (
    set _BGE_EXPORT=HKEY_LOCAL_MACHINE\Software\ubisoft\Beyond Good ^^^& Evil
    set _REG_ARG=
)

if defined WINEPREFIX (
    set _BGE_EXPORT=HKEY_LOCAL_MACHINE\Software\ubisoft\Beyond Good ^^^& Evil
    set _REG_ARG=
)

rem Selection menu
echo Please make a selection:
echo.
echo 1. Add registry entries for Beyond Good and Evil (needed for SettingsApplication.exe)
echo 2. Export registry entries to a REG file (useful on Linux)
echo 3. Remove registry entries
echo 4. Exit
echo.

rem Automatically make a selection in case of arguments
if defined _CHOICE (
    choice /C:1234 /N /T 0 /D %_CHOICE% 
) else (
    choice /C:1234 /N
)

if %ERRORLEVEL% == 1 goto BGE
if %ERRORLEVEL% == 2 goto export
if %ERRORLEVEL% == 3 goto cleanup
if %ERRORLEVEL% == 4 exit /B

:BGE
echo Adding registry entries for Beyond Good and Evil...

REG ADD "%_BGE%" /v "Install Path" /t REG_SZ /d "%CD%" /f %_REG_ARG% > nul

echo DONE
goto end

:export
echo REGEDIT4> %_REG_FILE%
echo.>> %_REG_FILE%

echo Exporting registry entries for Beyond Good and Evil...

echo [%_BGE_EXPORT%]>> %_REG_FILE%
echo "Install Path"="%_CD_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE
echo.
echo A new file called "%_REG_FILE%" has been created in the current directory.

goto end

:cleanup
echo Removing registry entries for Beyond Good and Evil...
REG DELETE "%_BGE%" /f %_REG_ARG% > nul

echo DONE
goto end

:end
echo.
pause
endlocal
