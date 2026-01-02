@echo off

:: --- Vérification des droits ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Demande de privileges administrateur...
    goto :UACPrompt
) else ( goto :is_admin )

:UACPrompt
    :: Crée un petit script temporaire pour relancer le BAT en admin
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:is_admin
powershell.exe -ExecutionPolicy Bypass -File "MonScript.ps1"
pause