# Day Long Addict — Art Direction and UI Visual Standard

## 1. Overall art direction

**Direction:** grounded, stylized semi-realistic wilderness survival.

The game should feel like a believable outdoor survival adventure, but with simplified shapes, readable silhouettes and controlled detail so it remains practical on Android. Avoid mixing photorealistic characters with cartoon trees or unrelated asset-pack styles.

**Visual keywords:** rugged, calm, outdoors, crafted, readable, rewarding, warm.

**Lighting mood:** natural daylight with soft shadows; warm golden-hour highlights; cool blue night lighting. Rain should change ambience through sound, particles and material response, not expensive simulation.

## 2. Colour and material system

Use a restrained palette. These are starting design tokens, not final texture colours:

| Token | Hex | Use |
|---|---|---|
| Pine | #263D32 | Main dark green, headings and selected navigation |
| Forest | #47634A | Secondary green, panels and nature accents |
| Moss | #87936A | Secondary highlights and progress |
| Sand | #C8B48A | Warm neutral surfaces |
| Canvas | #E6DDC8 | Main light text and parchment surfaces |
| Charcoal | #202722 | Dark UI panels and text |
| Amber | #E5A84B | Primary action, task timer and reward accent |
| Danger | #C96555 | Low health, failed task and urgent warnings |
| Water | #5E8790 | River, fishing and water-related UI |

Use warm off-white for text on dark panels. Do not use red as a general accent; reserve it for genuinely urgent states. Keep item rarity colours consistent wherever an item appears.

**Material language**
- Wood: warm, slightly varied grain; avoid noisy high-resolution tiling.
- Stone: cool grey with broad readable shapes.
- Iron: dark desaturated metal with restrained edge highlights.
- Leather and cloth: matte surfaces with minimal gloss.
- UI panels: dark charcoal-green translucent panels, subtle border, modest corner radius and soft shadow.

## 3. UI visual design

### Design principles

- Touch-first: important touch targets should normally be at least 48 dp, with larger primary controls.
- Show only information needed for the current moment.
- Use icon plus short label for unfamiliar actions.
- Keep decorative frames thin and low contrast.
- Use consistent spacing steps: 8, 12, 16, 24 and 32 dp.
- Use TextMeshPro for crisp, scalable text.
- Avoid tiny text, dense inventory grids and text baked into images.
- Use safe-area anchors and Canvas Scaler; do not position controls using fixed screen pixels.

### In-game HUD layout

**Top-left:** compact player status panel with health, stamina and hunger. Use short labels or clear icons. Bars should show both current level and low-state warning.

**Top-centre:** current task card. Show task name, target count, reward preview and a clear countdown. The countdown should change to amber when time is low and danger red only at the urgent threshold. Do not cover the player's view with a large permanent panel.

**Top-right:** small currency and day/time display. Keep it compact.

**Bottom-left:** movement joystick with a clear outer ring, a soft inner thumb pad and a high-contrast active state.

**Bottom-right:** primary action button (context-sensitive), jump button and one small secondary action. Avoid a cluster of tiny buttons.

**Right edge or a dedicated pause panel:** inventory, crafting, map and settings entry points. Keep them away from the look-drag area where possible.

### Phone and tablet behaviour

Use one responsive Canvas, not separate game projects.

- Phone landscape: compact status/task bars, controls anchored near lower corners, short labels.
- Tablet landscape: increase panel spacing and card width modestly; keep controls close to the screen edges and keep the central play area clear.
- Do not scale every control linearly with screen width. Cap maximum control size so tablet controls do not become absurdly large.
- Test at 16:9, 20:9 and a tablet landscape aspect ratio.
- Use SafeAreaFitter only on the parent container that owns the safe-area layout. Do not apply it to every individual button.

### Menus and panels

Use the same dark green/charcoal panel, warm neutral text and amber primary action throughout:
- Main menu: large world background image, title, Continue, New Game, Settings.
- Inventory: readable slot grid, selected item details and one obvious action.
- Crafting: recipe list on one side, requirements and result preview on the other; stack vertically on narrow screens.
- Task board: active, available and completed sections with clear reward summaries.
- Settings: large toggles and sliders; avoid tiny checkboxes.

### Motion and feedback

- Button press: scale down slightly (about 0.97), then return smoothly.
- Task completion: brief amber highlight, reward count-up and a small non-blocking success banner.
- Item pickup: small icon and quantity near the edge of the HUD, not a full-screen interruption.
- Low stamina: gentle bar pulse, not screen shake.
- Use short transitions; never make a player wait through a long animation to collect a reward.

## 4. World and environment art

### Biome identity

Each biome needs a distinct silhouette and colour identity, while sharing one material and lighting language.

- **Forest:** layered pine and broadleaf tree silhouettes, mossy ground, fallen logs, ferns and occasional clearings. Use a small number of plant variants with instancing and LODs.
- **River:** readable banks, stones, reeds and a simple scrolling or reflective water material. No fluid simulation.
- **Mountain:** larger rock forms, sparse vegetation, cooler palette and clear distant silhouettes.
- **Beach:** pale sand, darker wet shoreline, driftwood and low scrub. Keep the horizon clean.

