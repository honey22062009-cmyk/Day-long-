# Day Long Addict — Phase 1 Setup

## Device target

The first playable build targets Android phones and Android tablets in landscape orientation. The UI uses anchors, a Canvas Scaler and the screen safe area so one ARM64 APK can adapt to different screen sizes. A separate phone and tablet project is not needed.

The first milestone is a gray-box test scene: a capsule player, a ground plane, a virtual movement joystick, a drag-to-look area and a jump button. Replace the capsule with an imported character model and animation controller after movement is reliable.

## Recommended Unity project

- Use an installed Unity 6 LTS editor with the Universal 3D (URP) template.
- Install Android Build Support with Android SDK & NDK Tools and OpenJDK through Unity Hub.
- Install the Input System package from Window > Package Manager.
- In Edit > Project Settings > Player > Other Settings, set Active Input Handling to Input System Package (New), then restart the Editor if requested.
- In Project Settings > Player > Resolution and Presentation, set Default Orientation to Landscape Left. Enable only landscape orientations if using Auto Rotation.
- For first device tests, leave Auto Graphics API enabled. Test Vulkan on the target devices before forcing it; keep an OpenGL ES fallback until compatibility is confirmed.
- Use ARM64 (IL2CPP) for a modern Android release build.
- Import TextMeshPro Essentials only when a TMP text object is first created (not required by this phase's scripts).

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
2. Add a Plane at position (0, 0, 0), scale (5, 1, 5). Keep it at the default layer and make sure its Mesh Collider remains enabled.
3. Create an empty GameObject named Player at (0, 0, 0).
4. Add a CharacterController to Player. Start with Center (0, 1, 0), Height 2, Radius 0.4, Step Offset 0.3 and Skin Width 0.08.
5. Add a Capsule as a child of Player at local position (0, 1, 0). This is only a temporary visual, not a final character model. Remove the Capsule child's Capsule Collider; the Player's CharacterController handles collision.
6. Add ThirdPersonPlayerController to Player.
7. Create a Camera named Main Camera and add ThirdPersonCameraController.
8. Create a Canvas. Set Render Mode to Screen Space - Overlay. Keep its Graphic Raycaster enabled. Add Canvas Scaler and set UI Scale Mode to Scale With Screen Size, Reference Resolution to 1920 x 1080, and Screen Match Mode to Match Width Or Height (Match = 0.5).
9. Under Canvas, create an empty UI child named SafeArea. Stretch its RectTransform to all four Canvas edges (anchors Min 0,0 and Max 1,1). Add SafeAreaFitter. Use an empty object, not a Panel with an Image, so it cannot intercept UI raycasts.
10. Under SafeArea, create a full-stretch transparent UI Image named LookArea. Keep Raycast Target enabled and set its anchors to stretch across SafeArea. Add MobileLookArea. Set its Image color alpha to 0 if you want it invisible.
11. Under SafeArea, create JoystickBackground as a UI Image. Anchor it to bottom-left, set its pivot to (0,0), position to about (150,150), and size to about 260 x 260. Add MobileJoystick; assign its own RectTransform to Background.
12. Add a child UI Image named JoystickHandle, size about 110 x 110, and assign its RectTransform to Handle on MobileJoystick. Keep the handle's Raycast Target enabled so pointer events can bubble to the joystick parent.
13. Under SafeArea, create JumpButton as a UI Image. Anchor it to bottom-right, set its pivot to (1,0), position to about (-150,150), and size to about 150 x 150. Add MobileJumpButton.
14. Keep the Canvas order exactly like this: LookArea first, JoystickBackground second, JumpButton third. The joystick and jump button must be above LookArea in the hierarchy so they receive their own touches.
15. Create an EventSystem using GameObject > UI > Event System. If its Inspector shows a Replace with InputSystemUIInputModule button, click it. Otherwise remove Standalone Input Module and add Input System UI Input Module. The module normally assigns its default UI actions automatically. Check that Point and Left Click are assigned; also check the navigation, Submit and Cancel actions if you use keyboard/controller navigation.
16. On Player, assign JoystickBackground's MobileJoystick, JumpButton's MobileJumpButton and Main Camera's Transform.
17. On Main Camera, assign Player as Follow Target and LookArea's MobileLookArea.

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

## How to test in the Editor

- Press Play and drag the joystick with the mouse to move the capsule.
- Drag an empty part of the right side of the screen to orbit the camera.
- Press the jump image to jump.
- Tap Jump while airborne; that tap should be ignored rather than stored for a jump on landing.
- Use the Game view aspect-ratio menu to test a phone-shaped and tablet-shaped landscape view.
- Check the Console for missing-reference warnings from the player and camera scripts.

## Current phase limits

- The capsule is a temporary movement placeholder. It is not a generated or final 3D model.
- Camera collision, sprinting, crouching, combat, interaction prompts, animation and world systems are not part of this phase.
- This camera intentionally uses a small custom follow script to avoid making the first prototype depend on an extra camera package/API version. Cinemachine can be evaluated later if it materially improves the camera.
- Keep the scene small and use a simple plane until the controller is stable.

## APK delivery plan

A final APK must be produced by a real Unity Android build using the Android SDK/NDK and OpenJDK. The intended remote route is a GitHub Actions build runner using Unity command-line build tooling. That runner also needs a valid Unity license configured securely as a GitHub Actions secret. The repository does not contain a license, password, or signing key.

No APK is claimed by this phase: these source files have not yet been imported into Unity, compiled by the Unity Editor, or run on a physical Android device. After a Unity project version and first scene are verified, add and test the automated Android build workflow, then attach the generated APK to a GitHub release or workflow artifact.
