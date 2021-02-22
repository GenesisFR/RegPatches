@echo off
@setlocal enableextensions

title Reg Patcher for Dungeon Siege 1 by Genesis (v1.42)

rem Checking and validating arguments
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
set _MS_DS=HKLM\Software\Microsoft\Microsoft Games\DungeonSiege
set _MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\WOW6432Node\Microsoft\Microsoft Games\DungeonSiege\1.0
set _MS_LOA=HKLM\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna
set _MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\WOW6432Node\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0
set _REG_ARG=/reg:32
set _REG_FILE=%~n0.reg

rem WOW6432Node and /reg:32 aren't present on 32-bit systems
if %_OS_BITNESS% == 32 (
    set _MS_DS_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\DungeonSiege\1.0
    set _MS_LOA_EXPORT=HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft Games\Dungeon Siege Legends of Aranna\1.0
    set _REG_ARG=
)

rem Selection menu
echo Please make a selection:
echo.
echo 1. Add registry entries for Dungeon Siege 1 (needed for DSMod and the DS1 Tool Kit)
echo 2. Add registry entries for Dungeon Siege 1 Lands of Aranna (needed for DSLOAMod)
echo 3. Create a directory junction in Program Files (useful for GameRanger)
echo 4. Export registry entries to a REG file (useful on Linux)
echo 5. Remove registry entries for both games
echo 6. Exit
echo.

rem Automatically make a selection in case of arguments
if defined _CHOICE (
    choice /C 123456 /N /T 0 /D %_CHOICE% 
) else (
    choice /C 123456 /N
)

if %ERRORLEVEL% == 1 goto DS1
if %ERRORLEVEL% == 2 goto DS1LOA
if %ERRORLEVEL% == 3 goto junction
if %ERRORLEVEL% == 4 goto export
if %ERRORLEVEL% == 5 goto cleanup
if %ERRORLEVEL% == 6 exit /B

:DS1
echo Adding registry entries for Dungeon Siege 1...

REG ADD "%_MS_DS%\1.0" /v "EXE Path" /t REG_SZ /d "%CD%" /f %_REG_ARG% > nul

echo DONE
goto end

:DS1LOA
echo Adding registry entries for Dungeon Siege 1: Lands of Aranna...

REG ADD "%_MS_LOA%\1.0" /v "EXE Path" /t REG_SZ /d "%CD%" /f %_REG_ARG% > nul

echo DONE
goto end

:junction
rem https://stackoverflow.com/a/8071683
rem Get the current directory name
for %%a in (.) do set _CURRENT_DIRECTORY=%%~nxa

if exist "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" rmdir /Q "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" > nul
mklink /J "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" "%CD%"

if %ERRORLEVEL% == 0 (
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

echo Exporting registry entries for Dungeon Siege 1...

echo [%_MS_DS_EXPORT%]>> %_REG_FILE%
echo "EXE Path"="%_CD_DOUBLE_BACKSLASH%">> %_REG_FILE%
echo.>> %_REG_FILE%

echo DONE
echo.
echo Exporting registry entries for Dungeon Siege 1: Lands of Aranna...

echo [%_MS_LOA_EXPORT%]>> %_REG_FILE%
echo "EXE Path"="%_CD_DOUBLE_BACKSLASH%">> %_REG_FILE%
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

echo Removing registry entries for Dungeon Siege 1: Lands of Aranna...
REG DELETE "%_MS_LOA%" /f %_REG_ARG% > nul

echo DONE

:usage
echo Usage:
echo.
echo %~0 -c X (where X is a number between 1 and 5)
goto end

:end
echo.
pause
endlocal
