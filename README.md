# Roblox Daily Game — 2 llogari 🎮🎮

> 🤖 **Mënyra më e lehtë:** kliko dy herë **`start-claude-code.bat`**. Claude Code lexon `CLAUDE-CODE-HANDOFF.md` dhe të udhëheq hap pas hapi në shqip.

Çdo herë që e nis (një herë në ditë), programi punon **për secilën llogari Roblox** me radhë:

1. **Claude Code** gjen **top 10 lojërat që fitojnë më shumë sot** (Top Earning).
2. Zgjedh një zhanër prej tyre (obby, tycoon, brainrot, fashion, simulator…), por:
   - jo të njëjtin zhanër si **llogaria tjetër sot**,
   - jo një zhanër që kjo llogari ka përdorur në **7 ditët e fundit**.
3. Krijon një **lojë të re origjinale** me titull që nuk është përdorur më parë.
4. **Kontrollon automatikisht** cilësinë dhe rregullat e Roblox (shiko poshtë).
5. E **publikon LIVE** në lojën e asaj llogarie.

---

## 🛡️ Si e mbron programi nga rregullat e spam-it

Rregullat e Roblox për **Spam** ndalojnë:
- titujt/përshkrimet mashtruese që përdoren për të marrë më shumë lojtarë,
- **ngarkimet e përsëritura** në sistemet e Roblox,
- lojërat që krijohen vetëm për t'i çuar lojtarët jashtë Roblox.

Ndalojnë gjithashtu përdorimin e një llogarie të dytë **për t'i shpëtuar një dënimi** në llogarinë e parë.

Programi e respekton këtë kështu:

| Rreziku | Si mbrohet |
|---|---|
| Ngarkime të përsëritura | **Nuk krijon kurrë lojë të re.** Përditëson të njëjtën lojë (slot) që ke krijuar një herë. **Maksimumi 1 publikim në ditë për llogari** (edhe nëse e nis 10 herë). |
| Lojëra të njëjta në 2 llogaritë | Llogaria 2 **nuk lejohet** të bëjë të njëjtin zhanër si llogaria 1 atë ditë. Çdo llogari ka edhe **stilin** e vet (`style` te `config.json`). Titujt nuk përsëriten kurrë. |
| Gjuha | Lojërat bëhen **vetëm në anglisht** (titulli, përshkrimi, të gjitha tekstet në lojë). Programi refuzon lojën nëse gjen tekst shqip. |
| Tituj mashtrues / clickbait | Programi **refuzon** tituj me `[UPDATE]`, `FREE`, `ROBUX`, `x2`, `EVENT`, `SECRET`, `OG`, kllapa, ose me shkronja të mëdha. |
| Kopjimi i lojërave të tjera | Refuzon titullin/përshkrimin që përmend emrin e një loje nga top 10. |
| Lojë bosh / pa cilësi | Refuzon nëse kodi është shumë i vogel, nëse ka mbetur placeholder, ose nëse mungon SpawnLocation apo DESIGN.md. |
| Teksti i lojtarëve pa filtër | Refuzon nëse lojtarët mund të shkruajnë tekst pa `TextService:FilterStringAsync` (Roblox i heq lojërat pa filtrim). |
| Kod i rrezikshëm | Refuzon `loadstring`, `getfenv` dhe `require(ID)`. |

Nëse kontrolli dështon, programi i kërkon **një herë** Claude Code ta rregullojë. Nëse dështon përsëri, **nuk publikon** dhe kalon te llogaria tjetër.

### Rregulla që duhet t'i mbash vetë

1. **Mos i përdor 2 llogaritë për t'i rritur njëra-tjetrës vizitat, likes ose favorites.** Mos hyr me njërën llogari për të luajtur lojën e tjetrës për numra, dhe mos përdor bot-e. Kjo është manipulim.
2. **Nëse njëra llogari merr ndalim (ban/warning), mos e vazhdo të njëjtën gjë me llogarinë tjetër.** Kjo është pikërisht ajo që ndalohet. Ndalo programin për atë llogari dhe kupto çfarë ndodhi.
3. **Mos e përdor `-Force` çdo ditë.** Ekziston vetëm për rastin kur publikimi i parë doli me gabim.
4. **Mos krijo shumë slot-e.** Kemi 7 lojëra për llogari (një për çdo ditë të javës). Mos shto shumë më tepër: dhjetëra lojëra që ndryshojnë vazhdimisht duken si spam.
5. **Provoje lojën** (`-Preview`), sidomos javën e parë.

