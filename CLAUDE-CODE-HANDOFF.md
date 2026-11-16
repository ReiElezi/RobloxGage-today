# Handoff for Claude Code — Roblox Daily Game (Rei)

You are Claude Code running on Rei's Windows laptop, inside `C:\Users\User\Documents\roblox-daily`.
This file summarizes a long conversation Rei had with Claude (chat). Your job: **finish the setup
so the whole thing runs by itself**, guiding Rei through the few steps only he can do.

**Talk to Rei in Albanian. Give one action at a time, numbered, and wait for him to confirm before moving on.**
Rei is not a programmer — say exactly where to click and what to type.

---

## 1. What Rei wants (the goal)

- Every day, a **new original Roblox game** is generated automatically by Claude Code
  (headless `claude -p`) and **published LIVE on Roblox** so people can play it.
- The genre is chosen from the **top 10 Top-Earning Roblox games of that day**
  (obby, brainrot/collect-and-steal, fashion, tycoon, simulator, tower defense…).
- **2 Roblox accounts**, each gets its own new game every day.
- Must respect **Roblox rules against spam** (no repetitive uploads, no misleading metadata,
  no clones, no using one account to dodge a ban on the other).
- Rei wants it **automated**: he does NOT want a Claude chat controlling his computer every day.
  After this one-time setup, the daily run must work without any Claude chat.
- Code lives in the GitHub repo **https://github.com/ReiElezi/RobloxGage-today**.

## 2. How the system works (already built — do not rewrite unless asked)

| File | Purpose |
|---|---|
| `run-daily.ps1` / `run-daily.bat` | Main script. For each account in `config.json`: copies `template/` to `games/<date>/<account>/`, runs `claude -p` with `prompts/daily-game.md`, builds `game.rbxlx` with Rojo, runs quality + anti-spam checks (one automatic fix round via `claude -p --continue`), then publishes via Roblox Open Cloud Place Publishing API (`POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published`, header `x-api-key`). Writes `history.json`, logs to `logs/`. Flags: `-Auto`, `-Preview`, `-NoPublish`, `-Force`, `-Account "<name>"`. |
| `prompts/daily-game.md` | Prompt for the headless game generator (research top 10 → pick genre → design → build → `rojo build` → write `game.json`). Placeholders `{{DATE}}`, `{{AVOID_GENRES}}`, `{{PREVIOUS_TITLES}}`, `{{STYLE}}`. |
| `template/` | Rojo 7 project copied for each game. `template/CLAUDE.md` = build + Roblox rules for the generator (map from code, server-authoritative, DataStore with pcall, mobile UI, TextService filtering, no external asset IDs, no fake rewards, no off-platform links). |
| `config.example.json` → `config.json` | Accounts: `name`, `apiKeyEnv` (`ROBLOX_API_KEY_1` / `_2`), `style`, `slots` (`universeId`, `placeId`). `config.json` is git-ignored. |
| `setup.bat` | Checks git/claude/rojo, creates `config.json`, commits (author email forced to `ReiElezi@users.noreply.github.com` so his personal email is not published), pushes to the GitHub repo. |
| `install-claude-code.*` | Already used — Claude Code is installed (`%USERPROFILE%\.local\bin`). |
| `set-api-keys.bat` / `.ps1` | Asks for the 2 Roblox API keys with hidden input and stores them as **user environment variables**. Keys never touch files or chat. |
| `schedule-daily.bat` / `unschedule-daily.bat` | Windows Task Scheduler task `RobloxDailyGame` running `run-daily.ps1 -Auto` daily (default 11:17). |
| `rojo.exe` | Rojo 7.4.4 (git-ignored). |

**Anti-spam design (keep it):**
- Never creates new experiences — only updates each account's existing place(s) ("slots").
  The Roblox API cannot create experiences anyway.
- Max **1 publish per account per day** (enforced via `history.json`; `-Force` overrides).
- Account 2 may not use the genre account 1 used today; no genre repeat within 7 days per account;
  titles never repeat; each account has its own `style`.
- Publishing is refused if: title has brackets/ALL CAPS/clickbait words (free, robux, update, x2,
  event, secret, OG…), title/description names a top-10 game, code is too small/placeholder,
  no SpawnLocation/DESIGN.md, TextBox without `FilterStringAsync`, or `loadstring`/`require(id)`.
- Rei must NOT use one account to boost the other (visits/likes), and if one account is
  moderated he must not continue the same thing on the other.

## 3. Current state (as of 2026-11-16 20:55)

