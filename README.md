# AvatarKit

A lightweight, dependency-free SwiftUI library for rendering customizable layered avatars.

**Version:** 1.3.0 · **Platforms:** iOS 16+ · macOS 13+

---

## Installation

Add AvatarKit to your project via Swift Package Manager.

In Xcode: **File → Add Package Dependencies**, then enter the repository URL.

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Jay-Hell/AvatarKit", from: "1.3.0")
]
```

Then add `"AvatarKit"` to your target's dependencies.

---

## Quick Start

```swift
import AvatarKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        AvatarCompositorView(
            configuration: .defaultConfiguration
        )
    }
}
```

This renders a default avatar with medium skin tone and built-in clothing layers.

---

## Configuration

Build an `AvatarConfiguration` to control skin tone and equipped items:

```swift
let config = AvatarConfiguration(
    skinTone: .dark,
    equippedItems: [:]   // empty = all default layers
)
```

**Skin tones:** `.light`, `.medium`, `.dark`

---

## Colour Palette

Pass a `ColourPalette` to tint the default layers (hair, clothing, background):

```swift
AvatarCompositorView(
    configuration: config,
    palette: ColourPalette(
        primary: ColourPalette.from(hex: "#3B2F2F"),
        secondary: ColourPalette.from(hex: "#D6E4F0"),
        accent: ColourPalette.from(hex: "#5B9BD5")
    ),
    showShadow: true
)
```

`ColourPalette.from(hex:)` accepts 6-digit hex strings with or without a `#` prefix.

---

## Custom Layers

Replace any default layer by implementing the `AvatarLayer` protocol and adding it to `equippedItems`:

```swift
struct SunglassesLayer: AvatarLayer {
    let itemID = "sunglasses-classic"
    let layerOrder: LayerOrder = .accessory

    func renderView() -> AnyView {
        AnyView(
            Image("sunglasses-classic")
                .resizable()
                .frame(width: 200, height: 350)
        )
    }
}

let config = AvatarConfiguration(
    skinTone: .light,
    equippedItems: [.accessory: SunglassesLayer()]
)
```

When an equipped item is present for a given `LayerOrder`, it replaces that default layer entirely.

### Data-Driven Layers (JSON Shape Descriptors)

Instead of writing SwiftUI code for every item, you can define layers as JSON shape descriptors and render them at runtime with `DynamicLayerView`.

**Define a shape descriptor in JSON:**

```json
{
  "schemaVersion": 1,
  "itemId": "top-red-tshirt",
  "layerOrder": "top",
  "shapes": [
    {
      "type": "taperedRect",
      "topWidth": 60, "bottomWidth": 71, "cornerRadius": 9,
      "width": 71, "height": 61,
      "fill": { "palette": "primary" },
      "offsetY": -8
    },
    {
      "type": "roundedRectangle",
      "width": 26, "height": 40, "cornerRadius": 10,
      "fill": { "palette": "primary" },
      "offsetX": -22, "offsetY": -14,
      "rotation": 30, "rotationAnchor": "top"
    },
    {
      "type": "roundedRectangle",
      "width": 26, "height": 40, "cornerRadius": 10,
      "fill": { "palette": "primary" },
      "offsetX": 22, "offsetY": -14,
      "rotation": -30, "rotationAnchor": "top"
    }
  ]
}
```

**Render it:**

```swift
let json = /* JSON string from above */
let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: Data(json.utf8))

DynamicLayerView(
    descriptor: descriptor,
    palette: myPalette,
    skinTone: .medium
)
```

**Equip it on an avatar using `DynamicAvatarLayer`:**

```swift
let layer = try DynamicAvatarLayer(json: jsonString, palette: myPalette)

let config = AvatarConfiguration(
    skinTone: .medium,
    equippedItems: [layer.layerOrder: layer]
)
```

#### Supported shape types

| Type | Key fields |
|---|---|
| `roundedRectangle` | `width`, `height`, `cornerRadius`, `fill` |
| `circle` | `diameter`, `fill` |
| `ellipse` | `width`, `height`, `fill` |
| `taperedRect` | `topWidth`, `bottomWidth`, `cornerRadius`, `width`, `height`, `fill` |
| `quadCurve` | `startX/Y`, `endX/Y`, `controlX/Y`, `lineWidth`, `strokeColor` |

#### Fill types

| Fill | Example |
|---|---|
| Palette reference | `{ "palette": "primary" }` — resolves to the palette colour at runtime |
| Fixed hex | `{ "hex": "#FF0000" }` |
| Hex with opacity | `{ "hex": "#FF0000", "opacity": 0.5 }` |

Palette values: `"primary"`, `"secondary"`, `"accent"`, `"skin"`.

#### Common positioning fields

All shape types support optional positioning: `offsetX`, `offsetY`, `rotation`, `rotationAnchor` (`"center"`, `"top"`, `"bottom"`, `"leading"`, `"trailing"`), `opacity`, and `overlays` (nested shapes rendered on top).