---

## Hapi 1 — Instalo programet (vetëm një herë)

1. **Claude Code** — duhet ta kesh të instaluar dhe të jesh i loguar. Provo në PowerShell: `claude --version`
2. **Rojo**:
   1. Hap https://github.com/rojo-rbx/rojo/releases
   2. Shkarko `rojo-7.x.x-windows-x86_64.zip`
   3. Vendos **`rojo.exe` në të njëjtën dosje me `run-daily.ps1`**
3. **Roblox Studio** — për të krijuar lojërat bosh dhe për t'i provuar.

## Hapi 2 — Krijo lojën bosh në ÇDO llogari (vetëm një herë)

Bëje këtë **dy herë**: një herë i loguar në **llogarinë 1**, pastaj në **llogarinë 2**.

1. Hap **Roblox Studio** dhe hyr me llogarinë (lart djathtas → Log Out / Log In nëse duhet ndërruar)
2. **New** → **Baseplate**
3. **File → Publish to Roblox** → jepi një emër → **Create**
4. Hap https://create.roblox.com/dashboard/creations (me të njëjtën llogari) dhe kliko lojën
5. Plotëso **Maturity & Compliance Questionnaire**
6. Bëje lojën **Public**
7. Kliko **Places** → kliko place-in → shiko URL-në:
   `.../experiences/`**`1111111`**`/places/`**`2222222`**`/configure`
   - numri i parë = **universeId**, numri i dytë = **placeId**
8. Shkruaji diku dhe shëno për cilën llogari janë.

## Hapi 3 — Krijo një API Key për ÇDO llogari (vetëm një herë)

Edhe këtë bëje **dy herë**, i loguar në llogarinë përkatëse në shfletues:

1. Hap https://create.roblox.com/dashboard/credentials → **Create API Key**
2. **Name**: `daily-game`
3. **Access Permissions** → **universe-places** → **Add API System**
4. Zgjidh lojën e kësaj llogarie → operacioni **Write**
5. **Accepted IP Addresses**: `0.0.0.0/0` (ose IP-ja jote)
6. **Save & Generate Key** → **Copy**
7. Kliko dy herë **`set-api-keys.bat`** dhe ngjit çelësin e secilës llogari kur të pyesë
   (teksti nuk shfaqet në ekran dhe nuk ruhet në asnjë skedar).
8. **Mbyll dhe rihap PowerShell.**

> 🔒 Mos i vendos çelësat në asnjë skedar dhe mos ia jep askujt. Mos i ngatërro: çelësi 1 punon vetëm për lojën e llogarisë 1.

## Hapi 4 — Konfigurimi (vetëm një herë)

1. Kopjo `config.example.json` → riemërtoje **`config.json`**
2. Hape me Notepad dhe vendos numrat nga Hapi 2:
   ```json
   {
     "accounts": [
       {
         "name": "Llogaria 1",
         "apiKeyEnv": "ROBLOX_API_KEY_1",
         "style": "Bright, colorful, fast-paced games for younger players.",
         "slots": [ { "name": "Loja A", "universeId": 1111111, "placeId": 2222222 } ]
       },
       {
         "name": "Llogaria 2",
         "apiKeyEnv": "ROBLOX_API_KEY_2",
         "style": "Calmer, cleaner look; collecting, building and progression games.",
         "slots": [ { "name": "Loja B", "universeId": 3333333, "placeId": 4444444 } ]
       }
     ]
   }
   ```
   - `style` = stili i lojërave të asaj llogarie (në anglisht). Mbaji **të ndryshëm**, që të 2 llogaritë të mos duken njësoj.

## Hapi 5 — Ruaje në GitHub

