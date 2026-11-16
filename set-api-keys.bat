@echo off
REM Ruan API key-t e Roblox ne menyre te sigurt (nuk shfaqen dhe nuk ruhen ne skedare).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0set-api-keys.ps1"
pause