#### Validation

Use `ShapeDescriptorValidator` to check a JSON descriptor for structural issues before rendering:

```swift
let errors = ShapeDescriptorValidator.validate(json: jsonData)
// errors: [ValidationError] with .path and .message
```

---

## Admin & Tooling Views

These views are designed for use in admin/editor apps to verify that generated clothing items correctly cover the underlying avatar body.

### BodySkeletonView

Renders semi-transparent red silhouettes of the body parts relevant to a given clothing category. Overlay this on a generated item to check coverage — any red showing through means the item doesn't fully cover that body part.

```swift
ZStack {
    DynamicLayerView(descriptor: myDescriptor, palette: myPalette)
        .offset(y: 17)
    BodySkeletonView(category: "top")
}
```

Categories and the body parts they show:

| Category | Skeleton shapes |
|---|---|
| `top` | Torso, left arm, right arm |
| `bottom` | Left leg, right leg, left foot, right foot |
| `shoes` | Left foot, right foot |
| `accessory` | Head, left ear, right ear |
| `expression` | Head (bounding reference) |
| `background` | None |
| `pet` | None |

### Item Templates

Pre-built minimum-coverage shape templates derived from the body measurements in `AvatarBaseView`. These define the smallest shapes an item must include to fully cover the underlying body parts.

```swift
// Render a template view
TopItemTemplate(palette: myPalette, sleeveStyle: .short)
BottomItemTemplate(palette: myPalette, style: .longTrousers)
ShoesItemTemplate(palette: myPalette)
```

**Top variants** (`SleeveStyle`):
- `.short` — covers upper arm (30pt sleeve)
- `.long` — covers full arm (59pt sleeve)

**Bottom variants** (`BottomStyle`):
- `.shortTrousers` — separate leg shapes, upper legs
- `.longTrousers` — separate leg shapes, full length to ankles
- `.shortSkirt` — single flared shape, hip to mid-thigh
- `.longSkirt` — single flared shape, hip to ankles

**Get template code for prompt embedding:**

```swift
let code = ItemTemplates.templateCode(for: "top", variant: "shortSleeve")
// Returns a SwiftUI code string with the minimum structural shapes
```

Variant strings: `"shortSleeve"`, `"longSleeve"`, `"shortTrousers"`, `"longTrousers"`, `"shortSkirt"`, `"longSkirt"`.

---

### Layer rendering order

| Layer | Raw value | Default content |
|---|---|---|
| `background` | 0 | Rounded rectangle |
| `body` | 10 | Torso, arms, head, neck, ears |
| `shoes` | 20 | Feet |
| `bottom` | 30 | Trousers |
| `top` | 40 | T-shirt |
| `accessory` | 50 | *(empty by default)* |
| `hair` | 60 | Short hair |
| `pet` | 70 | *(empty by default)* |
| `expression` | 80 | Eyes, nose, mouth |

---

## API Reference

### `AvatarCompositorView`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `configuration` | `AvatarConfiguration` | — | Skin tone and equipped items |
| `palette` | `ColourPalette` | Brown/blue defaults | Colors applied to default layers |
| `showShadow` | `Bool` | `false` | Drop shadow beneath the avatar |

The rendered view is **150 x 275 pt** (clipped canvas).

### `AvatarConfiguration`

| Property | Type | Description |
|---|---|---|
| `skinTone` | `SkinTone` | `.light`, `.medium`, or `.dark` |
| `equippedItems` | `[LayerOrder: any AvatarLayer]` | Custom layers keyed by position |

Use `.defaultConfiguration` for a ready-made medium-skin, default-layer avatar.

### `AvatarLayer` protocol

```swift
public protocol AvatarLayer {
    var itemID: String { get }
    var layerOrder: LayerOrder { get }
    func renderView() -> AnyView
}
```

### `DynamicLayerView`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `descriptor` | `ItemDescriptor` | — | Decoded JSON shape descriptor |
| `palette` | `ColourPalette` | — | Palette for resolving `"palette"` fill references |
| `skinTone` | `SkinTone` | `.medium` | Skin tone for resolving `"skin"` fill references |

Renders within a **150 x 275 pt** frame.

### `DynamicAvatarLayer`

Wraps a `DynamicLayerView` to conform to `AvatarLayer`, so JSON-defined items can be equipped via `AvatarConfiguration`.

```swift
let layer = try DynamicAvatarLayer(json: jsonString, palette: palette)
```

### `BodySkeletonView`

| Parameter | Type | Description |
|---|---|---|
| `category` | `String` | Clothing category to show skeleton for |

Renders within a **150 x 275 pt** frame with the body group offset applied.

### `ItemTemplates`

| Method | Returns |
|---|---|
| `templateCode(for:variant:)` | SwiftUI code string for the minimum structural shapes |

### `ShapeDescriptorValidator`

| Method | Returns |
|---|---|
| `validate(json:)` | `[ValidationError]` — empty if valid |
