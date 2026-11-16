# Instalon Claude Code me instaluesin zyrtar (https://claude.ai/install.ps1)
# dhe te hap Claude Code qe te logohesh.
$ErrorActionPreference = 'Stop'
Write-Host "==> Instaloj Claude Code (instaluesi zyrtar nga claude.ai)..." -ForegroundColor Cyan
irm https://claude.ai/install.ps1 | iex

# Sigurohu qe claude eshte ne PATH (edhe per dritaret e reja)
$d = Join-Path $env:USERPROFILE '.local\bin'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ((Test-Path $d) -and ($userPath -notlike "*$d*")) {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$d", 'User')
    Write-Host "U shtua $d ne PATH." -ForegroundColor Green
}
$env:PATH = "$d;$env:PATH"

Write-Host "`n==> Versioni:" -ForegroundColor Cyan
claude --version

Write-Host "`n==> Tani hapet Claude Code. Ndiq hapat ne ekran per t'u loguar me llogarine tende Claude." -ForegroundColor Cyan
Write-Host "    Kur te shohesh qe je brenda, shkruaj /exit dhe shtyp Enter." -ForegroundColor Cyan
claude
