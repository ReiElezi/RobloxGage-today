@echo off
REM Kliko dy here kete skedar per te krijuar dhe publikuar lojen e sotme.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-daily.ps1" %*
pause
