@echo off
setlocal enabledelayedexpansion

REM GSD for Trae - Windows Installation Script
REM Usage: install.bat

echo Installing GSD for Trae...
echo.

REM Save current directory (user's project directory)
set "USER_PROJECT_DIR=%CD%"

REM 1. Set path variables
set "GSD_SOURCE=%USERPROFILE%\.gsd-source"
set "GSD_REPO=https://github.com/glittercowboy/get-shit-done.git"
set "REPO_URL=https://github.com/Lionad-Morotar/get-shit-done-trae"

REM 2. Download GSD source files to %USERPROFILE%\.gsd-source
if exist "%GSD_SOURCE%\.git" (
    echo Updating GSD source files...
    cd /d "%GSD_SOURCE%"
    git pull >nul 2>&1
    if errorlevel 1 (
        echo Update failed, trying to re-clone...
        rmdir /s /q "%GSD_SOURCE%" >nul 2>&1
        git clone --depth 1 "%GSD_REPO%" "%GSD_SOURCE%" >nul 2>&1
    )
) else (
    echo Downloading GSD source files to %GSD_SOURCE%...
    rmdir /s /q "%GSD_SOURCE%" >nul 2>&1
    git clone --depth 1 "%GSD_REPO%" "%GSD_SOURCE%" >nul 2>&1
    if errorlevel 1 (
        echo Git clone failed, please check network connection and Git installation
        exit /b 1
    )
)

REM 3. Create .gsdc directory (Windows doesn't support symlinks, use directory copy)
set "GSDC_PATH=%USERPROFILE%\.gsdc"
if exist "%GSDC_PATH%" (
    rmdir /s /q "%GSDC_PATH%" >nul 2>&1
)

xcopy "%GSD_SOURCE%\commands\gsd" "%GSDC_PATH%" /E /I /Y >nul 2>&1
echo Created command directory: %GSDC_PATH%

REM Return to user's project directory for file operations
cd /d "%USER_PROJECT_DIR%"

REM 4. Check if project_rules.md already exists
if exist ".trae\rules\project_rules.md" (
    for /f "tokens=1-6 delims=:.,/ " %%a in ("%time%") do (
        set "BACKUP_FILE=.trae\rules\project_rules.md.backup.%date:~-4,4%%date:~-10,2%%date:~-7,2%%a%%b%%c"
    )
    echo Found existing .trae\rules\project_rules.md
    echo Backup created: !BACKUP_FILE!
    copy ".trae\rules\project_rules.md" "!BACKUP_FILE!" >nul 2>&1
)

REM 5. Create .trae\rules directory
if not exist ".trae\rules" (
    echo Creating .trae\rules directory...
    mkdir ".trae\rules" >nul 2>&1
)

REM 6. Copy project rule documents
set "RULES_FILES=project_rules.md gsd-agents.md gsd-references.md"

REM Try to copy from script's source directory first
for %%f in (%RULES_FILES%) do (
    if exist ".trae\rules\%%f" (
        echo Copying %%f...
        copy ".trae\rules\%%f" ".trae\rules\%%f" >nul 2>&1
    )
)

REM Download missing files from remote repository
for %%f in (%RULES_FILES%) do (
    if not exist ".trae\rules\%%f" (
        echo Downloading %%f from remote repository...
        powershell -Command "try { Invoke-WebRequest '%REPO_URL%/raw/main/.trae/rules/%%f' -OutFile '.trae\rules\%%f' -UseBasicParsing; echo '   Success: %%f downloaded' } catch { echo '   Warning: %%f download failed' }" 2>nul
    )
)

echo.
echo Installation completed!
echo.
echo File locations:
echo    GSD Source: %GSD_SOURCE%
echo    Command Directory: %GSDC_PATH%
echo    Project Rules: %CD%\.trae\rules\
echo     - project_rules.md
echo     - gsd-agents.md
echo     - gsd-references.md
echo.
echo Getting started:
echo    Type /gsd:new-project when chatting with SOLO Coder in Trae

endlocal