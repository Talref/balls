# BALLS — Verification

Before editing, read the active issue and confirm the Godot project is `/home/eradan/s/balls`.

Use Godot MCP and permitted shell **diagnostics** to check scenes, scripts, input mappings, and runtime errors. You may run project-scoped tests through the tools available to you. Do not change or terminate host processes when diagnosing failures. Retry intelligently instead of looping.

## Issue #1 minimum checks
- Godot opens the main scene without script/runtime errors.
- The ball spawns correctly, moves downhill, steers, jumps, and resets.
- Follow camera and horizontal-speed HUD work.
- Record which checks were actually run and what they showed.

## Delivery
Summarize files changed, controls, verification performed, errors, limitations, and unresolved blockers. Human playtesting decides whether movement feels fun, fast, and controllable. Leave the issue open until the human accepts the result.
