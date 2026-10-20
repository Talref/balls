# PROGRESS — Milestone 001 development checkpoint

Branch: `feat/milestone-001-movement-sandbox` (from `main`) · Date: 2026-10-20
Status: **complete** — all tests A–E pass, final code headless-clean, committed and pushed;
PR #3 open with `Closes #1`; issue left open for human playtest acceptance.

## Implemented features

**Playable downhill course** (`scenes/sandbox.tscn`, the project main scene), built from
built-in box meshes and standard materials only:

| Segment | Top height (y) | z range | Notes |
|---|---|---|---|
| StartPlatform | 20.0 | -6 → 6 | spawn platform, ball rests at y ≈ 20.5 |
| T1–T5 | 20 → ~8.9 | 6 → 36 | five gradual downhill segments, 10°/15°/20°/25°/30° |
| Gap 1 | — | 36 → 40 | jumpable gap |
| MidFlat | 3.0 | 40 → 52 | flat landing area |
| JumpRamp | 3 → 6 | 52 → 58 | uphill ramp at 26.57° (launches over Gap 2) |
| Gap 2 | — | 58 → 62 | jumpable gap |
| FinishArea | 0.0 | 62 → 80 | flat finishing area |
| VoidFloor | -15.25 | whole course | far-below floor so falls are visible, not fatal |

**Kinematic ball controller** (`scripts/player.gd`, `CharacterBody3D`):

- Movement simulated in `_physics_process`; input collection is separated into
  `collect_input()`, which fills a plain `PlayerInput` data struct — the physics step only
  consumes that struct (multiplayer-ready seam).
- Tuning via exported variables: `gravity_scale` (2.0), `ground_accel` (20 m/s²),
  `air_control_factor` (0.35), `drag` (0.1 /s), `jump_speed` (7.5 m/s),
  `max_horizontal_speed` (32 m/s), `spawn_position`.
- Momentum-preserving: steering adds acceleration on top of existing velocity; airborne
  steering is 35% of grounded strength; jump only fires while grounded and preserves
  horizontal momentum; mild linear drag plus a hard 32 m/s cap.
- Screen-relative third-person steering from camera yaw, with world-axis fallback if no
  camera is assigned. Player logic is independent of level geometry (no hardcoded course refs).
- Visual-only rolling rotation on the mesh child (body never rotates), guarded against
  zero-length axis/omega vectors.

**Camera** (`scripts/camera_rig.gd`): smooth third-person follow — lerped position offset
behind/above the player, look-at with smoothing. No occlusion handling yet.

**HUD** (`scripts/hud.gd`): `SpeedLabel` shows horizontal speed in m/s every frame;
`HintLabel` shows controls (WASD/arrows steer · Space jump · R reset).

**Reset**: holding the `reset` action teleports the player to `spawn_position` with zero
velocity and resets visual roll.

**Project setup**: Jolt physics engine, procedural sky environment (`env.tres`), input
actions defined in `project.godot`, sandbox scene registered as main scene.

## Relevant files

- `scenes/sandbox.tscn` — course + player + camera rig + HUD (main scene)
- `scripts/player.gd` — kinematic controller, input struct, reset
- `scripts/camera_rig.gd` — follow camera
- `scripts/hud.gd` — speed readout + control hints
- `shapes/*.tres`, `meshes/*.tres` — box collision shapes / mesh resources per segment
- `env.tres` — procedural sky environment
- `project.godot` — engine, physics (Jolt), input actions, main scene
- `addons/godot_mcp/mcp_runtime_probe.gd` — MCP runtime probe autoload (dev tooling only)

## Current test results (Godot MCP, live play session)

- **Test A — settle: PASS.** Ball spawned at rest settles to `(0, 20.5007, 0)` with zero
  velocity; no drift or jitter.
- **Test B — jump: PASS.** Grounded jump reaches peak y ≈ 21.98 (expected ≈ 21.94 for
  g_eff = 19.6 m/s²); re-jump while holding the action works as designed; ball settles back
  to y ≈ 20.500. `simulate_action` input confirmed working end-to-end.
- **Test C — trajectory: PASS (with note).** With forward steering held continuously, the
  ball stays on the surface through T1–T5, crosses Gap 1 onto MidFlat, climbs JumpRamp, then
  overshoots FinishArea past z = 80 and falls toward the void beyond the course end.
  Releasing steering before the ramp would land it in FinishArea — this is sandbox behavior,
  not a bug (no win/lose state yet).
- **Test D — HUD: PASS.** SpeedLabel updates live while moving: 0.0 → 15.1 → 27.8 → 32.0 m/s
  (reaches the `max_horizontal_speed` cap, confirming the cap works).
- **Test E — reset: PASS.** With the ball mid-fall past the course end (y ≈ -49.7M), holding
  `reset` teleported it to exactly `(0, 21, 0)` with zero velocity and held it there; after
  release normal physics resumed and it settled back to y ≈ 20.5007.
- **Headless validation:** `godot --headless --path . res://scenes/sandbox.tscn --quit` loads
  clean; `--check-only --script` parse checks pass for all three scripts.

## Known issues / limitations

1. **Editor stale-script cache (this session only).** The long-running editor session keeps a
   cached old version of `player.gd`; live runs show 13 `"The axis Vector3 (0,0,0) must be
   normalized"` errors from that stale copy even though the on-disk code has guards. Two
   forced-recompile attempts failed; per project rules we stopped fighting it. The headless
   `run_and_capture` run of the final on-disk code is treated as the authoritative zero-error
   proof. Live movement results remain valid because old/new scripts differ only in
   `_update_visual_roll`.
2. **Seam hops** of < ~0.2 m at slope segment corners (geometry approximation).
3. **No camera occlusion handling.**
4. **Overshoot past FinishArea** when steering is held continuously — falls to the void floor
   beyond the course end; acceptable sandbox behavior for this milestone.
5. **Feel untested** — movement has not been human-played; no claim that it "feels good".

## Acceptance criteria (GitHub issue #1)

All agent-side work is done:

- [x] Test E — reset verified via MCP input simulation (see results above).
- [x] TEMP debug marker removed from `player.gd`.
- [x] Orphaned resources deleted (`shapes/box_20x0p5x22p36.tres`,
      `meshes/box_20x0p5x22p36.tres`; grep confirmed no references).
- [x] Final headless `run_and_capture` of the committed code — zero errors / zero warnings.
- [x] Committed (scaffolding + sandbox implementation), branch pushed, PR #3 opened with
      `Closes #1`.

Remaining: **human playtest acceptance** — issue intentionally left open until a human plays
the build and confirms feel/controls.
