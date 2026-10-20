# BALLS — Project charter

BALLS is an experimental 3D, high-speed downhill momentum game inspired by the *feel* of Haste, built with Godot 4.7.x on Arch Linux. Its distinguishing systems will eventually be seeded procedural levels, downhill movement, upgrades, and multiplayer. Game design specifics are deliberately deferred.

## Current scope
Issue #1: single-player movement sandbox. Build a small downhill course, a spherical `CharacterBody3D` player, jump/air control, follow camera, speed HUD, and reset. Use built-in assets for now.

## Intended milestones
1. Playable, tunable downhill movement sandbox.
2. Seeded procedural terrain/course generation.
3. Multiplayer foundation, with clear authority and input handling.
4. Data-driven upgrades.
5. Full game loop and design iteration.

This is a roadmap, not permission to implement future milestones early.

## Architectural defaults
- Prefer GDScript and Godot-native scenes/resources.
- Separate input collection from movement simulation, with future network input replication in mind.
- Keep movement tuning in exported variables or resources.
- Keep the player controller independent of any specific terrain scene.
- Favor simplicity and observed behavior over speculative frameworks.
- Multiplayer authority, prediction, and reconciliation are future design decisions; do not claim deterministic movement without testing.

## Environment
- GitHub: `Talref/balls`
- Local project root: `/home/eradan/s/balls`
- Godot 4.7.2-stable, Forward+
- OpenCode using local Qwen via LM Studio
- Godot MCP and Blender MCP; public web research through configured tools

The user directs goals and performs subjective playtests; agents implement and verify objective functionality.
