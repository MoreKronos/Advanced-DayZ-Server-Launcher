@echo off
REM DayZ Server Launcher Script

REM Enable delayed expansion for variables
setlocal enabledelayedexpansion

REM Set server location to the directory of this script
set "scriptDir=%~dp0"
set "serverLocation=%scriptDir%"

REM Set log file paths relative to where launcher.bat is located
set "logFile=%serverLocation%logs\server.log"
set "setupLogFile=%serverLocation%logs\setup.log"

REM Check if server.log exists and delete it
if exist "%logFile%" (
    del /q "%logFile%"
)

REM Check if DayZServer_x64.exe is present in the script's directory
if not exist "%serverLocation%DayZServer_x64.exe" (
    echo Error: DayZServer_x64.exe not found in the same directory as this script.
    pause
    exit /b
)

REM Check if setup has already been performed by looking for a marker file
set "markerFile=%serverLocation%setup_marker.txt"
if exist "%markerFile%" (
    goto Configuration
)

:DayZServerSetup
REM Clear screen
cls
REM Prompt user whether to set up DayZ server configuration 
echo It's recommended to use the DayZ setup script to configure your server.
echo.
set /p "Setup=Would you like this script to set up your DayZ server? (Y/N): "
if /i "%Setup%"=="Y" (
    cls
    echo Setting up DayZ Server configuration...
    goto DayZServerConfiguration
) else if /i "%Setup%"=="N" (
	REM Clear screen
	cls
    echo You chose not to use DayZServerSetup. It's recommended to use the DayZ setup script.
    echo Creating setup_marker.txt to prevent setup prompt on next launch...
    echo This file prevents the setup prompt from appearing on the next launch.
	echo To ever use the setup again find and delete the setup_marker.txt
    echo [%date% %time%] Created setup_marker.txt >> "%setupLogFile%"
	echo [%date% %time%] User chose to decline setup >> "%setupLogFile%" 
    timeout /t 10 >nul

    goto Configuration
) else (
    echo Error: Invalid choice. Please select either 'Y' or 'N'.
    timeout /t 5 >nul
    echo [%date% %time%] User chose an invalid choice. >> "%setupLogFile%"
    cls
    goto DayZServerSetup
)

:DayZServerConfiguration
REM This section cleans up existing configuration and prepares new setup
cls
echo Setting up DayZ Server configuration...

echo Deleting logs folder directory if found
if exist "%serverLocation%logs" (
    rmdir /s /q "%serverLocation%logs"
) else (
    echo Logs folder does not exist.
)
timeout /t 1 >nul

echo Deleting profiles folder directory if found
if exist "%serverLocation%profiles" (
    rmdir /s /q "%serverLocation%profiles"
) else (
    echo Profiles folder does not exist.
)
timeout /t 1 >nul

echo Deleting keys folder directory if found
if exist "%serverLocation%keys" (
    rmdir /s /q "%serverLocation%keys"
) else (
    echo Keys folder does not exist.
)
timeout /t 1 >nul

echo Deleting server_profile folder directory if found
if exist "%serverLocation%server_profile" (
    rmdir /s /q "%serverLocation%server_profile"
) else (
    echo Server_profiles folder does not exist.
)
timeout /t 1 >nul

echo Deleting config folder directory if found
if exist "%serverLocation%config" (
    rmdir /s /q "%serverLocation%config"
) else (
    echo Config folder does not exist.
)
timeout /t 1 >nul

echo ---
echo Configuration cleanup completed
echo ---
echo Press any key to continue
pause >nul
REM Clear screen 
cls