Kliko dy herë **`setup.bat`**. Ai:
- kontrollon Git, Claude Code dhe Rojo,
- ruan ndryshimet në git (me adresën noreply të GitHub, jo me email-in tënd personal),
- i dërgon te https://github.com/ReiElezi/RobloxGage-today

Herën e parë mund të të kërkojë login në GitHub në shfletues.
`config.json`, `history.json`, `games/`, `logs/` dhe `rojo.exe` **nuk dërgohen kurrë** në GitHub.

> Në një kompjuter tjetër: `git clone https://github.com/ReiElezi/RobloxGage-today.git`, pastaj shkarko `rojo.exe` (Hapi 1) dhe bëj Hapat 3–4.

## Hapi 6 — Nisja automatike çdo ditë

Kliko dy herë **`schedule-daily.bat`**. Programi niset vetë çdo ditë në orën e shkruar brenda skedarit (11:17). Ora ndryshon brenda skedarit.
- Laptopi duhet të jetë i ndezur dhe ti i loguar në Windows në atë orë.
- Çdo nisje ruhet te `logs\`.
- Për ta ndaluar: **`unschedule-daily.bat`**.

## Nisja me dorë (kur të duash)

**Mënyra e thjeshtë:** kliko dy herë **`run-daily.bat`**.

| Komanda (PowerShell, brenda dosjes) | Çfarë bën |
|---|---|
| `.\run-daily.ps1` | të dyja llogaritë, të pyet "po/jo" para çdo publikimi |
| `.\run-daily.ps1 -Preview` | i hap në Roblox Studio që t'i provosh para se të pyesë |
| `.\run-daily.ps1 -Auto` | publikon pa pyetur (vetëm lojërat që kalojnë kontrollet) |
| `.\run-daily.ps1 -Account "Llogaria 2"` | vetëm një llogari |
| `.\run-daily.ps1 -NoPublish` | vetëm krijon, nuk publikon |

Për 2 llogari duhen rreth **20–60 minuta**. Në fund shfaqet përmbledhja me linket.

## Ku ruhen gjërat

- `games/2026-11-16/Llogaria-1/` dhe `.../Llogaria-2/` — kodi, `game.rbxlx`, `DESIGN.md`, `game.json`, `claude-log.txt`
- `history.json` — çfarë u publikua, kur dhe në cilën llogari (përdoret për rregullat anti-spam)
- `prompts/daily-game.md` — komanda për Claude Code
- `template/CLAUDE.md` — rregullat e cilësisë dhe të Roblox për çdo lojë

## Gjëra të rëndësishme

- Çdo ditë programi zgjedh një slot: fillimisht ato që s'janë përdorur kurrë, pastaj atë që është përditësuar më herët. Kështu **lojërat e 6 ditëve të fundit mbeten dhe luhen**; vetëm loja më e vjetër zëvendësohet.
- **Titulli, përshkrimi dhe ikona nuk ndryshojnë automatikisht.** Programi t'i shfaq në fund: kopjoji te Creator Dashboard dhe përshtati me lojën e re, që të mos jenë mashtruese.
- Çdo nisje harxhon nga limiti i abonimit tënd të Claude (2 lojëra = 2 herë më shumë).

## Probleme të shpeshta

| Mesazhi | Zgjidhja |
|---|---|
| `'rojo' nuk u gjet` | Vendos `rojo.exe` në dosjen e programit |
| `Mungon API key: variabli ROBLOX_API_KEY_2...` | Bëj Hapin 3 për atë llogari dhe **rihap** PowerShell |
| `u kalua - u publikua tashme sot` | Normale: maksimumi 1 lojë në ditë për llogari |
| `Loja nuk kaloi kontrollet` | Shiko listën e problemeve dhe `claude-log.txt`; nise përsëri nesër ose me `-Account` |
| `HTTP 401` | API key i gabuar ose i skaduar |
| `HTTP 403` | Key-i nuk ka **universe-places → Write**, ose është krijuar nga llogaria tjetër |
| `HTTP 404` / `409` | `universeId` / `placeId` gabim te `config.json` |
| "running scripts is disabled" | Përdor `run-daily.bat` |
