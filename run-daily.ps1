<#
  Roblox Daily Game - 2 llogari
  Per cdo llogari ne config.json:
    - Claude Code gjen zhanret Top Earning te sotme ne Roblox
    - krijon nje loje te re origjinale (zhanri ndryshe nga llogaria tjeter sot)
    - kontrollon cilesine dhe rregullat kunder spam-it
    - e publikon LIVE ne lojen (slot-in) ekzistuese te asaj llogarie

  Perdorimi:
    .\run-daily.ps1                     # te dyja llogarite, pyet para cdo publikimi
    .\run-daily.ps1 -Preview            # i hap ne Roblox Studio para se te pyese
    .\run-daily.ps1 -Auto               # publikon pa pyetur (vetem nese kalon kontrollet)
    .\run-daily.ps1 -Account "Llogaria 1"  # vetem nje llogari
    .\run-daily.ps1 -NoPublish          # vetem krijon, nuk publikon
    .\run-daily.ps1 -Force              # lejon publikim te dyte ne te njejten dite (mos e perdor shpesh)
#>
param(
    [switch]$Auto,
    [switch]$Preview,
    [switch]$NoPublish,
    [switch]$Force,
    [string]$Account,
    [string]$Genre        # p.sh. "obby"; bosh ose "auto" = Claude zgjedh nga Top 10
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Root = $PSScriptRoot

# Ruaj gjithcka qe shfaqet ne logs\ (e dobishme kur niset vete nga Task Scheduler)
$logDir = Join-Path $Root 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
try { Start-Transcript -Path (Join-Path $logDir ("run-" + (Get-Date -Format 'yyyy-MM-dd_HHmm') + ".txt")) | Out-Null } catch { }

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Warn($msg) { Write-Host "KUJDES: $msg" -ForegroundColor Yellow }
function Fail($msg) { Write-Host "`nGABIM: $msg" -ForegroundColor Red; exit 1 }

$AllowedTools = 'Read,Write,Edit,MultiEdit,Glob,Grep,WebSearch,WebFetch,TodoWrite,Bash(rojo build:*),Bash(rojo --version)'

function Invoke-Claude([string]$dir, [string]$text, [switch]$Continue) {
    Push-Location $dir
    try {
        $log = Join-Path $dir 'claude-log.txt'
        if ($Continue) {
            $text | claude -p --continue --permission-mode acceptEdits --allowedTools $AllowedTools |
                Tee-Object -FilePath $log -Append
        } else {
            $text | claude -p --permission-mode acceptEdits --allowedTools $AllowedTools |
                Tee-Object -FilePath $log
        }
        if ($LASTEXITCODE -ne 0) { Warn "Claude Code mbaroi me kod $LASTEXITCODE" }
    } finally {
        Pop-Location
    }
}

function Build-Place([string]$dir) {
    $place = Join-Path $dir 'game.rbxlx'
    if (Test-Path $place) { Remove-Item $place -Force }
    & rojo build (Join-Path $dir 'default.project.json') -o $place | Out-Host
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $place)) { return $null }
    return $place
}

