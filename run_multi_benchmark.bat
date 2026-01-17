@echo off
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: PowerShell is not installed or not in your PATH.
    pause
    exit /b 1
)
powershell -ExecutionPolicy ByPass -File "%~dp0run_multi_after_compilation.ps1"
pause