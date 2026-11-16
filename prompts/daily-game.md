Today is {{DATE}}. You are creating TODAY'S new Roblox game in the current folder.
Read CLAUDE.md in this folder first and follow every rule in it.

This account's visual/creative style: {{STYLE}}

LANGUAGE: The game is for an international audience. ALL player-visible text
(title, description, UI, hints, signs, notifications) MUST be in English only.

## Step 1 — What earns the most on Roblox today
Use WebSearch and WebFetch to find the CURRENT top 10 top-earning (top-grossing) Roblox experiences.
Good sources: https://rotrends.com/experiences/TopEarning , https://www.roblox.com/charts ,
and news articles from the last 30 days. For each of the 10, write down its genre
(e.g. obby, tycoon, simulator, collect-and-steal "brainrot", fashion/dress-up show, horror survival,
fighting/PvP, tower defense, roleplay, farming/garden, fishing, idle/clicker...).

## Step 2 — Pick today's genre
Pick ONE genre from that top-10 list.
Do NOT use any of these genres (used recently by this account, or already used today by another account): {{AVOID_GENRES}}
If every top-10 genre is excluded, pick a related genre that is not excluded.
Prefer a genre whose core loop can be built well, from code only, in one session.

## Step 3 — Design an original game
Invent an original title, theme and twist. The title must be different from all of these previous titles: {{PREVIOUS_TITLES}}
Write a short design (core loop, 3+ progression tiers, what the UI shows) into DESIGN.md before coding.
Never use names, characters, logos or text from existing games (including the top-10 ones).

## Step 4 — Build it
Implement the game in src/ exactly as CLAUDE.md requires. Replace ALL placeholder files.

## Step 5 — Verify
Run: rojo build default.project.json -o game.rbxlx
Fix all errors and repeat until it builds. Then re-read all your scripts once more for runtime bugs.

## Step 6 — game.json (honest metadata — Roblox bans misleading titles/descriptions)
Write game.json in this exact format (valid JSON, UTF-8):
{
  "title": "Game title (max 50 chars)",
  "genre": "the genre you picked, lowercase, e.g. obby",
  "inspiredByTopEarners": ["names of the top-10 games that are in this genre"],
  "description": "Roblox experience description for players, 2-4 sentences, English",
  "descriptionAlbanian": "Same description in Albanian",
  "howToPlay": "1-2 sentences"
}
Metadata rules:
- Title and description describe ONLY what is really in the game.
- No brackets or tags in the title ([UPDATE], [x2], [EVENT]...), no ALL CAPS title.
- No words like: free robux, giveaway, admin, update, event, limited, secret, OG, x2.
- Never mention other games' names in the title or description.
- Title, description and howToPlay are in English (only descriptionAlbanian is in Albanian).

## Step 7 — Game icon and cover picture (required)
Roblox shows a picture for every game. Draw them yourself as self-contained HTML files (inline CSS and inline SVG only,
no external URLs, no images, no web fonts, no scripts needed):
- `art/icon.html` — exactly 512x512 px (`html,body{margin:0;width:512px;height:512px;overflow:hidden}`): square game icon.
- `art/cover.html` — exactly 1920x1080 px (same CSS with 1920/1080): wide cover/thumbnail for the game page.
They must look like professional Roblox game art for THIS game: bold bright colors, the game title in big, thick,
readable English letters with outline/shadow (title on the cover; title or a short word on the icon), and a clear
illustration of the core idea drawn with SVG shapes (e.g. obby platforms in the sky, a runway, towers, a farm...).
Fill the whole canvas (no white borders). Rules: no Roblox logo, no real people, no characters/logos from other games,
no text promising rewards (no "FREE", "ROBUX", "x2", "UPDATE"), nothing scary or violent.

Do not try to publish anything yourself. When done, print a 3-line summary: title, genre, core loop.
