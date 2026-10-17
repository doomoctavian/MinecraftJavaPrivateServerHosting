
@echo off
setlocal EnableExtensions
title Minecraft World Backup

REM ==================================================
REM Minecraft World Backup
REM Default server directory: C:\MinecraftServer
REM Stop the Minecraft server before running this.
REM ==================================================

set "SERVER_DIR=C:\MinecraftServer"
set "BACKUP_DIR=%SERVER_DIR%\backups"

echo ==========================================
echo       Minecraft World Backup
echo ==========================================
echo.

REM Check server directory
if not exist "%SERVER_DIR%\" (
    echo ERROR: Minecraft server directory not found:
    echo %SERVER_DIR%
    goto :failure
)

REM Check main world
if not exist "%SERVER_DIR%\world\" (
    echo ERROR: Main world folder was not found:
    echo %SERVER_DIR%\world
    goto :failure
)

REM Confirm the server is stopped
echo IMPORTANT:
echo The Minecraft server must be completely stopped.
echo Do not back up a world while it is running.
echo.

choice /C YN /M "Is the Minecraft server completely stopped"
if errorlevel 2 goto :cancelled

REM Create a locale-independent timestamp
for /f "delims=" %%I in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'"') do set "TIMESTAMP=%%I"

if not defined TIMESTAMP (
    echo ERROR: Could not generate a timestamp.
    goto :failure
)

set "BACKUP_NAME=world-backup-%TIMESTAMP%"
set "DEST_DIR=%BACKUP_DIR%\%BACKUP_NAME%"
set "LOG_FILE=%DEST_DIR%\backup.log"

echo.
echo Backup name: %BACKUP_NAME%
echo Destination: %DEST_DIR%
echo.

REM Create destination directory
if not exist "%BACKUP_DIR%\" (
    mkdir "%BACKUP_DIR%"
    if errorlevel 1 (
        echo ERROR: Could not create backup directory.
        goto :failure
    )
)

mkdir "%DEST_DIR%"
if errorlevel 1 (
    echo ERROR: Could not create backup destination.
    goto :failure
)

echo Backup started at %DATE% %TIME% > "%LOG_FILE%"

echo Copying main world...
robocopy "%SERVER_DIR%\world" "%DEST_DIR%\world" /E /COPY:DAT /DCOPY:DAT /R:2 /W:2 /XJ /TEE /LOG+:"%LOG_FILE%"
if errorlevel 8 goto :copyfailure

REM Support older server layouts that use separate folders.
REM Modern vanilla Java worlds normally store dimensions
REM inside the main world folder instead.

if exist "%SERVER_DIR%\world_nether\" (
    echo.
    echo Copying legacy Nether folder...
    robocopy "%SERVER_DIR%\world_nether" "%DEST_DIR%\world_nether" /E /COPY:DAT /DCOPY:DAT /R:2 /W:2 /XJ /TEE /LOG+:"%LOG_FILE%"
    if errorlevel 8 goto :copyfailure
)

if exist "%SERVER_DIR%\world_the_end\" (
    echo.
    echo Copying legacy End folder...
    robocopy "%SERVER_DIR%\world_the_end" "%DEST_DIR%\world_the_end" /E /COPY:DAT /DCOPY:DAT /R:2 /W:2 /XJ /TEE /LOG+:"%LOG_FILE%"
    if errorlevel 8 goto :copyfailure
)

echo.
echo Copying important configuration and player files...

for %%F in (
    server.properties
    whitelist.json
    ops.json
    banned-players.json
    banned-ips.json
    usercache.json
    eula.txt
) do (
    if exist "%SERVER_DIR%\%%F" (
        copy /Y "%SERVER_DIR%\%%F" "%DEST_DIR%\%%F" >> "%LOG_FILE%" 2>&1
        if errorlevel 1 (
            echo ERROR: Failed to copy %%F
            goto :copyfailure
        )
        echo Copied %%F
    )
)

echo.
echo Verifying the main world backup exists...
if not exist "%DEST_DIR%\world\level.dat" (
    echo ERROR: level.dat is missing from the backup.
    goto :copyfailure
)

echo Backup completed at %DATE% %TIME% >> "%LOG_FILE%"

echo.
echo ==========================================
echo          BACKUP COMPLETED
echo ==========================================
echo.
echo Backup location:
echo %DEST_DIR%
echo.
echo Review backup.log for copy details.
echo Test restoration before relying on this backup.
echo.
pause
exit /b 0

:copyfailure
echo.
echo ==========================================
echo          BACKUP FAILED
echo ==========================================
echo.
echo One or more copy operations failed.
echo The destination may contain a partial backup.
echo Do NOT treat this backup as reliable.
echo Check the log, if available:
echo %LOG_FILE%
echo.
pause
exit /b 1

:cancelled
echo.
echo Backup cancelled. No backup was created.
echo.
pause
exit /b 0

:failure
echo.
echo Backup could not be started.
echo.
pause
exit /b 1