function Read-GameJson([string]$dir) {
    $p = Join-Path $dir 'game.json'
    if (-not (Test-Path $p)) { return $null }
    try { return (Get-Content $p -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { return $null }
}

function Contains-Text([string]$haystack, [string]$needle) {
    if (-not $haystack -or -not $needle) { return $false }
    return $haystack.IndexOf($needle, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
}

# Kontrollet e cilesise dhe kunder spam-it. Kthen listen e problemeve (bosh = OK).
function Test-Game([string]$dir, $game, [string[]]$previousTitles) {
    $p = @()
    if (-not $game) { return @('game.json mungon ose nuk eshte JSON i vlefshem') }

    # --- Metadata e sinqerte (rregulli Spam i Roblox) ---
    $title = [string]$game.title
    $desc = [string]$game.description
    if (-not $title) { $p += 'Titulli mungon' }
    elseif ($title.Length -gt 50) { $p += 'Titulli eshte me i gjate se 50 shkronja' }
    if ($title -match '[\[\]\(\)\{\}]') { $p += 'Titulli ka kllapa (p.sh. [UPDATE]) - ndalohet per te mos mashtruar' }
    if ($title -cmatch '^[^a-z]*$' -and $title -match '[A-Z]{4,}') { $p += 'Titulli eshte i gjithi me shkronja te medha' }
    if (-not $desc -or $desc.Length -lt 40) { $p += 'Pershkrimi mungon ose eshte shume i shkurter' }
    $badTitle = '(?i)\b(free|robux|giveaway|gratis|admin|update|upd|event|limited|secret|og|x2|2x|x10|10x)\b'
    $m = [regex]::Matches($title, $badTitle)
    foreach ($x in $m) { $p += "Titulli permban '$($x.Value)' (clickbait / mashtrues)" }
    foreach ($w in @('free robux', 'robux free', 'giveaway', 'robux gratis', 'free admin')) {
        if (Contains-Text $desc $w) { $p += "Pershkrimi permban '$w'" }
    }
    foreach ($name in @($game.inspiredByTopEarners)) {
        $n = ([string]$name -replace '[\[\]\(\)]', '').Trim()
        if ($n.Length -ge 4 -and ((Contains-Text $title $n) -or (Contains-Text $desc $n))) {
            $p += "Titulli/pershkrimi permend lojen tjeter '$n' (kopjim emri)"
        }
    }
    foreach ($t in $previousTitles) {
        if ($t -and $title -and $t.Trim().ToLower() -eq $title.Trim().ToLower()) { $p += "Titulli '$title' eshte perdorur me pare" }
    }

    # --- Loje e vertete, jo placeholder ---
    $src = Join-Path $dir 'src'
    $files = @(Get-ChildItem $src -Recurse -Filter *.luau -ErrorAction SilentlyContinue)
    $code = ($files | ForEach-Object { Get-Content $_.FullName -Raw -Encoding UTF8 }) -join "`n"
    if ($files.Count -lt 4) { $p += "Vetem $($files.Count) skedare kodi (duhen te pakten 4)" }
    if ($code.Length -lt 6000) { $p += 'Kodi eshte shume i vogel per nje loje te plote' }
    if ($code -match 'Placeholder') { $p += 'Ka mbetur kod placeholder' }
    if (-not (Test-Path (Join-Path $dir 'DESIGN.md'))) { $p += 'Mungon DESIGN.md' }
    if ($code -notmatch 'SpawnLocation') { $p += 'Nuk krijohet SpawnLocation' }

    # --- Siguria (Roblox mund ta heqe lojen pa filtrim teksti) ---
    if ($code -match 'TextBox' -and $code -notmatch 'FilterStringAsync') {
        $p += 'Lojtaret shkruajne tekst (TextBox) por teksti nuk filtrohet me TextService:FilterStringAsync'
    }
    # --- Vetem anglisht (titulli, pershkrimi, tekstet ne kod) ---
    $nonEn = '[ëËçÇ]|\b(Fillo|Luaj|Dyqan|Bli|Monedha|Niveli|Fitove|Kliko|Shtyp)\b'
    if ("$title $desc $([string]$game.howToPlay)" -match $nonEn) { $p += 'Titulli/pershkrimi nuk eshte ne anglisht (loja duhet te jete vetem anglisht)' }
    if ($code -match $nonEn) { $p += 'Kodi ka tekst jo-anglisht (shkronja e/c shqipe ose fjale shqip) - te gjitha tekstet duhet te jene ne anglisht' }
    if ($code -match 'getfenv|setfenv|loadstring|require\(\s*\d') { $p += 'Kod i ndaluar/i rrezikshem (loadstring/require me ID)' }
    return $p
}

# ---------------- Kontrollet fillestare ----------------
Step "Kontrolloj programet dhe konfigurimin"
if (Test-Path (Join-Path $Root 'rojo.exe')) { $env:PATH = "$Root;$env:PATH" }
$claudeBin = Join-Path $env:USERPROFILE '.local\bin'
if (Test-Path $claudeBin) { $env:PATH = "$claudeBin;$env:PATH" }
foreach ($cmd in 'claude', 'rojo') {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { Fail "'$cmd' nuk u gjet. Shiko README.md, hapi 1." }
}
$cfgPath = Join-Path $Root 'config.json'
if (-not (Test-Path $cfgPath)) { Fail "Mungon config.json. Kopjo config.example.json si config.json dhe plotesoje." }
$cfg = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
$accounts = @($cfg.accounts)
if ($Account) { $accounts = @($accounts | Where-Object { $_.name -eq $Account }) }
if ($accounts.Count -eq 0) { Fail "Asnje llogari ne config.json (ose emri -Account nuk perputhet)." }

$histPath = Join-Path $Root 'history.json'
$history = @()
if (Test-Path $histPath) { $history = @(Get-Content $histPath -Raw -Encoding UTF8 | ConvertFrom-Json) }

$date = Get-Date -Format 'yyyy-MM-dd'
$todayGenres = [System.Collections.Generic.List[string]]::new()
foreach ($h in $history) { if ($h.date -eq $date -and $h.genre) { $todayGenres.Add([string]$h.genre) } }

$summary = @()
$results = @()
$index = 0

# ---------------- Per cdo llogari ----------------
foreach ($acc in $accounts) {
    $index++
    Write-Host "`n#############################################" -ForegroundColor Magenta
    Write-Host "  LLOGARIA $index : $($acc.name)" -ForegroundColor Magenta
    Write-Host "#############################################" -ForegroundColor Magenta
    try {
        $slots = @($acc.slots | Where-Object { $_.universeId -gt 0 -and $_.placeId -gt 0 })
        $apiKey = $null
        if ($acc.apiKeyEnv) {
            $apiKey = [Environment]::GetEnvironmentVariable([string]$acc.apiKeyEnv, 'Process')
            if (-not $apiKey) { $apiKey = [Environment]::GetEnvironmentVariable([string]$acc.apiKeyEnv, 'User') }
        }
        if (-not $NoPublish) {
            if (-not $apiKey) { throw "Mungon API key: variabli $($acc.apiKeyEnv) nuk eshte vendosur (README, hapi 3)." }
            if ($slots.Count -eq 0) { throw "Kjo llogari nuk ka slot me universeId/placeId te sakte." }
        }
        # Rezerva: perdoren vetem lojerat bosh (qe s'jane publikuar kurre). Lojerat e vjetra nuk prekan.
        $usedIds = @($history | ForEach-Object { [string]$_.placeId })
        $freeSlots = @($slots | Where-Object { $usedIds -notcontains [string]$_.placeId })
        if (-not $NoPublish -and $freeSlots.Count -eq 0) {
            throw "Rezerva mbaroi: te gjitha $($slots.Count) lojerat jane perdorur. Krijo lojera te reja bosh dhe shtoji te config.json."
        }

        # Anti-spam: maksimumi 1 publikim ne dite per llogari
        $doneToday = @($history | Where-Object { $_.account -eq $acc.name -and $_.date -eq $date })
        if ($doneToday.Count -gt 0 -and -not $Force -and -not $NoPublish) {
            Write-Host "Kjo llogari ka publikuar sot ('$($doneToday[0].title)'). E kaloj (maksimumi 1 loje/dite)." -ForegroundColor Yellow
            $summary += "$($acc.name): u kalua - u publikua tashme sot"
            $results += [pscustomobject]@{ status = 'skipped'; account = [string]$acc.name; title = [string]$doneToday[0].title
                error = 'Sot eshte publikuar tashme nje loje (maksimumi 1 ne dite).' }
            continue
        }

        # Dosja
        $slug = ([string]$acc.name -replace '[^A-Za-z0-9]+', '-').Trim('-')
        if (-not $slug) { $slug = "llogaria-$index" }
        $dir = Join-Path $Root "games\$date\$slug"
        if (Test-Path $dir) { $dir = "$dir-" + (Get-Date -Format 'HHmm') }
        New-Item -ItemType Directory -Force -Path (Split-Path $dir) | Out-Null
        Copy-Item -Path (Join-Path $Root 'template') -Destination $dir -Recurse
        Step "Dosja: $dir"

        # Cfare duhet shmangur
        $accHist = @($history | Where-Object { $_.account -eq $acc.name })
        $avoid = @($accHist | Select-Object -Last 7 | ForEach-Object { [string]$_.genre }) + @($todayGenres) |
            Where-Object { $_ } | Select-Object -Unique
        $avoidText = if ($avoid) { $avoid -join ', ' } else { '(none)' }
        $prevTitles = @($history | ForEach-Object { [string]$_.title } | Where-Object { $_ })
        $titlesText = if ($prevTitles) { (@($prevTitles | Select-Object -Last 40)) -join ' | ' } else { '(none)' }
        $style = if ($acc.style) { [string]$acc.style } else { 'No fixed style.' }

        $prompt = Get-Content (Join-Path $Root 'prompts\daily-game.md') -Raw -Encoding UTF8
        $prompt = $prompt.Replace('{{DATE}}', $date).Replace('{{AVOID_GENRES}}', $avoidText).
            Replace('{{PREVIOUS_TITLES}}', $titlesText).Replace('{{STYLE}}', $style)

        if ($Genre -and $Genre -ne 'auto') {
            $prompt += "`n`n## OWNER'S CHOICE (overrides Step 2)`nThe owner chose today's genre: **$Genre**. Build a game in exactly this genre (still research the top 10 for inspiration, still original, still English only). Ignore the avoid-genres list for this choice.`n"
        }

        Step "Claude Code po krijon lojen per '$($acc.name)' (10-30 min)..."
        Invoke-Claude -dir $dir -text $prompt
        $claudeExit = $LASTEXITCODE
        $logFile = Join-Path $dir 'claude-log.txt'
        $logTail = if (Test-Path $logFile) { ((Get-Content $logFile -Encoding UTF8 -ErrorAction SilentlyContinue | Select-Object -Last 15) -join "`n") } else { '(claude-log.txt mungon)' }
        if ($claudeExit -ne 0 -or -not (Test-Path (Join-Path $dir 'game.json'))) {
            throw "Claude Code nuk e krijoi lojen (kodi $claudeExit). Fundi i log-ut:`n$logTail"
        }

        # Build + kontrolle, me nje rrethim riparimi automatik
        $place = $null; $game = $null; $problems = @()
        for ($round = 1; $round -le 2; $round++) {
            Step "Ndertoj dhe kontrolloj (rrethi $round)"
            $place = Build-Place $dir
            $game = Read-GameJson $dir
            $problems = @()
            if (-not $place) { $problems += 'rojo build deshtoi' }
            $problems += @(Test-Game -dir $dir -game $game -previousTitles $prevTitles)
            if ($problems.Count -eq 0) { break }
            Warn "U gjeten probleme:"; $problems | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
            if ($round -eq 1) {
                Step "I kerkoj Claude Code t'i rregulloje..."
                $fix = "The automatic quality and anti-spam check failed. Fix ALL of these problems, then run rojo build again and update game.json:`n- " + ($problems -join "`n- ")
                Invoke-Claude -dir $dir -text $fix -Continue
            }
        }
        if ($problems.Count -gt 0) { throw ("Loja nuk kaloi kontrollet - NUK publikohet:`n- " + ($problems -join "`n- ")) }
        # Zhanri i sotem rezervohet qe llogaria tjeter te beje dicka ndryshe
        $todayGenres.Add([string]$game.genre)

        Write-Host ""
        Write-Host "Titulli   : $($game.title)" -ForegroundColor Green
        Write-Host "Zhanri    : $($game.genre)" -ForegroundColor Green
        Write-Host "Pershkrimi: $($game.descriptionAlbanian)"
        Write-Host "Skedari   : $place"

        if ($Preview) { Step "E hap ne Roblox Studio (shtyp Play per ta provuar)"; Start-Process $place }

        if ($NoPublish) {
            $summary += "$($acc.name): u krijua '$($game.title)' (pa publikim)"
                        continue
        }

        # Loja e radhes bosh nga rezerva (sipas radhes ne config.json)
        $slot = $freeSlots[0]
        if (-not $Auto) {
            $ans = Read-Host "`nTa publikoj LIVE '$($game.title)' te '$($acc.name)' / '$($slot.name)'? (po/jo)"
            if ($ans -notmatch '^(p|po|y|yes)$') {
                $summary += "$($acc.name): u anulua nga ti"
                continue
            }
        }

        Step "Publikoj ne Roblox..."
        $apiBase = if ($env:ROBLOX_API_BASE) { $env:ROBLOX_API_BASE } else { 'https://apis.roblox.com' }
        $uri = "$apiBase/universes/v1/$($slot.universeId)/places/$($slot.placeId)/versions?versionType=Published"
        try {
            $resp = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ 'x-api-key' = $apiKey } `
                -ContentType 'application/xml' -InFile $place
        } catch {
            $code = $null
            try { $code = $_.Exception.Response.StatusCode.value__ } catch { }
            $hint = switch ($code) {
                401 { 'API key i gabuar ose i skaduar.' }
                403 { 'API key nuk ka universe-places: Write per kete loje, ose IP nuk lejohet. A e krijove key-n nga KJO llogari?' }
                404 { 'universeId ose placeId gabim.' }
                409 { 'Konflikt: zakonisht Team Create eshte ndezur per kete loje (fike te Studio: File > Collaborate / Experience Settings), ose placeId nuk i perket universeId.' }
                429 { 'Shume kerkesa - provo pas 1 minute.' }
                default { '' }
            }
            $detail = try { [string]$_.ErrorDetails.Message } catch { '' }
            throw "Publikimi deshtoi (HTTP $code). $hint $($_.Exception.Message) $detail"
        }

        $link = "https://www.roblox.com/games/$($slot.placeId)"
        Write-Host "`nU PUBLIKUA! Versioni $($resp.versionNumber) - $link" -ForegroundColor Green
        # Emri dhe pershkrimi i lojes ne Roblox = ato te lojes se re (qe te mos jene mashtruese)
        try {
            $meta = @{ displayName = [string]$game.title; description = [string]$game.description } | ConvertTo-Json
            $metaUri = "$apiBase/cloud/v2/universes/$($slot.universeId)/places/$($slot.placeId)?updateMask=displayName,description"
            Invoke-RestMethod -Method Patch -Uri $metaUri -Headers @{ 'x-api-key' = $apiKey } `
                -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($meta)) | Out-Null
            Write-Host "Emri dhe pershkrimi u vendosen automatikisht ne Roblox." -ForegroundColor Green
        } catch {
            Warn "Emri/pershkrimi nuk u ndryshuan automatikisht ($($_.Exception.Message)). Vendosi me dore ne Creator Dashboard:"
            Write-Host "  $($game.title)"
            Write-Host "  $($game.description)"
        }

        $history = @($history) + [pscustomobject]@{
            date    = $date
            account = [string]$acc.name
            title   = [string]$game.title
            genre   = [string]$game.genre
            slot    = [string]$slot.name
            placeId = $slot.placeId
            version = $resp.versionNumber
        }
        ConvertTo-Json -InputObject @($history) -Depth 5 | Set-Content -Path $histPath -Encoding UTF8
        $left = $freeSlots.Count - 1
        $summary += "$($acc.name): '$($game.title)' ($($game.genre)) LIVE - $link"
        $results += [pscustomobject]@{ status = 'live'; account = [string]$acc.name; title = [string]$game.title
            genre = [string]$game.genre; description = [string]$game.description; link = $link; slotsLeft = $left }
    } catch {
        Write-Host "`nGABIM te '$($acc.name)': $($_.Exception.Message)" -ForegroundColor Red
        $summary += "$($acc.name): GABIM - $($_.Exception.Message)"
        $results += [pscustomobject]@{ status = 'error'; account = [string]$acc.name; error = $_.Exception.Message }
    }
}

# Rezultati per njoftimin ne GitHub
ConvertTo-Json -InputObject @($results) -Depth 4 | Set-Content -Path (Join-Path $Root 'last-result.json') -Encoding UTF8

Write-Host "`n================ PERMBLEDHJE ================" -ForegroundColor Cyan
$summary | ForEach-Object { Write-Host " - $_" }

try { Stop-Transcript | Out-Null } catch { }

if (@($results | Where-Object { $_.status -eq 'error' }).Count -gt 0) { exit 1 }
