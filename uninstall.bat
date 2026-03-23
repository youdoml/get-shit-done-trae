@echo off
setlocal enabledelayedexpansion

REM GSD for Trae - Windows Uninstallation Script
REM Usage: uninstall.bat

echo Uninstalling GSD for Trae...
echo.

REM Save current directory (user's project directory)
set "USER_PROJECT_DIR=%CD%"

REM 1. Delete GSD source files
set "GSD_SOURCE=%USERPROFILE%\.gsd-source"
if exist "%GSD_SOURCE%" (
    echo Deleting GSD source files: %GSD_SOURCE%
    rmdir /s /q "%GSD_SOURCE%" >nul 2>&1
    echo    Deleted
) else (
    echo    GSD source files not found, skipping
)

REM 2. Delete command directory
set "GSDC_PATH=%USERPROFILE%\.gsdc"
if exist "%GSDC_PATH%" (
    echo Deleting command directory: %GSDC_PATH%
    rmdir /s /q "%GSDC_PATH%" >nul 2>&1
    echo    Deleted
) else (
    echo    Command directory not found, skipping
)

REM 3. Delete current project's GSD rule documents (in user's project directory)
cd /d "%USER_PROJECT_DIR%"

set "RULES_FILES=project_rules.md gsd-agents.md gsd-references.md"
set "RULES_DELETED=0"

for %%f in (%RULES_FILES%) do (
    if exist ".trae\rules\%%f" (
        echo Deleting project rule: .trae\rules\%%f
        del ".trae\rules\%%f" >nul 2>&1
        echo    Deleted
        set /a RULES_DELETED+=1
    )
)

if !RULES_DELETED! equ 0 (
    echo    Project rule files not found, skipping
)

REM 4. If directory is empty, ask to delete
if exist ".trae\rules" (
    dir /b ".trae\rules" >nul 2>&1
    if errorlevel 1 (
        echo.
        set /p "DELETE_DIR=.trae\rules directory is empty, delete it? (y/N): "
        if /i "!DELETE_DIR!"=="y" (
            rmdir ".trae\rules" >nul 2>&1
            echo    Deleted .trae\rules directory
        ) else (
            echo    Keeping .trae\rules directory
        )
    )
)

echo.
echo Uninstallation completed!

endlocal