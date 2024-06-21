@echo off
REM DayZ Server Mod Setup Script

REM Set server location to the directory of this script
set "scriptDir=%~dp0"
set "serverLocation=%scriptDir%"

REM Set log file paths relative to where dayz_mods_setup.bat is located
set "logFile=%serverLocation%logs\dayz_mods_setup.log"

REM Ensure the keys folder exists
if not exist "%serverLocation%\keys" (
    mkdir "%serverLocation%\keys"
)

REM Clear screen
cls

:serverMods
REM Prompt user to add all mods to mods.cfg
echo Mods found.

:serverMods_Prompt
set /p "addMods=Do you want to add all mods to mods.cfg and all .bikey files to Keys folder? (Y/N): "
REM Clear all text in the mods.cfg file
type nul > "%serverLocation%\mods.cfg"

REM Validate user input
REM Use /I for case-insensitive comparison
if /i "%addMods%"=="Y" (
    REM Create an empty mods.cfg file
    type nul > "%serverLocation%\mods.cfg"

    REM Loop through each subfolder in the mods directory and write folder names to mods.cfg
    for /D %%F in ("%serverLocation%\mods\*") do (
        echo %%~nxF >> "%serverLocation%\mods.cfg"
    )

    REM Search for .bikey files in nested "mods" folders and copy them to "%serverLocation%\keys"
    echo Copying .bikey files to keys folder...
    setlocal enabledelayedexpansion
    for /R "%serverLocation%\mods" %%G in (*.bikey) do (
        echo Copying %%~nxG to keys folder...
        copy "%%G" "%serverLocation%\keys\"
    )
    endlocal

    echo This file prevents the mods setup prompt from appearing on the next launch. > "%serverLocation%\setup_mods_marker.txt"

    echo Mods and .bikey files copied successfully.
) else if /i "%addMods%"=="N" (
    REM User chose not to add all mods to mods.cfg
    echo User chose not to add all mods to mods.cfg and .bikey files.

    REM Create or update setup_mods_marker.txt to indicate mods setup was skipped
    echo This file prevents the mods setup prompt from appearing on the next launch. > "%serverLocation%\setup_mods_marker.txt"

) else (
    REM Invalid choice handling
    echo Error: Invalid choice. Please enter either Y or N.
    timeout /t 5 >nul
    goto serverMods_Prompt
)

echo Setup complete.

REM Pause at the end of the script
exit