### World composition

- Use a few large landmarks per chunk so players can navigate by sight.
- Keep resource nodes visually distinct from decoration.
- Place trees and rocks in clusters with intentional open paths; avoid random clutter everywhere.
- Use distance fog and sky colour to soften far terrain.
- Seeded generation must produce the same biome layout and resource placements for the same world seed.

### Mobile performance rules

- Use URP, baked lighting where possible and one main real-time shadow-casting light.
- Keep shadow distance short and use simple shadow cascades.
- Use LOD Groups for trees, rocks and larger props.
- Enable GPU instancing on compatible repeated materials.
- Avoid per-blade grass, per-leaf physics, real-time global illumination and expensive transparent particle layers.
- Limit particle counts; use pooled leaves, dust, rain and pickup effects.
- Profile on a real Android device before raising texture size, shadow quality or render scale.

## 5. Character design

**Player silhouette:** practical wilderness traveller, readable from behind and at a distance. Use layered outdoor clothing, sturdy boots, gloves and a compact backpack. Keep the base outfit neutral so equipment upgrades can be shown through clear add-ons rather than a completely different character each tier.

**Design rules**
- Use one consistent humanoid rig for the player and compatible NPCs where possible.
- Keep the face and small accessories low-detail; the camera is mostly behind the player.
- Use a small number of material slots.
- Avoid dangling straps, hair cards or accessories that require expensive physics.
- Equipment should change the silhouette in a controlled way: backpack, belt pouch, shoulder tool loop and visible tool attachment.

The current capsule is only a controller placeholder. Replace it with a properly licensed humanoid character model and matching animations after movement and camera are proven.

## 6. Tools and equipment design

Tools should be instantly recognisable by silhouette and material:

- **Wood tier:** rough wood handles, simple stone or basic metal heads, visible rope or binding.
- **Stone tier:** chunkier stone heads and wrapped grips.
- **Iron tier:** cleaner metal head, darker handle details and a small amber/metal accent.

Keep upgrade differences readable without adding lots of geometry. Use a shared scale and attachment point so tools can be swapped on the character and used by the same animation rig.

For first implementation, use one axe and one pickaxe model. Add a fishing rod after the gathering loop works. Tool models must be imported assets; do not create 3D geometry procedurally in C#.

## 7. Animation plan

Use a compatible humanoid rig and a small, polished animation set before expanding.

**Player baseline**
- Idle breathing.
- Walk forward and directional movement.
- Jog/run.
- Start/stop locomotion blend.
- Jump take-off, fall and land.
- Tool equip and stow.
- Axe gather/chop.
- Pickaxe mine.
- Fishing cast and reel.
- Pickup/carry interaction.
- Basic craft/work interaction.

**Wildlife baseline**
- Idle variation.
- Walk/trot.
- Turn in place.
- Flee.
- Simple eat/drink idle only where useful.
- Bird flap, perch and take-off.
- Fish swim and short surface movement.

**Animation implementation**
- Use Animator Controllers with clear states and transitions.
- Use a locomotion Blend Tree for idle/walk/run.
- Use Avatar Masks or upper-body layers for compatible tool actions where appropriate.
- Use animation events only for timed presentation effects; gameplay resource removal must be validated by the gameplay system, not depend only on an animation event.
- Avoid root motion for the initial mobile controller. Keep movement controlled by CharacterController.
- Avoid running complex animation rigs on distant wildlife; use simpler states or disable animators when far away.

## 8. Suggested asset selection checklist

Before importing an asset pack, verify:
1. It has a clear license permitting the intended game use.
2. Character model and animations use compatible rigs or include retargeting support.
3. Texture resolutions and material counts are appropriate for Android.
4. Models include LODs or can be reduced without destroying the silhouette.
5. Its art style matches the chosen grounded, stylized semi-realistic direction.
6. The pack does not require paid shaders or plugins that the project does not use.

Choose one environment pack and one character/animation source first. Do not combine several packs until their scale, palette, roughness and lighting have been matched.

## 9. Implementation order

1. Establish the UI theme tokens and a reusable button/panel style.
2. Restyle the joystick and jump button while keeping their input scripts unchanged.
3. Build the HUD layout and test phone/tablet safe areas.
4. Import one player model and a basic locomotion set.
5. Add axe and pickaxe models with one matching action animation each.
6. Create one small forest test environment and tune lighting/materials.
7. Add the other biomes only after the forest scene performs well on-device.

## 10. Acceptance criteria

- HUD is readable at phone and tablet landscape resolutions.
- Touch targets remain usable and do not overlap the camera drag area.
- Player, tools, props and environment share a consistent art style.
- Player animations blend without visible snapping during normal movement.
- Important resource nodes stand out from decoration.
- The test scene holds a stable frame rate on the target device before adding more foliage, shadows or particles.
- All imported assets have recorded license/source information.

## Current implementation status

This document establishes the art direction and implementation standard. It does not claim that visual assets, a finished HUD, character model, tool models, environments or animations have been imported into Unity. The repository currently contains Phase 1 scripts and setup documentation; Unity scene construction, asset selection and in-Editor visual testing remain to be done.
