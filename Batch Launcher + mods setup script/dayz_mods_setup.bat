@echo off
REM DayZ Server Mod Setup Script

REM Set server location to the directory of this script
set "scriptDir=%~dp0"

REM Initialize mods variable
set "mods="

REM Ensure the keys folder exists
if not exist "%scriptDir%\keys" (
    mkdir "%scriptDir%\keys"
)

REM Clear screen
cls

REM Prompt user to add all mods to mods.cfg
echo Mods found.

:serverMods_Prompt
echo.
echo In your launcher.bat script, you will find a line like this: "-mod=@mod1;@mod2;@mod3"
echo Replace "-mod=" with the contents of mods.cfg.
echo.
set /p "addMods=Do you want this script to setup everything required for mods? (Y/N): "

REM Clear all text in the mods.cfg file
type nul > "%scriptDir%\mods.cfg"

REM Validate user input
REM Use /I for case-insensitive comparison
if /i "%addMods%"=="Y" (
    REM Search for .bikey files in nested "put-mods-here" folders and copy them to "%scriptDir%\keys"
    echo Copying .bikey files to keys folder...
    setlocal enabledelayedexpansion
    for /R "%scriptDir%\put-mods-here" %%G in (*.bikey) do (
        echo Copying %%~nxG to keys folder...
        copy "%%G" "%scriptDir%\keys\"
    )
    endlocal

    REM Loop through each subfolder in put-mods-here and construct the mods variable
    for /D %%F in ("%scriptDir%\put-mods-here\*") do (
        REM Write folder names to mods.cfg
        echo %%~nxF >> "%scriptDir%\mods.cfg"

        REM Move mod folders to the server's root directory
        echo Moving folder %%~nxF to server root...
        move "%%F" "%scriptDir%"
    )

    echo This file prevents the mods setup prompt from appearing on the next launch. > "%scriptDir%\setup_mods_marker.txt"

) else if /i "%addMods%"=="N" (
    goto :serverMods_Prompt

) else (
    REM Invalid choice handling
    echo Error: Invalid choice. Please enter either Y or N.
    timeout /t 5 >nul
    goto serverMods
)

REM Display mods variable for verification (optional)
echo.
echo Mods written to mods.cfg:
type "%scriptDir%\mods.cfg"

echo.
echo Mods and .bikey files processed successfully.
echo Setup complete.
echo.

REM Pause at the end of the script and exit
echo Press any key to continue.
pause >nul
exit /b
