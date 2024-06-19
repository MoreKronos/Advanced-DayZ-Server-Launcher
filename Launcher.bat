@echo off
REM Made in batch script

REM This script is a server launcher for a DayZ server.
setlocal enabledelayedexpansion

REM Set log file path relative to where launcher.bat is located
set "logFile=%serverLocation%logs\server.log"
set "setupLogFile=%serverLocation%logs\setup.log"

REM Check if server.log exists and delete it
if exist "%logFile%" (
    del /q "%logFile%"
)

REM Set server location to the directory of this script
set "scriptDir=%~dp0"
set "serverLocation=%scriptDir%"

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
REM Setup DayZ Server configuration
cls

echo Would you like this script to set up your DayZ server? (Y/N)
set /p Setup=
if /i "%Setup%"=="Y" (
	cls
    goto DayZServerConfiguration
) else if /i "%Setup%"=="N" (
    echo [%date% %time%] User chose not to use DayZServerSetup.
	cls
    goto Configuration
) else (
    echo Error: Invalid choice. Please select either 'Y' or 'N'.
    timeout /t 5 >nul
    echo [%date% %time%] User chose an invalid choice.
	cls
    goto DayZServerSetup
)
:DayZServerConfiguration
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

echo Deleting mods folder directory if found
if exist "%serverLocation%mods" (
	echo mods folder was deleted
    rmdir /s /q "%serverLocation%mods"
) else (
     echo Mods folder does not exist.
)
timeout /t 1 >nul

echo Deleting keys folder directory if found
if exist "%serverLocation%keys" (
	echo keys folder was deleted
    rmdir /s /q "%serverLocation%keys"
) else (
     echo Keys folder does not exist.
)
timeout /t 1 >nul

echo Deleting server_profile folder directory if found
if exist "%serverLocation%server_profile" (
	echo server_profile folder was deleted
    rmdir /s /q "%serverLocation%server_profile"
) else (
    echo Server_profiles folder does not exist.
)
timeout /t 1 >nul

echo Deleting config folder directory if found
if exist "%serverLocation%config" (
	echo config folder was deleted
    rmdir /s /q "%serverLocation%config"
) else (
    echo config folder does not exist.
)
timeout /t 1 >nul

echo -
echo Configuration cleanup completed
echo -
echo Press any key to continue
pause >nul 
cls

echo Creating logs folder directory if not found
REM Create the logs directory if it doesn't exist
if not exist "%serverLocation%logs" (
	echo logs folder created
    mkdir "%serverLocation%logs"
)
echo [%date% %time%] Created logs folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Creating profiles folder directory if not found
REM Create the profiles directory if it doesn't exist
if not exist "%serverLocation%profiles" (
	echo profiles folder created
    mkdir "%serverLocation%profiles"
)
echo [%date% %time%] Created profiles folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Creating mods folder directory if not found
REM Create the mods directory if it doesn't exist
if not exist "%serverLocation%mods" (
	echo mods folder created
    mkdir "%serverLocation%mods"
)
echo [%date% %time%] Created mods folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Creating keys folder directory if not found
REM Create the keys directory if it doesn't exist
if not exist "%serverLocation%keys" (
	echo keys folder created
    mkdir "%serverLocation%keys"
)
echo [%date% %time%] Created keys folder >> "%setupLogFile%"
timeout /t 1 >nul