- ✅ Project files are in this folder. Local git repo exists (commits `a9c9b26`, `e2852c9` + maybe more).
- ✅ Rojo works (`rojo.exe build` tested OK on the laptop).
- ✅ Claude Code installed. (If you are reading this, login is done.)
- ⚠️ Not yet pushed to GitHub (the chat Claude had no GitHub access).
- ⚠️ Roblox Studio is signed in as **realDavidJames8** (= account 1). A "Publish Experience"
  dialog may still be open with a broken name ("Untitled ExperienceFresh Game Dailyim") —
  nothing was published. Tell Rei to click **Cancel** if he still sees it.
- ❌ No empty experiences ("slots") created yet, no API keys, `config.json` still has zeros.
- ❌ Daily schedule not registered yet.
- The whole pipeline was tested in a Linux sandbox with a fake `claude` and a mock Roblox API
  (2 accounts, anti-spam rejection + fix round, publish, 1-per-day skip): all passed.
  It has **never** run against the real Roblox API or a real `claude -p` game generation yet.

## 4. Your steps (do them in order, confirm each with Rei)

### Step A — Check tools
Run: `git --version`, `claude --version`, `.\rojo.exe --version`. Fix anything missing.

### Step B — Push to GitHub
1. `git status` — make sure `config.json`, `history.json`, `games/`, `logs/`, `rojo.exe` are ignored.
2. Ensure local `user.email` is `ReiElezi@users.noreply.github.com` (rewrite existing commits'
   author if they contain a personal email — the remote is empty, so this is safe).
3. Commit any changes, `git branch -M main`, add remote `origin` =
   `https://github.com/ReiElezi/RobloxGage-today.git` if missing, `git push -u origin main`.
   If GitHub asks to sign in, tell Rei to complete it in the browser. If the remote already has
   commits, merge with `--allow-unrelated-histories` (never force-push without asking Rei).
4. Ask Rei to open the repo page and confirm the files are there.

### Step C — Account 1 slot (realDavidJames8)
Guide Rei (do not do it for him — it is his account):
1. Roblox Studio → **New** → **Baseplate** → **File → Publish to Roblox**.
2. Name: an honest generic name, e.g. **"Fresh Game Daily"**. Description: *"A brand-new original
   game every day. Come back tomorrow for a different one!"* → Create.
3. On https://create.roblox.com/dashboard/creations → the experience → fill the
   **Maturity & Compliance Questionnaire** honestly (the generator makes only mild, non-graphic
   content; if a question doesn't fit, ask Rei — do not guess), then make it **Public**.
4. **Places** → click the place → URL `…/experiences/<universeId>/places/<placeId>/configure`.
   Ask Rei for both numbers and write them into `config.json` (account "Llogaria 1").

### Step D — Account 2 slot
Same as C, but Rei must log out of Studio and log in with his **second** account (he types his
own password). Use a **different** name (e.g. "New Game Every Day") and the second `style`.
Write the IDs into `config.json` (account "Llogaria 2").

### Step E — API keys (Rei does this himself)
For each account, while logged in as that account on create.roblox.com:
Creator Dashboard → **Open Cloud → API Keys** (https://create.roblox.com/dashboard/credentials)
→ Create API Key → Access Permissions: **universe-places** → select that account's experience →
operation **Write** → Accepted IP: `0.0.0.0/0` (or his IP) → Save & Generate → Copy.
Then tell Rei to double-click **`set-api-keys.bat`** and paste each key when asked.
**Never ask Rei to paste a key into this chat, never print it, never write it to a file.**

### Step F — First real test (Rei watches)
Tell Rei to open a **new** PowerShell window in this folder and run:
`.\run-daily.ps1 -Preview -Account "Llogaria 1"`
(it takes 10–30 minutes; it opens the game in Studio and asks "po/jo" before publishing).
Do not run it yourself from inside this session (it nests `claude -p` and exceeds tool timeouts).
If it fails, read `logs\` and `games\<date>\Llogaria-1\claude-log.txt` and fix the cause.
Then the same for "Llogaria 2".

### Step G — Make it automatic
Ask Rei what time of day he wants (laptop must be on and he must be logged into Windows).
Edit `set ORA=` in `schedule-daily.bat` if needed, then run it. Verify with
`schtasks /Query /TN RobloxDailyGame`. Commit + push the change.

### Step H — Wrap up (in Albanian)
Tell Rei: what is done, the two game links (`https://www.roblox.com/games/<placeId>`),
that titles/descriptions/icons on the Creator Dashboard don't change automatically
(the script prints suggested text each day), and the 2 rules he must follow himself
(no cross-boosting; stop if an account gets moderated).

## 5. Rules for you
- Do not weaken the anti-spam checks or the 1-per-day limit without Rei explicitly asking.
- Never commit or print secrets (`config.json` is fine to edit but stays git-ignored; API keys only in env vars).
- Never publish to Roblox yourself without Rei saying "po" for that specific publish.
- Keep `README.md` (Albanian) in sync with any change you make.
