# Walker — Decals

**What this is.** An independent, title-only adaptation of the official Godot
demo `3d/decals`: one scene with ten decal examples (plasma and bullet stains,
paint and arrows, a water puddle, a blob shadow, sci-fi panels, a buff effect,
normal-map decals, distance fade, and decals on animated and transparent
meshes), a decal filter-mode picker, and one interactive action — press P to
place a decal where the mouse cursor points. It is a tech demo, not a game.

**Why it is in Walker.** It is one of Walker's Godot demo adaptations and the
source for two planned native-4K Liam films.

**What was found and verified.** Godot 4.7.2 headless import and a 120-frame
normal run both exit 0 with no runtime errors. A headless input probe
(`godot/test_state.gd`) passes 25 checks: all ten examples reached with arrow
keys, both navigation clamps, drag rotation, wheel zoom limits, all six filter
options selected through keyboard input, a P-key ray that hits the floor and
adds one decal, and the placed decal's growth, fade and five-second removal.
Headless checks do not verify Forward+ decal pixels, filter quality, normals,
emission or fades.

## How to run

Open `godot/project.godot` in Godot 4.7 and run the main scene (`test.tscn`).

Controls (from the source):

- Left / right arrow keys, or the « Previous / Next » buttons: browse decal examples
- Drag with a mouse button (left, right or middle): orbit
- Mouse wheel: zoom
- P: place a decal at the cursor position
- Top-left menu: decal filter mode (Nearest, Linear, with Mipmaps, with 16× Anisotropic)

## Design

- [GDD.md](GDD.md) — recovered game design document (identical copy of
  `design/GDD.md`)
- [design/DECK.html](design/DECK.html) — review slides
- [design/IMPLEMENTATION-MAP.md](design/IMPLEMENTATION-MAP.md) — feature → scene/script/line
- [design/decisions.md](design/decisions.md) — open questions

The GDD was recovered from the code by Walker's Zelda GDD skill
(`/gdd reverse`, silent). It describes what exists; it is not an approved
design, and every gate is unsigned.

## Source & license

Upstream: Godot `3d/decals`, source commit
`a3b5c113112f77291d5f3d1360f33a882fdc52f7`. Source remains untouched. Original
assets, UIDs, import settings and README retained under `godot`; Godot
contributor MIT notice retained in `LICENSE.md`.

Retained asset notices: Kenney checker (2020), CC0; johndn paint (2010), CC-BY 3.0;
Alex Foster painted arrow (2020), CC-BY-SA 3.0; Yughues sci-fi (2012), CC0.
See `godot/textures/*.LICENSE.md` for original URLs. Preserve these credits in
eventual outputs and review asset license obligations before distribution.

## Status

Forward+ GPU appearance and both native-4K Liam films remain unverified/pending.
The dated work log is in `FRICTIONAL.md`; test logs (`import-`, `runtime-`,
`state-`, `interactions-`, `ray-diagnostic-`, `ray-input-20260924.log`) are kept
at the folder root.

Repository: https://github.com/nikbearbrown/walker-3d-decals
