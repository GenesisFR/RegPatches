@echo off

title Reg Patcher for Dungeon Siege 1 by Genesis (v1.4)

rem https://ss64.com/vb/syntax-elevate.html
echo Checking if the script is run as admin...

fsutil dirty query %SYSTEMDRIVE% > nul

if %ERRORLEVEL%% == 0 (
    echo OK
) else (
    echo ERROR: admin rights not detected.
    echo.
    echo The script will now restart as admin.

    echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\ElevateMe.vbs"
    echo UAC.ShellExecute """%~f0""", "", "", "runas", 1 >> "%TEMP%\ElevateMe.vbs"

    "%TEMP%\ElevateMe.vbs"
    del "%TEMP%\ElevateMe.vbs"
    
    exit /B
)

echo.

rem https://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
rem Correct current directory when a script is run as admin
@setlocal enableextensions
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
set _REG_FILE=Reg_Patch_DS1.reg

echo Please make a selection:
echo.
echo 1. Add registry entries for Dungeon Siege 1 (needed for LOA and the DS1 Tool Kit)
echo 2. Add registry entries for Dungeon Siege 1 Lands of Aranna (needed for DSLOAMod)
echo 3. Create a directory junction in Program Files (useful for GameRanger)
echo 4. Export registry entries to a REG file (useful on Linux)
echo 5. Remove registry entries for both games
echo 6. Exit
echo.
echo Note: if you're not sure which option to select, just press 1.
echo.
choice /c 123456 /N

IF %ERRORLEVEL% == 1 goto DS1
IF %ERRORLEVEL% == 2 goto DS1LOA
IF %ERRORLEVEL% == 3 goto junction
IF %ERRORLEVEL% == 4 goto export
IF %ERRORLEVEL% == 5 goto cleanup
IF %ERRORLEVEL% == 6 exit /B

:DS1
echo Adding registry entries for Dungeon Siege 1...

REG ADD "%_MS_DS%\1.0" /v "EXE Path" /t REG_SZ /d "%CD%" /f /reg:32 > nul

echo DONE
goto end

:DS1LOA
echo Adding registry entries for Dungeon Siege 1: Lands of Aranna...

REG ADD "%_MS_LOA%\1.0" /v "EXE Path" /t REG_SZ /d "%CD%" /f /reg:32 > nul

echo DONE
goto end

:junction
rem https://stackoverflow.com/a/8071683
rem Get the current directory name
for %%a in (.) do set _CURRENT_DIRECTORY=%%~nxa

if exist "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" rmdir /Q "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" > nul
mklink /J "%_PROGRAM_FILES%\%_CURRENT_DIRECTORY%" "%CD%"

IF %ERRORLEVEL% == 0 (
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
REG DELETE "%_MS_DS%" /f /reg:32 > nul
echo DONE
echo.

echo Removing registry entries for Dungeon Siege 1: Broken World...
REG DELETE "%_MS_LOA%" /f /reg:32 > nul

echo DONE

:end
echo.
pause
endlocal
