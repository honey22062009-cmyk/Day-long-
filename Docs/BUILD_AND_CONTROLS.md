# Build and Controls

## Android cloud build

The GitHub Actions workflow downloads the pinned Godot 4.7.1 stable editor and matching export templates, installs the Android SDK packages, imports the project in headless mode, and exports a debug-signed APK.

The temporary debug signing key is generated inside the GitHub runner. It is not committed to the repository and must not be used as a permanent release identity.

## First playable loop

1. Move around the forest clearing.
2. Find pickups for wood, stone, and berries.
3. Stand close to a pickup and press GATHER.
4. Collect at least 3 wood and 2 stone.
5. Press BUILD to place the first shelter.
6. Use EAT when you have berries to recover some hunger.

Hunger and thirst decrease gradually while the game is running. Progress and player position are stored locally in the app's user data.

## Input

The left virtual joystick controls movement. Dragging in the upper-right look area rotates the third-person camera. Buttons on the right trigger jump, gathering, shelter building, and eating.

WASD and right-mouse drag are included for desktop testing. Android is the primary target.
