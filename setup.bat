@echo off
REM Konfigurimi i pare: kontrollon programet dhe krijon repon git.
cd /d "%~dp0"
echo.
echo ===== 1. Kontrolloj programet =====
where git >nul 2>&1 && (git --version) || echo GABIM: Git nuk u gjet. Instalo nga https://git-scm.com
set "PATH=%USERPROFILE%\.local\bin;%PATH%"
where claude >nul 2>&1 && (call claude --version) || echo GABIM: Claude Code nuk u gjet. Kliko dy here install-claude-code.bat
"%~dp0rojo.exe" --version || echo GABIM: rojo.exe nuk punon.

echo.
echo ===== 2. config.json =====
if not exist config.json (
  copy config.example.json config.json >nul
  echo U krijua config.json - plotesoje me universeId/placeId te dy llogarive.
) else (
  echo config.json ekziston tashme.
)

echo.
echo ===== 3. Repo git =====
if not exist .git (
  git init >nul
  git checkout -b main >nul 2>&1
  git config user.name >nul 2>&1 || git config user.name "Rei"
  git config user.email >nul 2>&1 || git config user.email "elezirei8@gmail.com"
  git add -A
  git commit -q -m "Roblox Daily Game: 2 llogari, publikim ditor me kontrolle anti-spam"
) else (
  git add -A
  git diff --cached --quiet || git commit -q -m "Perditesim i konfigurimit"
)
git log --oneline -1
git status --short

echo.
echo ===== 4. Prove e ndertimit me Rojo =====
"%~dp0rojo.exe" build template\default.project.json -o "%TEMP%\roblox-daily-test.rbxlx" && echo ROJO OK

echo.
echo ===== GATI =====
echo Hapi tjeter: README.md, hapat 2-4 (lojet bosh, API key-t, config.json).
pause
