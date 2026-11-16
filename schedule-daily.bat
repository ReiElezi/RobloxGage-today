@echo off
REM Planifikon programin qe te niset VETE cdo dite (Windows Task Scheduler).
REM Ndrysho oren ketu nese do (format 24h):
set ORA=11:17
schtasks /Create /F /SC DAILY /ST %ORA% /TN "RobloxDailyGame" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%~dp0run-daily.ps1\" -Auto"
if errorlevel 1 (
  echo GABIM: planifikimi deshtoi.
) else (
  echo.
  echo OK: loja e re krijohet dhe publikohet vete cdo dite ne ora %ORA%.
  echo Laptopi duhet te jete i ndezur dhe ti i loguar ne Windows ne ate ore.
  echo Rezultatet ruhen te dosja logs\
  echo Per ta ndaluar: kliko dy here unschedule-daily.bat
)
pause
