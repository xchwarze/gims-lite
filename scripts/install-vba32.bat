@echo off
rem Downloads the VBA32 for Windows Vista+ installer and unpacks the scanner next to the engine executable.
rem The installer is a self-extracting exe whose resource RES_CAB holds a split cabinet (SETUP_1..3.CAB)
rem with the .msi inside; 7z pulls the cabinet out, and lessmsi unpacks the .msi without installing it.
rem Run by GIMS (download_command / update_command): everything comes from injected variables.
rem   %~1               URL of the installer (an argument in the engine INI)
rem   GIMS_DOWNLOAD_DIR where the installer and the temporary work folder go
rem   GIMS_TOOLS_DIR    where wget\wget.exe, 7z\7z.exe and lessmsi\lessmsi.exe live
rem   GIMS_ENGINE_DIR   where the engine is installed (folder of executable_path)
setlocal EnableExtensions
echo ==================================
echo  VBA Command line Install
echo  script by DSR!
echo ==================================

if "%~1"=="" goto :usage
if not defined GIMS_DOWNLOAD_DIR goto :not_gims
if not defined GIMS_TOOLS_DIR goto :not_gims
if not defined GIMS_ENGINE_DIR goto :not_gims

set "URL=%~1"
set "WGET=%GIMS_TOOLS_DIR%\wget\wget.exe"
set "SEVENZIP=%GIMS_TOOLS_DIR%\7z\7z.exe"
set "LESSMSI=%GIMS_TOOLS_DIR%\lessmsi\lessmsi.exe"
set "WORK=%GIMS_DOWNLOAD_DIR%\vba32-work"
set "INSTALLER=%WORK%\installer.exe"

if not exist "%WGET%" echo ERROR: wget not found: "%WGET%" & exit /b 3
if not exist "%SEVENZIP%" echo ERROR: 7z not found: "%SEVENZIP%" & exit /b 3
if not exist "%LESSMSI%" echo ERROR: lessmsi not found: "%LESSMSI%" & exit /b 3

rem A leftover work folder from a failed run would mix old and new files.
if exist "%WORK%\" rmdir /s /q "%WORK%"
mkdir "%WORK%"
if not exist "%GIMS_ENGINE_DIR%\" mkdir "%GIMS_ENGINE_DIR%"
if not exist "%GIMS_ENGINE_DIR%\" echo ERROR: cannot create "%GIMS_ENGINE_DIR%" & exit /b 4

echo [1/5] Downloading %URL%
"%WGET%" --no-verbose -O "%INSTALLER%" "%URL%"
if errorlevel 1 goto :download_failed

echo [2/5] Extracting the cabinet from the installer
"%SEVENZIP%" e -y -o"%WORK%\cab" "%INSTALLER%" ".rsrc\0\RES_CAB\*"
if errorlevel 1 goto :extract_failed
del /q "%INSTALLER%"

echo [3/5] Rebuilding the .msi from the split cabinet
"%SEVENZIP%" x -y -o"%WORK%\msi" "%WORK%\cab\SETUP_1.CAB"
if errorlevel 1 goto :extract_failed
rmdir /s /q "%WORK%\cab"

echo [4/5] Unpacking the .msi
for %%F in ("%WORK%\msi\*.msi") do "%LESSMSI%" x "%%~fF" "%WORK%\files\"
if errorlevel 1 goto :extract_failed
if not exist "%WORK%\files\SourceDir\Vba32\Vba32w.exe" goto :extract_failed
rmdir /s /q "%WORK%\msi"

echo [5/5] Copying the scanner to "%GIMS_ENGINE_DIR%"
robocopy "%WORK%\files\SourceDir\Vba32" "%GIMS_ENGINE_DIR%" /E /NFL /NDL /NJH /NJS /NP
rem robocopy reports success with codes below 8.
if errorlevel 8 goto :copy_failed
rem The help files (.chm) are not needed to scan.
del /s /q "%GIMS_ENGINE_DIR%\*.chm" >nul 2>&1
rmdir /s /q "%WORK%"
echo VBA32 installed.
exit /b 0

:usage
echo ERROR: usage: install-vba32.bat URL
exit /b 2

:not_gims
echo ERROR: GIMS_DOWNLOAD_DIR, GIMS_TOOLS_DIR and GIMS_ENGINE_DIR must be set; run this script through GIMS.
exit /b 2

:download_failed
echo ERROR: download failed.
if exist "%WORK%\" rmdir /s /q "%WORK%"
exit /b 5

:extract_failed
echo ERROR: extraction failed; the work folder was kept at "%WORK%".
exit /b 6

:copy_failed
echo ERROR: copying the files to "%GIMS_ENGINE_DIR%" failed.
exit /b 7
