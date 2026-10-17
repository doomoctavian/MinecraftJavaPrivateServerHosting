@echo off
title Minecraft Server

echo ==========================================
echo        Minecraft Server Launcher
echo ==========================================
echo.

cd /d C:\MinecraftServer

echo Server directory:
echo %CD%
echo.

if not exist "server.jar" (
echo ERROR: server.jar was not found.
echo Make sure the server is installed in:
echo C:\MinecraftServer
echo.
pause
exit /b 1
)

echo Starting Minecraft server...
echo.
echo Keep this window open while the server is running.
echo To safely stop the server, type:
echo stop
echo.

java -Xms2G -Xmx4G -jar server.jar nogui

echo.
echo ==========================================
echo Minecraft server process has stopped.
echo ==========================================
echo.