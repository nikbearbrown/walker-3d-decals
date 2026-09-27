# Verification and friction — 2026-09-24

Read README, project settings, tester script, decal scene and four texture
license files. Inspected main-scene node/connection inventory. No source 3d
AGENTS.md found. Created independent local copy; runtime title only changed.

Godot 4.7.2 headless import and 120-frame normal run both exited 0 with no
runtime errors (import-20260924.log and runtime-20260924.log). Headless startup
does not verify Forward+ decal pixels, filter quality, normals, emission or fades.

NEXT: route navigation, rotation/zoom and filter input; test physics ray placement
and decal animation lifetime. decal.tscn references Decal:extents in animation
tracks while the node specifies size; investigate actual behavior before fixing.
This is a source observation, not a reproduced failure yet. Read relevant
main-scene resources in full before modifying them.

No capture, render, publication or human approval. Both films remain pending
under the shared user-closed capture blocker. Retain this item for behavioral
checks before advancing to the next source.

## Navigation and animation probe — 06:14 UTC heartbeat

No existing Godot process or project AGENTS.md found. Separate test_state.gd
routes actual arrow key press/releases and a mouse drag through root.push_input.
state-20260924.log exits 0 with 16 passing checks: all ten tester indices/labels,
both navigation clamps, camera yaw change of -0.15 radians for 50 pixels,
decal growth, timed alpha fade and automatic disposal after five seconds.

The decal animation was instantiated as an explicit separate fixture, not placed
with the physics ray. Contrary to the suspected incompatibility, Decal:extents
tracks do affect size on this engine: size reached (2,2,2) after 0.3 seconds.
No speculative migration or runtime fix was made. This establishes current
engine behavior, not future compatibility or GPU visibility.

NEXT: verify zoom limits, actual filter input and P-key physics ray placement.
No Forward+ pixels or film footage captured. Both films remain pending under
the existing capture blocker; do not advance on the unfinished interaction tests.

## Remaining interaction checks — 06:44 UTC heartbeat

Extended test_state.gd with wheel limit checks (1.5 and 4), real keyboard popup
navigation selecting all six filter options with item_selected signals, and a
P-key ray placement. The first two runs failed placement: root.push_input mouse
motion delivered the event but get_mouse_position remained (0,0), producing an
empty ray. Logs interactions-20260924.log and ray-diagnostic-20260924.log retained.
This was a diagnostic input-delivery problem, not a reproduced game defect.

Using Input.parse_input_event for pointer motion updates the viewport mouse
position (observed 576,432 after viewport scaling). The real ray hit the existing
StaticBody3d floor at y=0; routed P press added one decal holder. No direct call
to the placement handler and no fabricated ray result. ray-input-20260924.log
exits 0 with 25 passing checks and no script errors. Only the diagnostic changed.
Wheel tests send pressed events, not complete OS scroll sequences. Filter
selection/signals pass, but actual RenderingServer filtering pixels remain
unverified under headless rendering. Placement check establishes holder creation,
not correct visible projection. Separate animation fixture still verifies fade
and five-second disposal, not every placed decal property.

Bounded state/input checks complete; next feasible source may be inspected while
Forward+ visual verification and both films remain pending under capture blocker.
