# walker-3d-decals — Game Design Document (recovered)

| | |
|---|---|
| Version | 0.1.0-recovered |
| Date | 2026-09-27 |
| Author | Zelda (agent, silent), for Nik Bear Brown |
| Mode | recovered — `/gdd reverse --path godot silent` |
| Revision | 1 |
| Gates | vision ○ · systems ○ · world ○ · scope ○ — gate — unsigned at time of writing |
| Project kind | **tech demo** (decal specimen gallery with one interactive placement), not a game |

Provenance tags: `[OBSERVED path:line]` the code or scene does this · `[INFERRED]` the code strongly implies this, evidence stated · `[MISSING]` the code cannot tell you this; logged in `decisions.md`. Paths are relative to `godot/` unless they name a folder-root file. This document describes what exists. It approves none of it.

**Evidence image:** `godot/screenshots/decals.png` — upstream screenshot shipped with the source; embedded in `design/DECK.html`.
*`[OBSERVED godot/screenshots/decals.png]` — the screenshot shipped with the upstream Godot demo. Not a Walker capture: "Forward+ GPU appearance … remain[s] unverified" (`README.md`).*

## 1. Vision summary

**What it is.** Ten decal specimens in a row — bullet/plasma stains, paint and arrows, a water puddle with reflection probe, a blob shadow, sci-fi panel decals, a buff effect, normal-map / ORM decals, distance fade, and decals on animated and transparent meshes — plus a filter-mode picker and one interactive verb: press P to stamp a decal where the cursor ray hits. `[OBSERVED test.tscn:240-686, 739-771; tester.gd:31-43]`

**Upstream purpose.** "Many examples of Decal nodes in action, for the purpose of showcasing Godot's rendering capabilities." `[OBSERVED godot/README.md:3-4]`

**Why it is in Walker.** An independent title-only adaptation of Godot `3d/decals` at commit a3b5c113; both native-4K Liam films pending. `[OBSERVED README.md]` The films' subject, audience and angle are `[MISSING]` (Q-01).

**Player fantasy / logline.** None. P-to-stamp is the only verb, and it has no goal, fail state or score. `[OBSERVED tester.gd]` The P key is the seed of a game mechanic (bullet holes, paint), but nothing here says Walker wants that. `[INFERRED]`

**Biggest unresolved question.** Is the film about *what decals can look like* (the gallery) or *how a game places them* (the P-key ray)? Different captures. Q-01, Q-03.

## 2. Design pillars

None stated. `[MISSING]` (Q-02). Implied `[INFERRED]`:
1. **Decals as the surface layer of a game world.** The specimen names are game uses — BulletPlasmaDecals, CircleBlobShadow, BuffEffect, WaterPuddle — not texture-channel names. Evidence: `test.tscn:242-578`.
2. **Every texture channel shown once.** Albedo, normal, ORM, emission each get a specimen. Evidence: `test.tscn:229-237, 609-626`.

## 3. Core loop

No game loop. Recovered **viewing loop** (`diagrams/viewing-loop.svg`):
1. Select a specimen — `ui_left` / `ui_right` or « Previous / Next ». `[OBSERVED tester.gd:25-29, 71-84; test.tscn:769-770]`
2. Camera slides on Z (rate `3 * delta`); orbit with a held mouse button; wheel zooms 1.5–4. `[OBSERVED tester.gd:45-68]`
3. Optionally change the decal filter mode. `[OBSERVED tester.gd:87-89; test.tscn:752-771]`
4. Optionally press P: ray from camera through cursor, 100 units; on hit, spawn `decal.tscn` at the hit point, facing the camera. `[OBSERVED tester.gd:31-43]`
5. The stamped decal grows over 0.2 s, fades over 5 s, and frees itself. `[OBSERVED decal.tscn:32-72, 87-89]`

## 4. Player Experience Goals

None stated. `[MISSING]` (Q-01). Not writing any; "sees a puddle" is a feature, not an experience. Candidate learning outcome, unconfirmed `[INFERRED from godot/README.md:6-16]`: the viewer can say when to pick Nearest vs Linear, and why anisotropic filtering matters at oblique angles.

## 5. Mechanics

### M-01 Specimen stepping `[OBSERVED tester.gd:71-84]`
Index clamped 0..9; label and boundary buttons update. All ten indices and both clamps pass under routed key events. `[OBSERVED ray-input-20260924.log]`

### M-02 Orbit and zoom `[OBSERVED tester.gd:4-11, 45-59, 68]`
`ROT_SPEED 0.003`; pitch clamped [−90°, 0]; initial pitch −22.5°, yaw 90°; `ZOOM_SPEED 0.125`, zoom starts 1.5, clamped [1.5, 4]. Tuning values. Wheel tests send pressed events only. `[OBSERVED FRICTIONAL.md 06:44 UTC]`

