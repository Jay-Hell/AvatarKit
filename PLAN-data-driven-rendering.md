# Data-Driven Avatar Rendering — Implementation Plan

## Problem

AvatarAdmin generates Swift source code via the Claude API and stores it in Contentful's `generatedSwiftCode` field. The consumer iOS app fetches this string at runtime but **cannot compile Swift code** — making the entire pipeline non-functional for end users.

## Solution

Replace Swift code generation with a **JSON shape descriptor** format. AvatarKit gains a runtime renderer (`DynamicLayerView`) that interprets this JSON and renders SwiftUI views. Items become truly dynamic — fetched from Contentful and rendered without app updates.

---

## Phase 1: AvatarKit — JSON Schema Models and DynamicLayerView

**Goal**: AvatarKit gains the ability to decode JSON shape descriptors and render them. Purely additive — no existing APIs change.

### 1.1 JSON Schema Design

#### Top-level descriptor

```json
{
  "schemaVersion": 1,
  "itemId": "top_red_hoodie",
  "layerOrder": "top",
  "shapes": [ ... ]
}
```

- `schemaVersion` — integer for forward compatibility. The renderer refuses unknown versions.
- `layerOrder` — string matching `LayerOrder` case names.
- `shapes` — ordered array rendered back-to-front in a ZStack (first = backmost).

#### Shape object

Each entry in `shapes` has a `type` discriminator:

```json
{
  "type": "roundedRectangle",
  "width": 65,
  "height": 57,
  "cornerRadius": 9,
  "fill": { "palette": "primary" },
  "offsetX": 0,
  "offsetY": -8,
  "rotation": 0,
  "rotationAnchor": "center",
  "opacity": 1.0,
  "overlays": []
}
```

**Supported types:**

| type | Required fields | Maps to |
|---|---|---|
| `roundedRectangle` | `width`, `height`, `cornerRadius` | `RoundedRectangle` |
| `circle` | `diameter` | `Circle()` |
| `ellipse` | `width`, `height` | `Ellipse()` |
| `taperedRect` | `topWidth`, `bottomWidth`, `cornerRadius`, `width`, `height` | `TaperedRect` |
| `quadCurve` | `startX`, `startY`, `endX`, `endY`, `controlX`, `controlY`, `lineWidth`, `strokeColor` | `Path` with `addQuadCurve` |

**Common optional fields (all types):**

| Field | Type | Default |
|---|---|---|
| `offsetX` | CGFloat | 0 |
| `offsetY` | CGFloat | 0 |
| `rotation` | Double (degrees) | 0 |
| `rotationAnchor` | String | `"center"` |
| `opacity` | Double | 1.0 |
| `overlays` | [Shape] | [] |

**Fill color model:**

```json
{ "palette": "primary" }
{ "palette": "secondary" }
{ "palette": "accent" }
{ "palette": "skin" }
{ "hex": "#3D2B1F" }
{ "hex": "#FF9999", "opacity": 0.4 }
```

Palette references resolve at render time from `ColourPalette`/`SkinTone`, so the same item re-colors when a user changes their avatar theme.

### 1.2 New files to create

All in `/Sources/AvatarKit/`:

**`ShapeDescriptor.swift`** — Codable models:
- `ItemDescriptor` — top-level: schemaVersion, itemId, layerOrder, shapes
- `ShapeDescriptor` — enum-backed on `type` with associated data per shape
- `FillColor` — enum: `.palette(String)` or `.hex(String, opacity: Double?)`
- `RotationAnchor` — enum mapping string names to `UnitPoint`

**`DynamicLayerView.swift`** — SwiftUI view that:
- Takes `ItemDescriptor`, `ColourPalette`, `SkinTone`
- Renders a ZStack iterating shapes
- Resolves palette colors at render time
- Handles all shape types and modifiers

**`DynamicAvatarLayer.swift`** — Conforms to `AvatarLayer` protocol:
- Wraps `DynamicLayerView` in `renderView() -> AnyView`
- Factory method: `static func from(json: Data, palette: ColourPalette, skinTone: SkinTone) throws -> DynamicAvatarLayer`

