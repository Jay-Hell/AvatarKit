# AvatarKit

A lightweight, dependency-free SwiftUI library for rendering customizable layered avatars.

**Version:** 1.0.1 · **Platforms:** iOS 16+ · macOS 13+

---

## Installation

Add AvatarKit to your project via Swift Package Manager.

In Xcode: **File → Add Package Dependencies**, then enter the repository URL.

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/AvatarKit", from: "1.0.1")
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

The rendered view is always **200 × 350 pt**.

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