echo Creating logs folder directory if not found
REM Create the logs directory if it doesn't exist
if not exist "%serverLocation%logs" (
    mkdir "%serverLocation%logs"
)
echo [%date% %time%] Created logs folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Creating profiles folder directory if not found
REM Create the profiles directory if it doesn't exist
if not exist "%serverLocation%profiles" (
    mkdir "%serverLocation%profiles"
)
echo [%date% %time%] Created profiles folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Creating mods folder directory if not found
REM Create the mods directory if it doesn't exist
if not exist "%serverLocation%mods" (
    mkdir "%serverLocation%mods"
)
echo [%date% %time%] Created mods folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Creating keys folder directory if not found
REM Create the keys directory if it doesn't exist
if not exist "%serverLocation%keys" (
    mkdir "%serverLocation%keys"
)
echo [%date% %time%] Created keys folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Creating server_profile directory if not found
REM Create the server_profile directory if it doesn't exist
if not exist "%serverLocation%server_profile" (
    mkdir "%serverLocation%server_profile"
)
echo [%date% %time%] Created server_profiles folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Moving server.DZ.cfg to the proper folder ("%serverLocation%server_profile\serverDZ.cfg")
REM Move serverDZ.cfg to server_profile folder (assuming it's in the same directory as this script)
move "%serverLocation%serverDZ.cfg" "%serverLocation%server_profile\serverDZ.cfg" >nul 2>&1
echo [%date% %time%] Moved server.DZ.cfg to ("%serverLocation%server_profile\serverDZ.cfg") >> "%setupLogFile%"
REM Check if move was successful
if not exist "%serverLocation%server_profile\serverDZ.cfg" (
    echo Error: Failed to move serverDZ.cfg to server_profile folder.
    echo This either means that there was no serverDZ.cfg found or you already have the file in that folder, 
    echo Please remove it and put it in the %serverLocation% folder
    pause
    exit /b
)
timeout /t 1 >nul

echo :
echo Press any key to continue
pause >nul

:completeSetup
REM Clear screen
cls
echo Setup complete.

REM Create a marker file to indicate setup completion
echo [%date% %time%] Setup complete > "%markerFile%"
echo [%date% %time%] DO NOT DELETE THIS FILE >> "%markerFile%"
echo [%date% %time%] This file stops you from seeing the setup every time on launch >> "%markerFile%"
echo [%date% %time%] DayZ Server setup completed. >> "%setupLogFile%"
timeout /t 3 >nul

goto Configuration

:Configuration
REM Clear Screen
cls
REM Title Name
title Configuration
echo Configuration:
REM Check if server.log exists and delete it
if exist "%logFile%" (
    del /q "%logFile%"
)

REM Prompt user to enter server name
:serverName
set /p "serverName=Enter server name: "
if "%serverName%"=="" (
    echo Error: Server name cannot be empty.
    timeout /t 5 >nul
    goto serverName
)
echo [%date% %time%] Server name set to: %serverName% >> "%logFile%"

REM Prompt user to enter server port
:serverPort
set /p "serverPort=Enter server port (press Enter to use the default port = 2302): "
if "%serverPort%"=="" (
    set "serverPort=2302"
) else (
    echo [%date% %time%] Server port set to: %serverPort% >> "%logFile%"
)
echo [%date% %time%] Server port set to: %serverPort% >> "%logFile%"

REM Prompt user to enter CPU count
:serverCPU
set /p "serverCPU=Enter CPU count (press Enter to use the default CPU count = 2): "
if "%serverCPU%"=="" (
    set "serverCPU=2"
) else (
    echo [%date% %time%] CPU count set to: %serverCPU% >> "%logFile%"
)
echo [%date% %time%] CPU count set to: %serverCPU% >> "%logFile%"

REM Prompt user to enter restart hours
:serverRestart
set /p "restartHours=Enter restart time (from 1 to 24 hours): "
set "validInput=false"

REM Check if input is a number between 1 and 24
for /L %%i in (1,1,24) do (
    if "%restartHours%"=="%%i" set "validInput=true"
)

if not "%validInput%"=="true" (
    echo Error: Invalid restart time format or out of range. Please enter a value from 1 to 24 hours.
    timeout /t 5 >nul
    goto serverRestart
)

REM Determine the correct logging format for restart time
if %restartHours% equ 1 (
    set "serverRestartLog=%restartHours% hour"
) else (
    set "serverRestartLog=%restartHours% hours"
)
echo [%date% %time%] Restart time set to: %serverRestartLog% >> "%logFile%"

goto serverLocation

REM Display found server location in prompt
:serverLocation
set "serverLocationInput="
set /p "serverLocationInput=Enter server location (press Enter to use found directory = %serverLocation%): "

REM Validate server location input
if not "%serverLocationInput%"=="" (
    if exist "%serverLocationInput%" (
        set "serverLocation=%serverLocationInput%"
		echo [%date% %time%] Server location set to: %serverLocation% >> "%logFile%"
        goto serverMods
    ) else (
        echo Error: Directory "%serverLocationInput%" not found. Please enter a valid directory.
        timeout /t 5 >nul
        goto serverLocation
    )
) else (
	echo [%date% %time%] Server location set to: %serverLocation% >> "%logFile%"
    goto folderCheck
)

:folderCheck
REM Check if there are any subfolders inside the "mods" folder
if exist "%serverLocation%\mods" (
    dir /b /ad "%serverLocation%\mods\*" >nul 2>&1
    if errorlevel 1 (
        REM No subfolders found inside "mods" folder
        echo No mods found inside mods folder. Skipping serverMods tab.
        echo [%date% %time%] No mods found inside mods folder. Skipping serverMods. >> "%logFile%"
        goto Reconfiguration
    ) else (
        REM Subfolders found, proceed with serverMods script
		echo [%date% %time%] Mods found continuing to prompt>> "%logFile%"
        goto serverMods
    )
) else (
    REM "mods" folder not found
    echo Mods folder not found. Skipping serverMods tab.
    echo [%date% %time%] Mods folder not found. Skipping serverMods. >> "%logFile%"
    goto Reconfiguration
)

:serverMods
REM Clear screen
cls

REM clear all text in the mods.cfg file
type nul > "%serverLocation%\mods.cfg"

REM Create keys folder if it doesn't exist
if not exist "%serverLocation%\keys" (
    mkdir "%serverLocation%\keys"
    REM Log the creation of keys folder
    echo [%date% %time%] Created keys folder >> "%logFile%"
)

REM Prompt user to add all mods to mods.cfg
echo Mods found.

:serverMods_Prompt
set /p "addMods=Do you want to add all mods to mods.cfg and all .bikey files to Keys folder? (Y/N): "

REM Validate user input
REM Use /I for case-insensitive comparison
if /i "%addMods%"=="Y" (
    REM Create an empty mods.cfg file
    type nul > "%serverLocation%\mods.cfg"

    REM Loop through each subfolder in the mods directory and write folder names to mods.cfg
    for /D %%F in ("%serverLocation%\mods\*") do (
        echo %%~nxF >> "%serverLocation%\mods.cfg"
    )

    REM Log the operation
    echo [%date% %time%] Successfully added all mods to mods.cfg and Keys folder >> "%logFile%"

    REM Search for .bikey files in nested "mods" folders and copy them to "%serverLocation%\keys"
    setlocal enabledelayedexpansion
    for /R "%serverLocation%\mods" %%G in (*.bikey) do (
        echo Copying %%~nxF to keys folder outside of mods...
        copy "%%G" "%serverLocation%\keys\"
    )
    endlocal
) else if /i "%addMods%"=="N" (
    REM User chose not to add all mods to mods.cfg
    echo User chose not to add all mods to mods.cfg and .bikey files.

    REM Log user decision
    echo [%date% %time%] User chose not to add all mods to mods.cfg and Keys folder >> "%logFile%"
    
    REM Proceed to the next section or label after handling 'N'
    goto Reconfiguration
) else (
    REM Invalid choice handling
    echo Error: Invalid choice. Please enter either Y or N.
    timeout /t 5 >nul
    goto serverMods_Prompt
)

echo Press any key to continue
pause >nul

REM Reconfigure prompt
:Reconfiguration
REM Clear screen
cls

echo Do you want to reconfigure the settings? (Y/N)
set /p reconfigure=
if /i "%reconfigure%"=="Y" (
    goto Configuration
) else if /i "%reconfigure%"=="N" (
    echo [%date% %time%] User chose not to reconfigure settings. >> "%logFile%"
    goto startServer_Prompt
) else (
    echo Error: Invalid choice. Please select either 'Y' or 'N'.
    timeout /t 5 >nul
    echo [%date% %time%] User chose to reconfigure settings. >> "%logFile%"
    goto Configuration
)

:startServer_Prompt
REM Clear screen
cls
REM Title Name
title Starting Server
echo Are you sure you want to start %serverName% Dayz Server? (Y/N)
set /p confirm=
if /i "%confirm%"=="Y" (
    echo [%date% %time%] User chose to start the server. >> "%logFile%"
    goto startServer
) else if /i "%confirm%"=="N" (
    echo [%date% %time%] User chose to abort server startup. >> "%logFile%"
    goto exit
) else (
	REM Clear screen
	cls
    echo Error: Invalid choice. Please select either 'Y' or 'N'.
    timeout /t 5 >nul
    goto startServer_Prompt
)

:startServer
REM Clear screen
cls
REM Title Name
title %serverName% 
REM Log server startup
echo (%time%) Starting %serverName% DayZ server
echo (%date% %time%) %serverName% Server started >> "%logFile%"

REM Display mods.cfg contents if it exists
echo Mods currently loaded:
echo ------------------------
if exist "%serverLocation%\mods.cfg" (
	type "%serverLocation%\mods.cfg"
) else (
    echo No mods found/enabled.
)
REM Force text to not overlap the line
echo ------------------------

REM Kill DayZ server process if it exists
tasklist /fi "imagename eq DayZServer_x64.exe" 2>NUL | find /i "DayZServer_x64.exe" >nul && (
    taskkill /f /im DayZServer_x64.exe
    echo [%date% %time%] Killing DayZServer_x64.exe for startup issues !serverName! >> "%logFile%"
)

REM Launch DayZ server with specified parameters
start "DayZ Server" /min "DayZServer_x64.exe" -profiles=profiles -mod=%mods% -config=server_profile\serverDZ.cfg -port=%serverPort% -cpuCount=%serverCPU% -dologs -adminlog -netlog -freezecheck
REM Wait before server restart
set /a serverRestart=%restartHours%*3600
timeout /t %serverRestart%

REM Kill server process
taskkill /im DayZServer_x64.exe /F

REM Log server restart
echo (%date% %time%) Server restarted >> "%logFile%"

REM Wait before restarting server
title Restarting Server
echo (%date% %time%) Restarting server (Please Wait) >> "%logFile%"
timeout /t 10

goto startServer

:exit
REM Set terminal title
title Exiting Launcher

REM Set countdown for exiting
set countdown=5
:countdownloop2
REM Clear screen
cls
REM Log countdown
echo Exiting in (%countdown%) >> logs\Batch_Launcher.log

echo Server startup aborted
echo Exiting in %countdown% seconds...
set /a countdown-=1
if %countdown% gtr -1 (
    timeout /t 1 >nul
    goto countdownloop2
) else (
	REM Clear screen
	cls
	REM exit the script 
	echo Launcher Was Aborted >> logs\Batch_Launcher.log
    exit /b
)
