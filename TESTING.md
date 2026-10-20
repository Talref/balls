# BALLS — Verification protocol

## Before starting
- Read the issue acceptance criteria.
- Verify the intended Godot project and scene via Godot MCP, not by guessing.
- Do not modify the host to repair MCP availability.

## During implementation
- Use the smallest meaningful test after each subsystem.
- Validate scene paths, node names, resources, input actions, and scripts.
- Inspect Godot errors after changes. Report exact errors and fixes.
- Avoid unbounded retries. After two identical failures, stop and report the blocker.

## Minimum acceptance for issue #1
- The project opens in Godot and the main scene starts without errors.
- The player spawns without intersection, moves on terrain, accelerates downhill, loses speed climbing, jumps, steers with reduced air control, and resets.
- The camera follows smoothly and the HUD shows horizontal speed.
- Tests and observed results are documented; failures and untested cases remain explicit.

## Delivery
- Work in a feature branch.
- Report changed files, controls, verification performed, outstanding errors, and known limitations.
- A human must assess whether movement feels fun, fast, and controllable.
- Keep the GitHub issue open until accepted by the human.