echo Creating server_profile directory if not found
REM Create the server_profile directory if it doesn't exist
if not exist "%serverLocation%server_profile" (
	echo server_profile folder created
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

echo -
echo Press any key to continue
pause >nul
cls

echo Deleting readme file...
del /q "%~dp0readMe.txt"
echo Deleted readMe.txt file
echo [%date% %time%] Deleted readMe.txt file >> "%setupLogFile%"
timeout /t 1 >nul

echo Deleting mods.cfg.txt files...
del /q "%~dp0mods.cfg.txt"
echo Deleted mods.cfg.txt file

set "modsFile=%serverLocation%Mods.cfg"
if exist "%modsFile%" (
    goto completeSetup
) else (
timeout /t 1 >nul
rem Creating new mods.cfg if one is not found
echo @add-mod-here > "%serverLocation%Mods.cfg"
echo [%date% %time%] Creating new mods.cfg file >> "%setupLogFile%"
echo Created new mods.cfg file
timeout /t 1 >nul
goto completeSetup
)

:completeSetup
echo Setup complete.

REM Create a marker file to indicate setup completion
echo [%date% %time%] Setup complete > "%markerFile%"
echo [%date% %time%] DO NOT DELETE THIS FILE >> "%markerFile%"
echo [%date% %time%] This file stops you from seeing the setup every time on launch >> "%markerFile%"
echo [%date% %time%] DayZ Server setup completed. >> "%setupLogFile%"
timeout /t 3 >nul

goto Configuration

:Configuration

cls
echo Configuration:
goto serverName

:serverName
REM Read server name with error checking
set "serverName="
set /p "serverName=Enter server name: "
if "!serverName!"=="" (
    echo Error: Server name cannot be empty.
    timeout /t 5 >nul 
	goto serverName
) else (
echo [%date% %time%] User entered server name: !serverName! >> "%logFile%"
goto serverPort
)

REM Read server port
:serverPort
set /p "serverPort=Enter server port (press Enter to use the default port = 2302): "
if "%serverPort%"=="" (
    set "serverPort=2302"
)
echo [%date% %time%] User entered server port: !serverPort! >> "%logFile%"

goto cpuCount

REM Read CPU count
:cpuCount
set /p "serverCPU=Enter CPU count (press Enter to use the default cores = 2): "
if "%serverCPU%"=="" (
    set "serverCPU=2"
)
echo [%date% %time%] User entered CPU count: !serverCPU! >> "%logFile%"
goto restartTime

REM Read restart time
:restartTime
set /p "restartHours=Enter restart time (from 1 to 24 hours): "
set "validInput=false"

REM Check if input is a number between 1 and 24
for /L %%i in (1,1,24) do (
    if "%restartHours%"=="%%i" set "validInput=true"
)

if not "%validInput%"=="true" (
    echo Error: Invalid restart time format or out of range. Please enter a value from 1 to 24 hours.
    timeout /t 5 >nul
    goto restartTime
)

REM Determine the correct logging format for restart time
if %restartHours% equ 1 (
    set "restartTimeLog=%restartHours% hour"
) else (
    set "restartTimeLog=%restartHours% hours"
)
echo [%date% %time%] User entered restart time: %restartTimeLog% >> "%logFile%"
goto serverLocationInput

REM Display found server location in prompt
:serverLocationInput
set "serverLocationInput="
set /p "serverLocationInput=Enter server location (press Enter to use found directory = %serverLocation%): "

REM Validate server location input
if not "%serverLocationInput%"=="" (
    if exist "%serverLocationInput%" (
        set "serverLocation=%serverLocationInput%"
        goto setSettings
    ) else (
        echo Error: Directory "%serverLocationInput%" not found. Please enter a valid directory.
        timeout /t 5 >nul
        goto serverLocationInput
    )
) else (
    goto setSettings
)

REM Set title for terminal
:setSettings
REM adding serverLocation log code here for now
echo [%date% %time%] Server location set to: %serverLocation% >> "%logFile%"

title %serverName%

REM Change directory to DayZ server location
cd /d "%serverLocation%"

REM Log script start
echo [%date% %time%] Script started. >> "%logFile%"
goto Reconfiguration

REM Prompt user to reconfigure settings
:Reconfiguration
cls
echo Do you want to reconfigure the settings? (Y/N)
set /p reconfigure=
if /i "%reconfigure%"=="Y" (
    goto Configuration
) else if /i "%reconfigure%"=="N" (
    echo [%date% %time%] User chose not to reconfigure settings. >> "%logFile%"
    goto startServer_process
) else (
    echo Error: Invalid choice. Please select either 'Y' or 'N'.
    timeout /t 5 >nul
    echo [%date% %time%] User chose to reconfigure settings. >> "%logFile%"
    goto Configuration
)

REM Confirm server start
:startServer_process
cls
echo Are you sure you want to start %serverName% Dayz Server? (Y/N)
set /p confirm=
if /i "%confirm%"=="Y" (
    echo [%date% %time%] User chose to start the server. >> "%logFile%"
    goto startServer
) else if /i "%confirm%"=="N" (
    echo [%date% %time%] User chose to abort server startup. >> "%logFile%"
    goto exit
) else (
    echo Error: Invalid choice. Please select either 'Y' or 'N'.
    timeout /t 5 >nul
    goto startServer_process
)

REM Clear screen
:startServer
cls
REM Log server startup
echo (%time%) %serverName% started.
echo (%date% %time%) %serverName% Server started >> "%logFile%"

REM Kill DayZ server process if it exists
tasklist /fi "imagename eq DayZServer_x64.exe" 2>NUL | find /i "DayZServer_x64.exe" >nul && (
    taskkill /f /im DayZServer_x64.exe
    echo [%date% %time%] Killing DayZServer_x64.exe for startup issues !serverName! >> "%logFile%"
)

REM Launch DayZ server with specified parameters
start "DayZ Server" /min "DayZServer_x64.exe" -profiles=profiles -mod=%mods% -config=server_profile\serverDZ.cfg -port=%serverPort% -cpuCount=%serverCPU% -dologs -adminlog -netlog -freezecheck
REM Wait before server restart
set /a restartTime=%restartHours%*3600
timeout /t %restartTime%

REM Kill server process
taskkill /im DayZServer_x64.exe /F

REM Log server restart
echo (%date% %time%) Server restarted >> "%logFile%"

REM Wait before restarting server
title Restarting Server
echo (%date% %time%) Restarting server (Please Wait) >> "%logFile%"
timeout /t 10

goto startServer

REM Clear screen
cls

REM Set countdown for exiting
set countdown=5
echo Server startup aborted
echo Exiting in %countdown% seconds...
set /a countdown-=1
if %countdown% gtr -1 (
    timeout /t 1 >nul
    goto countdownloop
)

REM Log exiting
echo Exiting... >> "%logFile%"
exit /b