**`ShapeDescriptorValidator.swift`** — Pure validation:
- Checks schemaVersion is supported
- Validates layerOrder maps to a valid case
- Validates required fields per shape type
- Validates color references
- Returns `[ValidationError]`

### 1.3 Files to modify

**`AvatarBaseView.swift`** — Make `TaperedRect` public (currently internal). The JSON renderer needs to reference it.

**`LayerOrder.swift`** — Add `init?(string: String)` to map layer order names to enum cases.

### 1.4 Tests

- JSON decoding round-trip for `ItemDescriptor`
- `ShapeDescriptorValidator` with valid and invalid inputs
- `LayerOrder(string:)` mapping
- `DynamicAvatarLayer` construction from sample JSON

### 1.5 Version

Tag AvatarKit **1.2.0** after Phase 1 is complete.

---

## Phase 2: AvatarAdmin — Switch Generation to JSON

**Goal**: Claude generates JSON instead of Swift code. The admin app validates, previews, and stores JSON descriptors.

### 2.1 Contentful CMS changes (manual)

- Add field `shapeDescriptorJSON` (long text) to the avatarItem content type
- Keep `generatedSwiftCode` during transition — stop writing to it

### 2.2 Files to modify

**`AvatarItemGenerator.swift`** — Prompt rewrite:
- Change from "Generate a SwiftUI View..." to "Generate a JSON shape descriptor..."
- Include the JSON schema specification in the prompt
- Keep body reference geometry and anchor zones (still needed for placement)
- Keep style rules (chunky shapes, min corner radius, etc.)
- Tell Claude to output only valid JSON, no markdown fences
- Rename `parseCode` to `parseJSON`, add JSON validation via `JSONSerialization`
- Method signature `generate(for:) -> String` stays the same (now returns JSON string)

**`AvatarItem.swift`** — Model changes:
- Add field `shapeDescriptorJSON: String?`
- Add computed property `hasShapeDescriptor: Bool`
- Update `ManagementEntry.toAvatarItem()` to read `fields["shapeDescriptorJSON"]`
- Keep `generatedSwiftCode` for backward compatibility

**`ContentfulManagementService.swift`** — Storage:
- Add `saveShapeDescriptor(_:for:)` method (writes to `shapeDescriptorJSON`)
- Keep `saveGeneratedCode` during transition

**`GenerationReviewView.swift`** — Preview and approval:
- Preview tab: render `DynamicLayerView` from decoded JSON instead of `ItemOverlayCanvas`
- Code tab: show pretty-printed JSON with JSON-appropriate syntax highlighting
- Add validation banner via `ShapeDescriptorValidator`
- `approve()` calls `saveShapeDescriptor` instead of `saveGeneratedCode`

**`CatalogueManagerView.swift`** — Grid/list previews:
- `ItemOverlayCanvas`: check `item.shapeDescriptorJSON` first
  - If present: decode and render `DynamicLayerView`
  - If absent: fall back to existing Canvas placeholder

**`GenerationDetailView.swift`** — Item detail:
- Show JSON from `shapeDescriptorJSON` instead of `generatedSwiftCode`
- Avatar preview uses `DynamicLayerView` when JSON is available

**`GenerationQueueView.swift`** — Queue management:
- Clear `shapeDescriptorJSON` instead of `generatedSwiftCode` when resetting items

**`ItemCodeLoader.swift`** — Cache:
- Update to cache `.json` files instead of `.swift` files
- Rename methods accordingly

### 2.3 Dependency update

Update AvatarAdmin's `Package.resolved` to pull AvatarKit 1.2.0.

---

## Phase 3: Consumer App Integration

**Goal**: Ensure the public API supports the consumer app pattern.

The consumer app usage pattern:

