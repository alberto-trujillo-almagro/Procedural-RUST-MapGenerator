@echo off
REM
REM  Source Code: 
REM  rcon binary source: https://github.com/gorcon/rcon-cli
REM  rcon binary version: v.0.10.3
REM
REM  steamcmd binary source: https://developer.valvesoftware.com/wiki/SteamCMD#Windows
REM
REM  
cls

REM Global variables
SET MAPSIZE=4000
SET RANDOMSEED=%random%
for /f "tokens=1-8 delims=.:/ " %%a in ("%date% %time%") do set DateNtime=%%a-%%b-%%c_%%d-%%e
SET CURRENTDIR=%cd%
SET LOGFILE=%CURRENTDIR%\LogFile_%DateNtime%.log
SET LOGFILE2=%CURRENTDIR%\LogFile2_%DateNtime%.log
@rmdir /S /Q "%CURRENTDIR%\server" >nul

IF NOT exist "%CURRENTDIR%\MAPS" ( @mkdir "%CURRENTDIR%\MAPS" >nul )
IF NOT exist "%CURRENTDIR%\server" ( @mkdir "%CURRENTDIR%\server" >nul )
@copy /Y "%CURRENTDIR%\steamcmd.exe" "%CURRENTDIR%\server\" >nul
REM End Global variables

:MENU
cls
echo.
echo.
echo.
echo                                   ********************************************************
echo                                   *         RUST PROCEDURAL MAP GENERATOR v1.1           *
echo                                   ********************************************************
echo                                   *   1. Select Map Size                                 *
echo                                   *   2. Select Map Seed                                 *
echo                                   *   3. Generate Map!                                   *
echo                                   *   4. View Map Prefabs and config                     *
echo                                   *   5. View Maps generated                             *
echo                                   *   6. Exit                                            *
echo                                   ********************************************************
echo.                                           [MapSize: %MAPSIZE% - MapSeed: %RANDOMSEED%]
echo.
CHOICE /C 123456 /N /M "Select Option (1,2,3,4,5,6):"
echo.
IF ERRORLEVEL ==6 GOTO END
IF ERRORLEVEL ==5 GOTO VIEWMAPS
IF ERRORLEVEL ==4 GOTO VIEWCONFIG
IF ERRORLEVEL ==3 GOTO GENERATEMAP
IF ERRORLEVEL ==2 GOTO MAPSEED
IF ERRORLEVEL ==1 GOTO MAPSIZE
goto END

:MAPSEED
set /P RANDOMSEED=Input MapSeed [0-2147483647]:
IF %RANDOMSEED% GTR 2147483647 (
echo MAPSEED must be between 0 and 2147483647.
goto MAPSEED
)
cls
goto MENU

:MAPSIZE
set /P MAPSIZE=Input MapSize [1500-6000]:
IF %MAPSIZE% LSS 1000 (
echo MAPSIZE must be between 1000 and 6000.
goto MAPSIZE
)
IF %MAPSIZE% GTR 6000 (
echo MAPSIZE must be between 1000 and 6000.
goto MAPSIZE
)
cls
goto MENU

:GENERATEMAP
cls
"%CURRENTDIR%\server\steamcmd.exe" +login anonymous +force_install_dir "%CURRENTDIR%\server\server" +app_update 258550 +quit
mkdir "%CURRENTDIR%\server\server\server\world_%RANDOMSEED%"
copy /Y "%CURRENTDIR%\myConfig.txt" "%CURRENTDIR%\server\server\server\world_%RANDOMSEED%\"
cd "%CURRENTDIR%\server\server"
start /B /D "%CURRENTDIR%\server\server" RustDedicated.exe -batchmode +server.seed %RANDOMSEED% +server.worldsize %MAPSIZE% +world.configfile myConfig.txt +server.port 28015 +server.maxplayers 10 +server.hostname GENERATOR +server.description GENERATOR +server.identity world_%randomseed% +rcon.port 28016 +rcon.password 1 +rcon.web 1 +rcon.ip 0.0.0.0 -logfile "%LOGFILE2%" 2^>nul

:STOPSERVER
"%CURRENTDIR%\rcon.exe" -a 127.0.0.1:28016 -t web -p 1 status 2>nul
IF %ERRORLEVEL% EQU 0 (
echo [INFO][%DATE% - %TIME%] RCON IS ALIVE >> %LOGFILE%
IF EXIST server\world_%RANDOMSEED%\*.map (
    dir server\world_%RANDOMSEED%\*.map
    copy /Y server\world_%RANDOMSEED%\*.map "%CURRENTDIR%\MAPS\"
    "%CURRENTDIR%\rcon.exe" -a 127.0.0.1:28016 -t web -p 1 world.rendermap 2>nul
    timeout /t 20 /nobreak >nul
    IF EXIST map_%MAPSIZE%_%RANDOMSEED%.png (
       copy /Y map_%MAPSIZE%_%RANDOMSEED%.png "%CURRENTDIR%\MAPS\"
       rename "%CURRENTDIR%\MAPS\map_%MAPSIZE%_%RANDOMSEED%.png" proceduralmap.%MAPSIZE%.%RANDOMSEED%.png
    )
    timeout /t 20 /nobreak >nul
)
"%CURRENTDIR%\rcon.exe" -a 127.0.0.1:28016 -t web -p 1 quit
timeout /t 30 /nobreak >nul
cd "%CURRENTDIR%"
rmdir /S /Q "%CURRENTDIR%\server"
del "%LOGFILE%"
del "%LOGFILE2%"
goto MENU
) ELSE (
echo [INFO][%DATE% - %TIME%] RCON IS NOT ALIVE >> %LOGFILE%
echo [INFO][%DATE% - %TIME%] GENERATING MAP...PLEASE WAIT
timeout /t 2 /nobreak >nul
cls
goto STOPSERVER
)


goto END

:VIEWCONFIG
cls
echo.
echo *************************************** myConfig.txt **********************************
type "%CURRENTDIR%\myConfig.txt"
echo *************************************** myConfig.txt **********************************
pause
cls
goto MENU

:VIEWMAPS
cls
echo ************ MAPS GENERATED (PATH: "%CURRENTDIR%\MAPS\") ************
echo.
dir /B "%CURRENTDIR%\MAPS\"
echo.
echo ************ MAPS GENERATED (PATH: "%CURRENTDIR%\MAPS\") ************
echo.
echo.
echo.
pause
cls
goto MENU

:END