### M-03 Decal filter mode `[OBSERVED tester.gd:87-89; test.tscn:752-766]`
Six options passed straight to `RenderingServer.decals_set_filter(index)`. The OptionButton starts at `selected = 4` (Nearest + Mipmaps + 16× Anisotropic) `[OBSERVED test.tscn:754]` while the project setting is `textures/decals/filter=5` (Linear + Mipmaps + Anisotropic) `[OBSERVED project.godot:40]`. `[INFERRED]` At startup the picker shows one mode while the renderer uses another, until the viewer changes it. Unverified on screen (Q-05).

### M-04 Place decal (P) `[OBSERVED tester.gd:31-43; project.godot:30-34]`
Action `place_decal`, physical key 80 (P). Ray length 100. On hit: instance `decal.tscn`, set child `Decal.modulate = Color(1, 0, 0)`, position at hit, basis = camera basis. Verified: a routed P press after real pointer motion hits the floor `StaticBody3d` at y = 0 and adds one holder. `[OBSERVED ray-input-20260924.log]` Holder creation is not visible projection. `[OBSERVED FRICTIONAL.md]`

`[INFERRED]` The red tint set at `tester.gd:41` is probably overwritten on the next frame: the autoplaying `fade` animation keys `Decal:modulate` from white to transparent white (`decal.tscn:49-60`). If so, placed decals render untinted. Not observed on screen (Q-04).

### M-05 Stamped-decal lifetime `[OBSERVED decal.tscn:32-72]`
`fade` (5.0 s, autoplay): `Decal:extents` 0 → 1 over 0.2 s; modulate alpha 1 → 0 over 5 s; `queue_free` at 5 s. The track targets `extents` while the node sets `size`; on 4.7.2 the track does drive size, reaching (2, 2, 2). `[OBSERVED FRICTIONAL.md 06:14 UTC; state-20260924.log]` Future engine compatibility is not established.

## 6. Systems

### S-01 Specimen row `[OBSERVED test.tscn:240-686]`
| # | Node | What it shows | Line |
|---|---|---|---|
| 0 | BulletPlasmaDecals | 4 plasma stains on a mesh | 242 |
| 1 | PaintDecals | 3 paint + 4 arrow decals, albedo + normal | 270 |
| 2 | WaterPuddle | albedo + ORM decal with ReflectionProbe | 320 |
| 3 | CircleBlobShadow | gradient-texture blob shadow | 332 |
| 4 | ScifiDecals | 12 pivots × 2 sci-fi panel decals | 342 |
| 5 | BuffEffect | gradient + emissive noise decal + OmniLight | 578 |
| 6 | NormalMapDecals | AlbedoAndNormal, NormalOnly, Metallic | 606 |
| 7 | DistanceFade | FadeInstant, FadeShort, FadeLong | 628 |
| 8 | DecalOnAnimatedMesh | decal on a CSGPolygon3D | 657 |
| 9 | DecalOnTransparentMesh | decal on a transparent CSGPolygon3D | 672 |

Two root-level decals outside the row, `PlasmaEmission` and `PlasmaStain`, plus an autoplaying `move` AnimationPlayer. `[OBSERVED test.tscn:196-198, 229-238]`

### S-02 Physics for the ray `[OBSERVED test.tscn:200-210, 573, 601]`
Floor `StaticBody3d` + collision shape; extra static bodies under ScifiDecals and BuffEffect. No collision layers configured beyond defaults. `[OBSERVED project.godot — no layer names]`

### S-03 Input map `[OBSERVED project.godot:28-34]`
One custom action: `place_decal` (P). Built-ins `ui_left`, `ui_right`; raw mouse.

### S-04 Signals
Three editor connections (Previous, Next, filter OptionButton). No custom signals, no `@export` vars. `[OBSERVED test.tscn:769-771; tester.gd]`

## 7. Progression
None. `[OBSERVED]` Specimen order runs from game-use decals to rendering edge cases `[INFERRED from S-01]`; intended teaching order `[MISSING]` (Q-03).

## 8. World
A lab floor with checker texture, a shadowed sun, and the specimens. `[OBSERVED test.tscn:200-228]` No setting.

## 9. Narrative
None, correctly. `[OBSERVED]`

## 10. Characters
None. `[OBSERVED]`

## 11. Features and priority

| ID | Feature | Exists | Verified how | Priority |
|---|---|---|---|---|
| F-01 | Specimen stepping | yes | 10 indices + 2 clamps, routed keys | [MISSING] |
| F-02 | Orbit + zoom | yes | drag yaw −0.15 rad / 50 px; zoom bounds (press events) | [MISSING] |
| F-03 | Filter mode picker | yes | all 6 options selected by keyboard popup nav, signals fire; **pixels unverified** | [MISSING] |
| F-04 | P-key placement | yes | real ray hit + one holder created; **projection unverified** | [MISSING] |
| F-05 | Stamped-decal grow / fade / free | yes | separate fixture: size (2,2,2) at 0.3 s, fade, freed at 5 s | [MISSING] |
| F-06 | 10 specimen decals render correctly | unknown | headless only | [MISSING] |
| F-07 | Forward+ capture | **no** (proposed) | — | [MISSING] |
| F-08 | Two native-4K Liam films | **no** (proposed) | — | [MISSING] |

