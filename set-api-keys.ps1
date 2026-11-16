# Ruan API key-t e Roblox si variabla te perdoruesit (ROBLOX_API_KEY_1, ROBLOX_API_KEY_2).
# Teksti qe ngjit nuk shfaqet ne ekran dhe nuk ruhet ne asnje skedar.
foreach ($n in 1, 2) {
    $secure = Read-Host "Ngjit API key-n e Llogarise $n (Enter bosh = kalo)" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    if ($plain) {
        [Environment]::SetEnvironmentVariable("ROBLOX_API_KEY_$n", $plain.Trim(), 'User')
        Write-Host "OK: ROBLOX_API_KEY_$n u ruajt." -ForegroundColor Green
    } else {
        Write-Host "U kalua Llogaria $n." -ForegroundColor Yellow
    }
    $plain = $null
}
Write-Host "`nGati. Mbyll dhe rihap PowerShell qe te lexohen celesat e rinj."
