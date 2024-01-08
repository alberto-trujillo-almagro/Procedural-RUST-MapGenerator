@echo off
REM
REM  rcon binary source: https://github.com/gorcon/rcon-cli
REM  rcon binary version: v.0.10.3
REM
REM  steamcmd binary source: https://developer.valvesoftware.com/wiki/SteamCMD#Windows

for /f "tokens=1-8 delims=.:/ " %%a in ("%date% %time%") do set DateNtime=%%a-%%b-%%c_%%d-%%e
SET CURRENTDIR=%cd%
SET LOGFILE=%CURRENTDIR%\LogFile_%DateNtime%.log

rmdir /S /Q "%CURRENTDIR%\server"
mkdir "%CURRENTDIR%\MAPAS"
mkdir "%CURRENTDIR%\server"
copy /Y "%CURRENTDIR%\steamcmd.exe" "%CURRENTDIR%\server\"
"%CURRENTDIR%\server\steamcmd.exe" +login anonymous +force_install_dir "%CURRENTDIR%\server\server" +app_update 258550 +quit

set numero=%random%
mkdir "%CURRENTDIR%\server\server\server\world_%numero%"
copy /Y "%CURRENTDIR%\myConfig.txt" "%CURRENTDIR%\server\server\server\world_%numero%\"


cd "%CURRENTDIR%\server\server"
start RustDedicated.exe -batchmode +server.seed %numero% +server.worldsize 4000 +world.configfile myConfig.txt +server.port 28015 +server.maxplayers 10 +server.hostname GENERATOR +server.description GENERATOR +server.identity world_%numero% +rcon.port 28016 +rcon.password 1 +rcon.web 1 +rcon.ip 0.0.0.0


:pararserver
"%CURRENTDIR%\rcon" -a 127.0.0.1:28016 -t web -p 1 status
IF %ERRORLEVEL% EQU 0 (
echo [INFO][%DATE% - %TIME%] RCON IS ALIVE >> %LOGFILE%
IF EXIST server\world_%numero%\*.map (
    dir server\world_%numero%\*.map
    copy /Y server\world_%numero%\*.map "%CURRENTDIR%\MAPAS\"
    timeout /t 20 /nobreak >nul
)

"%CURRENTDIR%\rcon" -a 127.0.0.1:28016 -t web -p 1 quit
timeout /t 120 /nobreak >nul
cd "%CURRENTDIR%"
rmdir /S /Q "%CURRENTDIR%\server"
echo "Proceso terminado..."
goto fin2
) ELSE (
echo [INFO][%DATE% - %TIME%] RCON IS NOT ALIVE >> %LOGFILE%
timeout /t 120 /nobreak >nul
goto pararserver
)

:fin2
exit 0

