@echo off
REM Konfigurimi: kontrollon programet, ruan ne git dhe dergon ne GitHub.
cd /d "%~dp0"
set "REPO_URL=https://github.com/ReiElezi/RobloxGage-today.git"

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
  echo config.json ekziston tashme. ^(Nuk dergohet ne GitHub.^)
)

echo.
echo ===== 3. Repo git =====
if not exist .git (
  git init >nul
)
git config --local user.name >nul 2>&1 || git config user.name "Rei Elezi"
REM Mos e publiko email-in personal ne GitHub: perdor adresen noreply te GitHub
git config --local user.email >nul 2>&1 || git config user.email "ReiElezi@users.noreply.github.com"
git config --local user.email | findstr /i "@gmail.com" >nul && (
  git config user.email "ReiElezi@users.noreply.github.com"
  git rev-parse --verify HEAD >nul 2>&1 && git rebase -q --root --exec "git commit -q --amend --no-edit --reset-author"
)
git branch -M main
git add -A
git diff --cached --quiet || git commit -q -m "Perditesim i programit Roblox Daily Game"
git log --oneline -3
git status --short

echo.
echo ===== 4. GitHub =====
git remote get-url origin >nul 2>&1 || git remote add origin %REPO_URL%
git push -u origin main
if errorlevel 1 (
  echo Provoj te bashkoj me ate qe ka tashme GitHub...
  git pull --no-rebase --allow-unrelated-histories --no-edit origin main
  git push -u origin main || echo GABIM: dergimi ne GitHub deshtoi. Kontrollo login-in e GitHub.
)

echo.
echo ===== 5. Prove e ndertimit me Rojo =====
"%~dp0rojo.exe" build template\default.project.json -o "%TEMP%\roblox-daily-test.rbxlx" && echo ROJO OK

echo.
echo ===== GATI =====
echo Repo: https://github.com/ReiElezi/RobloxGage-today
pause
