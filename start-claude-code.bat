@echo off
REM Hap Claude Code ne kete dosje dhe i jep udhezimet e plota te projektit.
cd /d "%~dp0"
set "PATH=%USERPROFILE%\.local\bin;%PATH%"
claude "Read CLAUDE-CODE-HANDOFF.md in this folder and carry out the steps in it, one at a time. Talk to me in Albanian and wait for my confirmation after each step."
pause
