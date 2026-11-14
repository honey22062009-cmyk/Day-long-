# Day Long Addict — Phase 1 Setup

## Device target

The first playable build targets Android phones and Android tablets in landscape orientation. The UI uses anchors, a Canvas Scaler and the screen safe area so one ARM64 APK can adapt to different screen sizes. A separate phone and tablet project is not needed.

The first milestone is a gray-box test scene: a capsule player, a ground plane, a virtual movement joystick, a drag-to-look area and a jump button. Replace the capsule with an imported character model and animation controller after movement is reliable.

## Recommended Unity project

- Unity 6 LTS, Universal 3D (URP) template.
- Android Build Support with Android SDK & NDK Tools and OpenJDK.
- Install TextMeshPro Essentials when prompted.
- Install the Input System package from Window > Package Manager.
- In Edit > Project Settings > Player > Other Settings, set Active Input Handling to Input System Package (New), then restart the Editor if requested.
- In Project Settings > Player, set Default Orientation to Landscape Left or Auto Rotation with only landscape orientations enabled.
- For the first device tests, leave Auto Graphics API enabled. Test Vulkan on the target devices before forcing it; keep an OpenGL ES fallback until compatibility is confirmed.
- Use ARM64 (IL2CPP) for a modern Android release build.

## Folder structure

Create these folders under Assets/DayLong:

- Scenes
- Scripts/Player
- Scripts/Camera
- Scripts/UI
- Prefabs
- Materials
- Art/Characters
- Art/Environment

The scripts in this repository are already placed under Scripts/Player, Scripts/Camera and Scripts/UI.

## Build the test scene

1. Create a new scene named DayLongDemo and save it in Assets/DayLong/Scenes.
2. Add a Plane at position (0, 0, 0), scale (5, 1, 5). Keep it static for this test.
3. Create an empty GameObject named Player at (0, 0, 0).
4. Add a CharacterController to Player. Start with Center (0, 1, 0), Height 2 and Radius 0.4.
5. Add a Capsule as a child of Player at local position (0, 1, 0). This is only a placeholder visual, not a final character model.
6. Add ThirdPersonPlayerController to Player. Assign the MobileJoystick and Main Camera transform in its Inspector fields after creating the UI.
7. Create a Camera named Main Camera. Add ThirdPersonCameraController. Assign Player as Follow Target and assign the MobileLookArea component.
8. Create a Canvas. Set Render Mode to Screen Space - Overlay. Add Canvas Scaler and set UI Scale Mode to Scale With Screen Size, Reference Resolution to 1920 x 1080, and Screen Match Mode to Match Width Or Height (Match = 0.5).
9. Under Canvas, create a full-screen transparent Image named LookArea. Keep Raycast Target enabled and set its anchors to stretch across the full Canvas. Add MobileLookArea.
10. Create a UI Image named JoystickBackground, anchor it to the bottom-left, and size it about 260 x 260. Add MobileJoystick; assign its own RectTransform to Background. Add a child Image named JoystickHandle, size about 110 x 110, and assign it to Handle.
11. Create a UI Image named JumpButton, anchor it to the bottom-right, size about 150 x 150. Add MobileJumpButton.
12. Keep LookArea behind the joystick and jump button in the Canvas hierarchy so the controls receive their own pointer events.
13. Create an EventSystem. Replace Standalone Input Module with Input System UI Input Module. Assign the default UI actions when prompted by the Inspector.
14. Add a child Panel under Canvas named SafeArea, stretch it to the full Canvas, move the joystick, jump button and look area inside it, and add SafeAreaFitter to SafeArea.
15. On Player, assign JoystickBackground's MobileJoystick, JumpButton's MobileJumpButton and Main Camera's Transform. On Main Camera, assign Player as Follow Target and LookArea's MobileLookArea.

### Suggested hierarchy

    DayLongDemo
    ├── Directional Light
    ├── Ground
    ├── Player
    │   └── CharacterVisual (Capsule placeholder)
    ├── Main Camera
    ├── Canvas
    │   └── SafeArea
    │       ├── LookArea
    │       ├── JoystickBackground
    │       │   └── JoystickHandle
    │       └── JumpButton
    └── EventSystem

## Android orientation and responsive layout

Use landscape for the initial open-world control scheme. Keep the joystick and jump button anchored to opposite lower corners, not positioned with fixed screen coordinates. The SafeAreaFitter component handles display cutouts and rounded corners. Test at least one phone aspect ratio and one tablet aspect ratio before UI polish.

## Current phase limits

- The capsule is a temporary movement placeholder. It is not a generated or final 3D model.
- Camera collision, sprinting, crouching, combat, interaction prompts, animation and world systems are not part of this phase.
- This camera intentionally uses a small custom follow script to avoid making the first prototype depend on an extra camera package/API version. Cinemachine can be evaluated later if it materially improves the camera.
- Keep the scene small and use a simple plane until the controller is stable.

## APK delivery plan

A final APK must be produced by a real Unity Android build using the Android SDK/NDK and OpenJDK. The intended remote route is a GitHub Actions build runner using Unity command-line build tooling. That runner also needs a valid Unity license configured securely as a GitHub Actions secret. The repository does not contain a license, password, or signing key.

No APK is claimed by this phase: these source files have not yet been imported into Unity, compiled by the Unity Editor, or run on a physical Android device. After a Unity project version and first scene are verified, add and test the automated Android build workflow, then attach the generated APK to a GitHub release or workflow artifact.
