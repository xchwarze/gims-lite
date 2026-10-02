@echo off
rem Downloads the latest RHash Windows zip and installs it next to the tool executable.
rem Run by GIMS (download_command / update_command): everything comes from injected variables.
rem   %~1               URL of the archive (an argument in the engine INI)
rem   GIMS_DOWNLOAD_DIR where the archive is saved
rem   GIMS_TOOLS_DIR    where wget\wget.exe and 7z\7z.exe live (also on PATH)
rem   GIMS_ENGINE_DIR   where the tool is installed (folder of executable_path)
setlocal EnableExtensions
echo ==================================
echo  RHash Command line Install
echo  script by DSR!
echo ==================================

if "%~1"=="" goto :usage
if not defined GIMS_DOWNLOAD_DIR goto :not_gims
if not defined GIMS_TOOLS_DIR goto :not_gims
if not defined GIMS_ENGINE_DIR goto :not_gims

set "URL=%~1"
set "ARCHIVE=%GIMS_DOWNLOAD_DIR%\rhash.zip"
set "STAGE=%GIMS_DOWNLOAD_DIR%\rhash-extract"
set "WGET=%GIMS_TOOLS_DIR%\wget\wget.exe"
set "SEVENZIP=%GIMS_TOOLS_DIR%\7z\7z.exe"

if not exist "%WGET%" echo ERROR: wget not found: "%WGET%" & exit /b 3
if not exist "%SEVENZIP%" echo ERROR: 7z not found: "%SEVENZIP%" & exit /b 3

if not exist "%GIMS_DOWNLOAD_DIR%\" mkdir "%GIMS_DOWNLOAD_DIR%"
if exist "%STAGE%" rmdir /s /q "%STAGE%"

echo [1/4] Downloading %URL%
rem SourceForge serves the Windows zip only to a wget-like client; a browser User-Agent gets an HTML page.
rem wget follows the redirect chain by itself.
"%WGET%" --no-verbose --user-agent="Wget/1.21.4 (mingw32)" -O "%ARCHIVE%" "%URL%"
if errorlevel 1 goto :download_failed

echo [2/4] Extracting
"%SEVENZIP%" x -y -o"%STAGE%" "%ARCHIVE%"
if errorlevel 1 goto :extract_failed

rem The zip nests everything in a versioned folder; find rhash.exe wherever it is and copy its folder.
set "SOURCE="
for /r "%STAGE%" %%F in (rhash.exe) do if exist "%%F" set "SOURCE=%%~dpF"
if not defined SOURCE goto :no_executable

echo [3/4] Installing to "%GIMS_ENGINE_DIR%"
if not exist "%GIMS_ENGINE_DIR%\" mkdir "%GIMS_ENGINE_DIR%"
xcopy "%SOURCE%*" "%GIMS_ENGINE_DIR%\" /e /y /q >nul
if errorlevel 1 goto :install_failed

echo [4/4] Cleaning up
del /q "%ARCHIVE%"
rmdir /s /q "%STAGE%"
echo RHash installed.
exit /b 0

:usage
echo ERROR: usage: install-rhash.bat URL
exit /b 2

:not_gims
echo ERROR: GIMS_DOWNLOAD_DIR, GIMS_TOOLS_DIR and GIMS_ENGINE_DIR must be set; run this script through GIMS.
exit /b 2

:download_failed
echo ERROR: download failed.
rem A partial file would be mistaken for a good archive on the next run.
if exist "%ARCHIVE%" del /q "%ARCHIVE%"
exit /b 5

:extract_failed
echo ERROR: extraction failed; the archive was kept at "%ARCHIVE%".
exit /b 6

:no_executable
echo ERROR: rhash.exe not found inside the archive.
exit /b 7

:install_failed
echo ERROR: copying to "%GIMS_ENGINE_DIR%" failed.
exit /b 8