CORE percentage: undetermined; nothing tagged CORE (Q-06).

## 12. Out of scope
Observed absences: shooting, projectile physics, persistence of placed decals, audio, score. `[OBSERVED]` Licence review before distribution is required by the README, not yet done. `[OBSERVED README.md]` (Q-07)

## 13. Technical
- Godot 4.7 feature tag `[OBSERVED project.godot:16]`; 4.7.2.stable in all logs.
- Renderer unset → Forward+ default; upstream README says Forward+. `[INFERRED]`
- Decal filter 5, anisotropic 4, soft shadow quality 3. `[OBSERVED project.godot:38-40]`
- Scripts: `tester.gd` (89 lines, `extends WorldEnvironment`), `test_state.gd` (Walker probe).
- Textures: 21 PNGs under `textures/` with four licence files — checker CC0; paint CC-BY 3.0; painted arrow CC-BY-SA 3.0; sci-fi set CC0 (authors and URLs in each `*.LICENSE.md`). `[OBSERVED README.md; godot/textures/*.LICENSE.md]` Maturity L4 upstream. `[INFERRED]`
- Logs: import, runtime (clean), state (16/16), interactions (1 fail: empty ray), ray-diagnostic (pointer (0,0) → empty hit), ray-input (25/25, 0 failures).

## 14. Risks

| ID | Risk | L / I | Evidence |
|---|---|---|---|
| R-01 | Share-alike / attribution obligations missed on a published film | M / H | CC-BY 3.0 and CC-BY-SA 3.0 textures; README asks for review |
| R-02 | Filter picker shows one mode, renderer uses another at startup; a film narrates the wrong one | M / M | `test.tscn:754` vs `project.godot:40` |
| R-03 | Stamped decal expected red, renders white | M / L | M-04 inference |
| R-04 | `extents` track breaks on a future engine | L / M | works on 4.7.2 only |
| R-05 | Recording blocker holds both films | H / H | README, FRICTIONAL.md |

**Top 3.** R-05 blocks visible work; R-01 is the one with legal weight; R-02 is the one a narrator will trip on.

## 15. Open questions
In `decisions.md`: Q-01 film purpose and audience; Q-02 pillars; Q-03 gallery vs placement focus and order; Q-04 intended stamp tint; Q-05 startup filter mismatch; Q-06 CORE; Q-07 licence review before distribution.

## 16. Tests

Existing `[OBSERVED godot/test_state.gd; ray-input-20260924.log]`: T-01 navigation 0-9; T-02 both clamps; T-03 drag rotates camera; T-04 zoom limits (pressed events); T-05 filter selection 0-5 via keyboard popup; T-06 P-key ray places decal; T-07 decal growth affects size; T-08 fade; T-09 expiry at 5 s. 25 checks, 0 failures.

Proposed (dashed):
| ID | Setup | Action | Expected | Links |
|---|---|---|---|---|
| T-10 | Forward+, fresh start | read OptionButton and `RenderingServer` filter | agree, or mismatch documented | M-03, Q-05 |
| T-11 | Forward+ | place decal with P | visible projection at cursor; record tint | M-04, Q-04 |
| T-12 | DistanceFade | dolly out | three fade distances visibly differ | F-06 |
| T-13 | each filter mode at oblique angle | capture | Nearest grainy, Anisotropic sharp at distance | F-03 |

## Zelda's notes (silent mode; what I would have said out loud)

7 Failure Mode read:
1. **Ghost Center — PRESENT, expected.** A sample, not a vision.
2. **Mechanic Mirage — ABSENT by refusal.**
3. **Implementation Void — PARTIAL.** Better than most in this batch — the P-key path was chased until a real ray hit — but every claim stops at "a node was created."
4. **Priority Inflation — cannot assess.**
5. **Novelist's Trap — ABSENT.** Specimen names like "BuffEffect" are hints, not lore; I have not expanded them.
6. **Completeness Fallacy — PRESENT.** Seven open questions; two (Q-04, Q-05) are small code-level surprises that nobody has looked at on screen.
7. **Stagnant Artifact — ABSENT.**

What the structure suggests `[INFERRED]`: this is the one demo in the batch with a game verb. The gallery shows what decals look like; P shows how a game spawns them. If Walker's films are for game makers, the P key is the film.

**First fix:** answer Q-07 before anything is published — two of the texture licences carry attribution and share-alike terms — then Q-03.
