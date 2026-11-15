# Day Long Addict

**Day Long Addict** is a single-player, Android-first 3D wilderness survival game built with Godot 4.7.1.

The repository has been restarted as a clean Godot project. The earlier Unity-only skeleton is replaced on the current branch.

## First playable prototype

- Third-person 3D player with keyboard and mobile touch movement.
- Drag-to-look camera and touch jump button.
- Generated forest clearing, rocks, river strip, and collectible resources.
- Collect wood, stone, and berries.
- Eat berries to restore hunger and a little thirst.
- Build a shelter after collecting 3 wood and 2 stone.
- Day/night lighting cycle and local JSON save.

This is the first playable foundation, not the finished open-world game. Art currently uses generated low-poly primitives. Richer terrain, crafting, wildlife, weather, sound, animation, and expanded survival systems are later phases.

## Android APK

Every push to main starts the **Build Android APK** GitHub Actions workflow. A manual run is also available under the repository's Actions tab.

After a successful run:
1. Open the latest successful Build Android APK run.
2. Open Artifacts.
3. Download the Day-Long-Addict-Android-APK ZIP.
4. Extract the ZIP and install the APK on an Android device.

The workflow creates a temporary debug-signed APK for testing. It is not a Play Store release build. No private signing key is stored in this repository.

## Controls

| Action | Touch | Desktop test |
|---|---|---|
| Move | Left virtual joystick | WASD |
| Look around | Drag on right side | Hold right mouse button and move |
| Jump | JUMP button | Not mapped |
| Collect supply | GATHER button | GATHER button |
| Build shelter | BUILD button | BUILD button |
| Eat berries | EAT button | EAT button |

## Project layout

- project.godot - Godot project settings.
- scenes/main.tscn - Main game scene.
- scripts/main.gd - World, player, survival loop, UI, and save logic.
- scripts/touch_stick.gd - Mobile virtual joystick.
- export_presets.cfg - Android export preset.
- .github/workflows/android-apk.yml - Cloud APK build.

## Verification status

The project and workflow are committed first. The Actions run must complete before an APK can be described as built. A successful export still needs an install-and-play check on a physical Android device.
