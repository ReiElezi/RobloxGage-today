# Daily Roblox game — build rules

This folder is a **Rojo 7** project. Everything you build must live in `src/` as Luau files.
There is NO Roblox Studio open: the whole game (map included) must be created from code.
The script that called you will publish `game.rbxlx` live to Roblox, so real players will join it.

## File layout (Rojo naming)
- `src/server/*.server.luau` → Script in ServerScriptService
- `src/client/*.client.luau` → LocalScript in StarterPlayerScripts
- `src/shared/*.luau` → ModuleScript in ReplicatedStorage.Shared
- Any `*.luau` without `.server`/`.client` is a ModuleScript.
- Split code into several modules (MapBuilder, GameLoop, Data, UI...) — no 2000-line files.

## Hard requirements
1. **Map from code.** A server script builds the whole map with Parts/WedgeParts/Models,
   built-in Materials, Colors, Lighting, Atmosphere and Sky properties. Create a `SpawnLocation`
   FIRST, before anything slow, so players never spawn into the void.
2. **No external asset IDs** (meshes, decals, sounds, animations) unless you have verified
   in this session that the ID exists and is public. Prefer primitives + materials + particles.
3. **Server-authoritative.** Currency, progress, purchases and rewards are decided on the server.
   Clients only send requests through RemoteEvents/RemoteFunctions created by the server,
   and the server validates every request (distance checks, cooldowns, types).
4. **leaderstats** for the main currency/progress so it shows on the player list.
5. **DataStore saving** with `pcall` around every call, save on PlayerRemoving and `game:BindToClose`.
   DataStore must fail gracefully (game still playable if it errors).
6. **UI from code** (ScreenGui built in a LocalScript): title, currency, objective/hint,
   and any shop/buttons. Use Scale sizing + UIAspectRatioConstraint/UIScale so it works on phones.
   Every button must also be big enough to tap on mobile.
7. **Core loop playable in 30 seconds**: a new player immediately understands what to do
   (on-screen hint + visual cues like arrows, glowing parts, BillboardGui labels).
8. **Progression**: at least 3 tiers/stages/upgrades so there is a reason to keep playing.
9. **Original content only**: no names, characters, logos or text copied from existing games.
   Being *inspired* by a genre is fine; cloning a specific game is not.
10. **Performance**: keep total parts under ~3000, anchor all static parts,
    no `while true do` without `task.wait`, use `task.spawn/task.delay` (not `spawn/delay/wait`).
11. Use only current APIs (no deprecated `Instance.new(class, parent)` in hot loops, no `wait()`).

## Before you finish
- Run `rojo build default.project.json -o game.rbxlx` and fix every error.
- Re-read every script for: nil indexing, misspelled service/property names, RemoteEvents used
  before they exist (use `WaitForChild` on the client), infinite yields, missing `task.wait`.
- Write `game.json` (see the prompt for the exact format).

## Roblox rules (the game is checked automatically before publishing)
12. **Text filtering**: any text a player types that other players can see (names, signs,
    outfit names, chat-like boards) MUST go through `TextService:FilterStringAsync` on the server
    and be shown with `GetNonChatStringForBroadcastAsync`. Roblox removes games that skip this.
13. **No cross-promotion or off-platform links**: do not advertise other games, groups or websites,
    and never ask players to leave Roblox.
14. **No fake rewards**: never show "free Robux", fake prizes, games of chance with Robux,
    or buttons that pretend to give something they don't.
15. Do not use `loadstring`, `getfenv/setfenv`, or `require(<assetId>)`.
16. **English only.** Every player-visible text (UI labels, buttons, hints, BillboardGui text,
    signs, notifications, title, description) must be in English. No other languages anywhere
    in the game, including code comments.
