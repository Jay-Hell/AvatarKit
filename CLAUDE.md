# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build
swift build

# Run all tests
swift test

# Run a single test
swift test --filter AvatarKitTests.LayerOrderTests/testRawValues
```

## Architecture

AvatarKit is a dependency-free SwiftUI library for rendering customizable layered avatars, targeting iOS 16+ and macOS 13+.

### Core types

- **`AvatarConfiguration`** — holds a `SkinTone` and a dictionary of `[LayerOrder: any AvatarLayer]` for equipped items. `.defaultConfiguration` (static property) returns medium skin, no equipped items.
- **`AvatarLayer`** (protocol) — custom layer contract: `itemID`, `layerOrder`, and `renderView() -> AnyView`. Implement this to create custom clothing/accessory layers.
- **`LayerOrder`** (enum, `Int`, `Comparable`) — 9 rendering depths: `background(0)`, `body(10)`, `shoes(20)`, `bottom(30)`, `top(40)`, `accessory(50)`, `hair(60)`, `pet(70)`, `expression(80)`.
- **`SkinTone`** (enum) — `light`, `medium`, `dark`, each mapped to specific RGB `Color` values.
- **`ColourPalette`** — `primary`, `secondary`, `accent` colors with a `from(hex:)` factory utility.

### Rendering pipeline

`AvatarCompositorView` is the public-facing view. It:
1. Iterates `LayerOrder` cases in order.
2. Renders the equipped item from `AvatarConfiguration.equippedItems` if present, otherwise falls back to the corresponding sub-layer in `AvatarBaseView`.
3. Optionally applies a drop shadow.

`AvatarBaseView` contains the complete default avatar as 9 nested SwiftUI sub-views assembled in a `ZStack`. Sub-views that style clothing/background take a `ColourPalette` parameter (`BackgroundLayer`, `HairLayer`, `TopLayer`, `BottomLayer`, `AccessoryLayer`). Body-related views take a `SkinTone` (`BodyLayer`, `HeadLayer`). `FaceLayer`, `ShoesLayer`, and `PetLayer` take no parameters. `AccessoryLayer` and `PetLayer` render as `EmptyView()` by default.

## Visual style rules (apply to ALL generated layers and items)

These rules are mandatory for every shape drawn in any avatar layer.

### Stroke
Every shape must have an outline overlay:
```swift
.overlay(shape.stroke(ColourPalette.from(hex: "#2A2A2A"), lineWidth: 2.5))
```

### Colours
- Use a base fill colour **and** a shadow colour that is 15% darker (reduce brightness).
- Apply the darker variant to the bottom-right area of rounded shapes to imply depth.

### Body proportions (canvas = 200×350 pt)
| Region | Height |
|---|---|
| Head | 38% → ~133 pt |
| Torso | 30% → ~105 pt |
| Legs | 32% → ~112 pt |

### Limbs
- Arms: max **12 pt** wide — short and stubby.
- Legs: max **18 pt** wide — short and stubby.

### Clothing details
- Every clothing item must include at least one visible **waistband**, **cuff**, or **hem** as a separate shape.
- Shoes must have a distinct **toe cap** (lighter colour) and **heel** (darker colour) as separate shapes.

### Corners & complexity
- Minimum `cornerRadius` of **8 pt** on every rectangular shape — corners must be heavily rounded.
- No thin lines. No complex bezier paths. All shapes must be chunky and simple.

### Style reference
Flat cartoon style matching a children's dress-up app.