```swift
// Fetch JSON string from Contentful Delivery API
let jsonString = contentfulEntry.fields.shapeDescriptorJSON

// Create a DynamicAvatarLayer
let layer = try DynamicAvatarLayer.from(
    json: jsonString.data(using: .utf8)!,
    palette: userPalette,
    skinTone: userSkinTone
)

// Equip on avatar
var config = AvatarConfiguration(skinTone: .medium)
config.equippedItems[layer.layerOrder] = layer

// Render
AvatarCompositorView(configuration: config, palette: palette)
```

### Files to consider

- Add convenience initializer on `AvatarConfiguration` that takes `[Data]` (array of JSON blobs) and builds the equipped items dictionary
- Doc comments on `DynamicAvatarLayer` showing usage

---

## Phase 4: Migration and Cleanup

**Goal**: Migrate existing items and remove legacy code.

### Migration strategy

1. Both fields coexist during transition
2. Add batch migration action in AvatarAdmin: for items with `generationStatus == "complete"` and no `shapeDescriptorJSON`, set status to `"pending"` to queue for regeneration
3. After all items regenerated with JSON, remove `generatedSwiftCode` from Contentful content type
4. Remove `generatedSwiftCode` from `AvatarItem` model
5. Remove old `saveGeneratedCode` method
6. Remove/rename `ItemCodeLoader` if fully replaced

---

## Implementation Sequence

```
Phase 1A: ShapeDescriptor.swift (Codable models)
    |
Phase 1B: TaperedRect public + LayerOrder(string:) init
    |
Phase 1C: DynamicLayerView.swift
    |
Phase 1D: DynamicAvatarLayer.swift
    |
Phase 1E: ShapeDescriptorValidator.swift
    |
Phase 1F: Tests
    |
Phase 1G: Tag AvatarKit 1.2.0
    |
    +--- Phase 2A: Update AvatarAdmin dependency to 1.2.0
    |
    +--- Phase 2B: AvatarItemGenerator prompt rewrite
    |
    +--- Phase 2C: AvatarItem model + ContentfulManagementService
    |       |
    +--- Phase 2D: GenerationReviewView + GenerationDetailView
    |       |
    +--- Phase 2E: CatalogueManagerView (ItemOverlayCanvas)
    |       |
    +--- Phase 2F: GenerationQueueView + ItemCodeLoader
    |
Phase 3: Consumer app APIs + docs
    |
Phase 4: Migration + cleanup
```

Phase 2C (model changes) must come before 2D-2F (views depend on new model field).

---

## Design Decisions

| Decision | Rationale |
|---|---|
| Schema lives in AvatarKit, not AvatarAdmin | Consumer app also needs to decode/validate. Avoids duplication. AvatarKit stays dependency-free (just Codable structs). |
| Palette references + hex literals | Palette refs let items re-color with theme changes. Hex for fixed elements (eye color, universal details). |
| Flat shapes array, not nested groups | Simpler to generate, validate, render. `overlays` handle compound shapes (e.g. eye highlight dot). |
| `quadCurve` only, no generic SVG paths | Covers the only Path usage (smile). Full SVG paths are hard to validate and easy for Claude to generate incorrectly. Add in schema v2 if needed. |
| `schemaVersion` field | Forward compatibility. Renderer shows "please update" placeholder for unknown versions. |
| Keep `generatedSwiftCode` during transition | Non-breaking migration. Both fields coexist. Old field removed in Phase 4. |

---

## Risk Areas

| Risk | Mitigation |
|---|---|
| Claude generates malformed JSON | Explicit schema in prompt. `parseJSON` validates with `JSONSerialization`. `ShapeDescriptorValidator` catches structural issues before save. Review screen shows errors. |
| Schema evolution after consumer apps ship | `schemaVersion` is the escape hatch. Renderer shows placeholder for unknown versions. |
| TaperedRect made public | Acceptable — it's a genuinely useful shape for the avatar system and the JSON schema explicitly references it. |
| Contentful field size | Long text supports 50,000 chars. Typical descriptor is 2-4KB. No concern. |
| Performance | Decoding JSON + building views for ~10-15 shapes per layer is negligible. |
