# Day Long Addict

A single-player 3D open-world survival game for Android phones and tablets, built with Unity.

## Project status

**Early prototype foundation.** The repository contains Phase 1 touch-control and third-person controller scripts, setup documentation, and an art-direction guide. A Unity project, playable scene, imported art assets and Android APK have not yet been built or tested.

## Visual direction

Grounded, stylized semi-realistic wilderness survival. The UI, player, tools and environments should share a restrained forest-and-earth palette, readable silhouettes and mobile-friendly detail levels.

See [Art Direction and UI Visual Standard](Docs/ART_DIRECTION_AND_UI.md) for the HUD layout, design tokens, character/tool direction, animation checklist and Android graphics limits.

## Planned technology

- Unity 6 LTS
- C#
- Universal Render Pipeline (URP)
- New Input System
- TextMeshPro
- Android phones and tablets

## Development phases

1. Project setup, touch controls, third-person character and camera
2. Procedural chunk-streamed terrain and biomes
3. Inventory
4. Gathering and mining
5. Crafting and equipment upgrades
6. Building
7. Timed task system
8. Wildlife AI
9. Day/night cycle, weather and graphics polish
10. Saving, menus, optimization and Android build

## Getting started

Create the Unity project in Unity Hub using the Universal 3D (URP) template. Place the project files in this repository and keep the selected Unity version consistent. Follow [Phase 1 Setup](Docs/PHASE_01_SETUP.md).

Do not commit generated folders such as Library/, Temp/, Obj/ or build output. See the .gitignore file.

## Android target

One responsive Android build should support phone and tablet landscape layouts. Aim for 60 FPS on capable devices, with a stable 30 FPS fallback on less capable hardware. Measure performance on real target devices before increasing visual quality.

## Build status

No APK is currently available. A real Unity Android build and device test are required before a release can be published.
