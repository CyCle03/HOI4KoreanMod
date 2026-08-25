# Chosŏn — How to Become a Nation

*English · [한국어](README.ko.md)*

Three design documents — `docs/korea-focus-tree.html`, `docs/korea-research-tree.html`,
`docs/korea-mod-spec.html` — carried over into a mod for Hearts of Iron IV 1.19.2
(Operation Postern). Open them in a browser: all 107 focus-tree nodes, the equipment
naming tables and the tag design are in there, and every place the implementation
parts ways with the design is written down under "Where this differs from the design"
below. The documents are in Korean.

## Installing

Point `Documents/Paradox Interactive/Hearts of Iron IV/mod/korea_chosen_mod.mod` at the
repository's `KoreaMod/` folder and enable it in the launcher's Mods tab. `KoreaMod.zip`
is that same folder zipped up, for installing without cloning the repository — if you
change the source, the zip has to be rebuilt too.

## What is in it

| | Design | Implemented |
|---|---|---|
| Focuses | 107 (1 hidden) | **105 focuses + 2 events** — two of the design's 107 nodes were events, not focuses |
| National spirits | 7 | 66 (7 at start + 59 from focuses and decisions) |
| Cosmetic tags | 5 | 11 — 6 for naming (`KOR_jap` `KOR_chi` `KOR_usa` `KOR_csr` `KOR_sov` `KOR_ger`) + 5 for the country name (`KOR_peoples_republic` `KOR_dominion` `KOR_empire` `KOR_dominion_ger` `KOR_empire_ger`) |
| Equipment names | 76 rows × 5 branches | **678 entries** — the research document's 326 plus copies for the 5 country-name tags |
| MIOs | 8 | 8 |
| Characters | 14 | 8 reused from the base game + 6 new |
| Decisions | 7 (requisition, bandits, endgame) | 15 |
| Localisation | Korean, English | both |
| Flags | — | 17 — 14 copied from the base game, 3 drawn (see [Flags](#flags)) |

Focus durations fall out of `cost` exactly as the design specifies (35 days = 5,
70 = 10, 105 = 15, 140 = 20).

There are 12 events: six called from focuses and decisions, and six that simply happen
to the peninsula — the supply-base turn of July 1937, Sup'ung going live in October 1941,
the declaration of war on Japan in December 1941, the Korean Language Society arrests of
October 1942, conscription in April 1944, and the collapse of the autonomous assembly on
the day Japan surrenders. That last one is the collapse `CHO_autonomous_assembly` promises
in red text. The dated ones are collected in the `KOR_wartime_events` scripted effect and
called from both the KOR and CHO daily on_actions.

## Where the design's key mechanisms live

- **The "five of nine" gate** — `KOR_ind_regional_specialization`. The nine tier-1
  focuses have no prerequisites between them; the count of completed ones is kept in
  the `KOR_ind_tier1` variable and surfaced through `custom_trigger_tooltip`. The final
  gate, `KOR_ind_korea_in_world`, wants `KOR_ind_total > 8` across tiers 1 and 2.
- **Clawing back the leak rate** — the `KOR_supply_base_leak` dynamic modifier reads the
  `KOR_leak` variable daily. Every industry focus calls `KOR_recover_leakage` for 5
  percentage points, with a floor of 20% (10% once "Korea in the World" is done).
- **What splits the army tree** — not ideology but the `KOR_has_government_apparatus`
  scripted trigger. The regular and guerrilla branches divide on `allow_branch` and
  rejoin at the military academy.
- **Opening the five political branches** — the four branch heads are visible §in grey§
  from January 1936, and the flag-defacement incident of 25 August decides which one
  unlocks. `available` + `custom_trigger_tooltip` is used instead of `allow_branch`
  because hiding them would hide the very fact that the tree forks at all for the first
  eight months. The only genuinely hidden branch is the Keijō plan.
- **The hidden branch** — `allow_branch` on `KOR_infiltrate_hq` demands both the
  `KOR_uiyeoldan_done` and `KOR_hq_accord_signed` flags. Until then it is not drawn.
- **The left/right scale** — the `KOR_scale_right` / `KOR_scale_left` variables and their
  decisions. It does not use the BBA power-balance UI, so there is no DLC dependency.
- **The recognition gauge** — `KOR_recognition`, capped at 60 by default.
  `KOR_lift_recognition_cap` is only called after a successful landing at home following
  Operation Eagle.
- **Three difficulties / start modes** — `KoreaMod/common/game_rules/KOR_game_rules.txt`.

## How the gauges press on the game

A number the player can move is not a system unless something reads it while the game
is running. The leak rate was built that way from the start — the `KOR_supply_base_leak`
dynamic modifier reads `KOR_leak` every day — and the other two were not. Recognition
and the left-right scale were read when a decision window opened and at no other time.
All three now work the same way.

| Gauge | Read daily by | Effect |
|---|---|---|
| `KOR_leak` | `KOR_supply_base_leak` | factory and dockyard output |
| `KOR_recognition` | `KOR_allied_standing` | political power and war support (nothing at 0, +15% political power at the default cap of 60) |
| `KOR_scale_right` | `KOR_united_front_strain` | the further from 50, the lower the stability and the higher the zeal of the half that remains |

The derived variables are computed once a day by `KOR_refresh_gauges`, called from both
the KOR and CHO daily on_actions. Recognition's natural decay moved in there too, so both
tags follow the same rule, and `KOR_scale_left` — written in five places and read in none —
is refreshed there as well.

**Ideology accumulates as pressure.** Starting popularity is not 100/0/0/0 but 90
non-aligned, 5 democratic, 5 communist. `KOR_divided_movement` pushes 0.02 a day into each
of those two, and `KOR_governorate_police` pushes exactly their sum (0.04) back into
non-aligned. While the police state holds, the peninsula stands still; from the day
`KOR_restore_sovereignty` removes it, it starts moving. That is what turns the political
tree's fork from a switch into a pressure that builds.

**The supply base is attached from 1 January 1936.** It used to arrive with the
`KOR_logistics_base` focus, which meant `KOR_setup_leakage` spent the intervening years
computing a leak rate nothing read, and the industry focuses spent their 5-point recoveries
on a modifier that was not attached yet. It moved to startup, and the focus now goes
through `KOR_ensure_supply_base` so nothing is granted twice.

## Where this differs from the design

1. **The Japanese surrender-gauge problem is already gone.** In 1.19 the base game's
   `history/states/525` and `527` are `owner = JAP` with `add_core_of = KOR` and are
   **not Japanese cores.** The design's biggest worry in §Tag design was something the
   game had already solved.
2. **The peninsula is six states** — 525 Gyeonggi, 527 Pyongan-Hwanghae, 1028 Hamgyong,
   1029 Gangwon, 1030 Gyeongsang, 1031 Chungcheong-Jeolla. All six are `owner = JAP`
   with `add_core_of = KOR`, and none is a Japanese core. This is the part the design
   said to "check against the installed version". Anything that works per state was
   matched to the real geography — Hungnam, Musan and Aoji are in Hamgyong (1028);
   Sup'ung and Kyŏmipo in Pyongan-Hwanghae (527); Chosen Heavy Industries in Gyeongsang
   (1030), which holds Busan; Kyŏngsŏng Spinning and the Gyeongin industrial belt in
   Gyeonggi (525); the cotton of "cotton in the south, sheep in the north" in
   Chungcheong-Jeolla (1031). Anything that has to mean the whole peninsula is written
   as `is_core_of = KOR` — the two scripted effects `KOR_seize_the_peninsula` and
   `KOR_return_peninsula_to_japan` collect those so the state numbers are not written
   out twice.
3. **The CHO tag is switched on and off by game rule.** The default is `GOVERNORATE` —
   two of the peninsula's states go to CHO as an integrated puppet of Japan, and you can
   click Korea on the start screen and play it. That was the design's original intent and
   the central decision of §Tag design. Ownership itself is declared in
   `KoreaMod/history/states/525` and `527`, not in on_startup: the country selection
   screen reads history files and nothing else, so moving the states in on_startup left
   the peninsula Japanese while you were choosing, broke it away the instant the game
   began, and made CHO unselectable. What stays in startup is the diplomacy, which has
   no map to redraw.
   The flip side is that Japan's AI — what the design called `the biggest risk` — is on
   this path. Switching to `LIBERATION` leaves the 1936 map completely untouched and
   Korea stays a releasable nation (no effect on Japan's AI, but you cannot pick it at
   start).

   **There is still no tag switch.** The design said choosing resistance swaps CHO→KOR;
   for now only the cosmetic tag changes. The design never settled what a KOR in exile
   would own, and in HOI4 a country with no territory capitulates immediately.
4. **Equipment naming keys are a prefix, not a suffix.** The design's example was
   `infantry_equipment_1_KOR_usa`; the real format is `KOR_usa_infantry_equipment_1`
   (confirmed against the base game's `GER_infantry_equipment_1`). Implemented as a prefix.

   **A country has exactly one cosmetic tag slot.** A tag that renames the country and a
   tag that names the equipment therefore cannot coexist — whichever runs last erases the
   other. In the two places where the design calls for a rename — the People's Republic
   and the restored Yi state — the country-name tag carries the equipment list itself.
   `KOR_peoples_republic` is a copy of `KOR_jap` (captured Japanese arms), and the Yi
   state has one tag for each side of the German military mission: `KOR_dominion` and
   `KOR_empire` hold the Japanese arsenal, `KOR_dominion_ger` and `KOR_empire_ger` the
   German one. `KOR_name_equipment_german` reads the `YIH_yi_un_chosen` and
   `YIH_empire_proclaimed` flags and swaps only the arsenal, leaving the name alone.
5. **The division-template limit needed no workaround.** 1.19 has the
   `set_division_template_cap` effect and it is used as is (3 at start → 8 at the
   Sinheung Military Academy → unlocked at the officers' academy, 12 for the People's
   Republic). The "Korea Army HQ veto" is still done the way the design asked, as
   penalties severe enough that nobody tries — there is still no modifier that forbids
   raising divisions outright.
6. **There is no `economy_minister` slot in this version.** Pak Hŭng-sik is a political
   advisor with the `captain_of_industry` trait.
7. **The ship rows of the naming table were left out.** Transport, destroyer and submarine
   names come from the ship name lists (`common/units/names_ships`), not from equipment
   localisation.
8. **Only the hulls were carried over from the tank rows.** In rows like "Ha-Go · Ke-Nu ·
   Ko-Hi", the SPG, tank-destroyer and AA variants are omitted.

## Flags

CHO and the eleven cosmetic tags each need their own flag file — the game looks up
`gfx/flags/<tag>.tga` and draws a blank where the country's identity should be when it is
not there. Seventeen names, three sizes each (82×52, 41×26, 10×7): fifty-one files.

Fourteen of the seventeen needed no new art. The base game already ships the
Government-General's flag (`KOR_chousen_tag_*`, from Graveyard of Empires) and Korea's four
ideology flags, so those are copied under the names this mod's tags expect.

| Flag | What it is | Art |
|---|---|---|
| `CHO` (+ four ideology variants), `KOR_gg`, `KOR_jap` | Government-General of Chosen, and Korea before it has a name of its own | base game, `KOR_chousen_tag_*` |
| `KOR_dominion`, `KOR_dominion_ger` | Chosen Dominion | base game, `KOR_chousen_tag_fascism` — the gold-bordered palgwae, the empire's own subordinate |
| `KOR_ger`, `KOR_empire`, `KOR_empire_ger` | Great Korean Empire | base game, `KOR_fascism` — the eight-trigram taegukgi of the imperial period |
| `KOR_chi`, `KOR_usa` | Korean Provisional Government | base game, `KOR_democratic` — the taegukgi |
| `KOR_csr`, `KOR_sov` | Korean Independence League | **drawn**, `tools/make-league-flag.ps1` |
| `KOR_peoples_republic` | People's Republic of Korea | **drawn**, `tools/make-prk-flag.ps1` |

Two designs are new, and for the same reason: the only communist Korean flag the base game
has is the DPRK's, which is 1948 and the wrong organisation for either of these.

**The Korean Independence League** (조선독립동맹, Yan'an, 1942) was communist in alignment
and nationalist in symbol — the Korean Volunteer Army it fielded is photographed under the
taegeuk. So the flag keeps the taegeuk, on a white disc, and sets a gold star beside it
rather than over it. The field is deeper than the DPRK's scarlet so the two do not read as
one flag at 41×26, and the white ring is wide on purpose: the taegeuk's red and the field's
red are both red, and a thin ring closes up at 10×7 and turns the whole thing into a blob.

**The People's Republic of Korea** (조선인민공화국, Seoul, September 1945) actually flew the
taegukgi, so this is the taegukgi. The one change is the upper hoist: geon (☰), the trigram
for heaven and the sovereign, is the corner the star takes — the first corner the eye
reaches, and the one whose meaning the change is about. Ri, gam and gon keep theirs. The
star is a shade deeper than the taegeuk's red so it is not read as part of it.

Both are drawn at eight times size and filtered down; the taegeuk's S does not survive being
drawn at 82×52 directly. Both scripts are deterministic — re-running one reproduces the
committed files byte for byte:

```bash
pwsh tools/make-league-flag.ps1 KoreaMod/gfx/flags
```

That is why they are kept. A `.tga` is binary: without the script, the colours, the width of
the white ring and the star's position are unreachable.

The fourteen copied flags are Paradox's own art, redistributed inside the mod folder. That
is ordinary for Hearts of Iron IV mods, but it is worth knowing that is what those files are.

**The thumbnail** (`KoreaMod/thumbnail.png`, 512×512, pointed at by `picture=` in
`descriptor.mod`) is drawn by `tools/make-thumbnail.ps1` out of the same taegeuk and the
same palette, so the launcher entry and the flags are one thing rather than two. The emblem
takes the upper two thirds and the title the lower third; the title block is flowed from the
measured height of each line rather than fixed offsets, because the font's leading is
generous and guessing at it put the first version's title straight through the bottom
trigrams. The rule under the title is 5px for a reason — at 3px it vanished by the time the
launcher had scaled the image down to list size.

If you install by pointing a `.mod` file in `Documents/Paradox Interactive/Hearts of Iron IV/mod/`
at this repository, that file needs its own `picture="thumbnail.png"` line for the launcher
to show it. `descriptor.mod` covers the zip and the Workshop copy, not the local pointer.

## What has been checked, and what has not

Static validation is done — brace balance, 106 focus prerequisite/exclusivity/relative-position
references, national spirit references, scripted effect and trigger calls, GFX icon names,
modifier names (cross-checked against base game usage), and every localisation key in both
languages. No unresolved references remain.

**The game has never actually been launched.** The things that only show up at runtime —
whether the focus tree layout overlaps, whether the AI takes the branches properly, whether
`GOVERNORATE` mode wrecks Japan's conduct of the Second Sino-Japanese War — have to be seen
firsthand. That is exactly what the design meant by asking for ten observer-mode runs.

A suggested first pass:

```bash
"C:/Program Files (x86)/Steam/steamapps/common/Hearts of Iron IV/hoi4.exe" -debug
```

With `-debug`, script errors pile up in
`Documents/Paradox Interactive/Hearts of Iron IV/logs/error.log`. Switch with `tag KOR`
in the console and look at the tree first.

## Layout

```
├─ KoreaMod/            the mod itself (the folder the launcher reads)
│  ├─ common/
│  │  ├─ national_focus/   KOR_political(60) · KOR_industry(15) · KOR_military(19) · KOR_late(11)
│  │  ├─ ideas/            KOR_ideas · KOR_focus_ideas · KOR_event_ideas
│  │  ├─ decisions/        requisition · bandits · endgame · balance + categories
│  │  ├─ scripted_triggers/ · scripted_effects/
│  │  ├─ characters/ · country_leader/ · opinion_modifiers/
│  │  ├─ dynamic_modifiers/ · game_rules/ · on_actions/
│  │  ├─ country_tags/ · countries/ · units/names_divisions/
│  │  └─ military_industrial_organization/organizations/
│  ├─ events/              KOR_timeline · KOR_politics · KOR_industry
│  ├─ gfx/flags/           17 flags, each at 82×52 · medium/ 41×26 · small/ 10×7
│  ├─ history/             countries/CHO · states/ (the six peninsula states) · units/KOR_1936 · units/CHO_1936
│  ├─ localisation/        korean/ · english/  (3 files each)
│  └─ thumbnail.png        512×512, what descriptor.mod's picture= points at
├─ docs/                the three design documents (the game does not read these)
├─ tools/               the flag and thumbnail renderers (not read by the game either)
├─ KoreaMod.zip         KoreaMod/ zipped up for distribution
├─ README.md            English (this file)
└─ README.ko.md         Korean
```

Only the political branch sits inside a `focus_tree` block; industry, military and late
are `shared_focus`. That is the same reason the design split the files five ways, and a
single tree (`korea_focus`) is shared by the KOR and CHO tags.
