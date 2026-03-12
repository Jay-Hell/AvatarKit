import XCTest
@testable import AvatarKit

final class ItemDescriptorDecodingTests: XCTestCase {

    static let sampleJSON = """
    {
        "schemaVersion": 1,
        "itemId": "top_red_tshirt",
        "layerOrder": "top",
        "shapes": [
            {
                "type": "taperedRect",
                "topWidth": 54,
                "bottomWidth": 65,
                "cornerRadius": 9,
                "width": 65,
                "height": 57,
                "fill": { "palette": "primary" },
                "offsetY": -8
            },
            {
                "type": "roundedRectangle",
                "width": 12,
                "height": 10,
                "cornerRadius": 4,
                "fill": { "palette": "accent" },
                "offsetX": -18,
                "offsetY": -36
            }
        ]
    }
    """

    func testDecodesTopLevel() throws {
        let data = Data(Self.sampleJSON.utf8)
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: data)

        XCTAssertEqual(descriptor.schemaVersion, 1)
        XCTAssertEqual(descriptor.itemId, "top_red_tshirt")
        XCTAssertEqual(descriptor.layerOrder, "top")
        XCTAssertEqual(descriptor.shapes.count, 2)
    }

    func testDecodesShapeTypes() throws {
        let data = Data(Self.sampleJSON.utf8)
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: data)

        if case .taperedRect(let d) = descriptor.shapes[0] {
            XCTAssertEqual(d.topWidth, 54)
            XCTAssertEqual(d.bottomWidth, 65)
            XCTAssertEqual(d.common.offsetY, -8)
        } else {
            XCTFail("Expected taperedRect")
        }

        if case .roundedRectangle(let d) = descriptor.shapes[1] {
            XCTAssertEqual(d.width, 12)
            XCTAssertEqual(d.cornerRadius, 4)
            XCTAssertEqual(d.common.offsetX, -18)
        } else {
            XCTFail("Expected roundedRectangle")
        }
    }

    func testDecodesHexFill() throws {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "test",
            "layerOrder": "expression",
            "shapes": [{
                "type": "circle",
                "diameter": 8,
                "fill": { "hex": "#3D2B1F" }
            }]
        }
        """
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: Data(json.utf8))

        if case .circle(let d) = descriptor.shapes[0],
           case .hex(let hex, let opacity) = d.fill {
            XCTAssertEqual(hex, "#3D2B1F")
            XCTAssertEqual(opacity, 1.0)
        } else {
            XCTFail("Expected circle with hex fill")
        }
    }

    func testDecodesHexFillWithOpacity() throws {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "test",
            "layerOrder": "expression",
            "shapes": [{
                "type": "ellipse",
                "width": 14,
                "height": 8,
                "fill": { "hex": "#FF9999", "opacity": 0.4 }
            }]
        }
        """
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: Data(json.utf8))

        if case .ellipse(let d) = descriptor.shapes[0],
           case .hex(_, let opacity) = d.fill {
            XCTAssertEqual(opacity, 0.4)
        } else {
            XCTFail("Expected ellipse with hex fill and opacity")
        }
    }

    func testCommonFieldDefaults() throws {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "test",
            "layerOrder": "top",
            "shapes": [{
                "type": "circle",
                "diameter": 20,
                "fill": { "palette": "primary" }
            }]
        }
        """
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: Data(json.utf8))
        let common = descriptor.shapes[0].common

        XCTAssertEqual(common.offsetX, 0)
        XCTAssertEqual(common.offsetY, 0)
        XCTAssertEqual(common.rotation, 0)
        XCTAssertEqual(common.rotationAnchor, .center)
        XCTAssertEqual(common.opacity, 1.0)
        XCTAssertTrue(common.overlays.isEmpty)
    }

    func testDecodesRotationAnchor() throws {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "test",
            "layerOrder": "body",
            "shapes": [{
                "type": "roundedRectangle",
                "width": 20,
                "height": 55,
                "cornerRadius": 8,
                "fill": { "palette": "skin" },
                "rotation": 30,
                "rotationAnchor": "top"
            }]
        }
        """
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: Data(json.utf8))
        let common = descriptor.shapes[0].common

        XCTAssertEqual(common.rotation, 30)
        XCTAssertEqual(common.rotationAnchor, .top)
    }

    func testDecodesOverlays() throws {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "test",
            "layerOrder": "expression",
            "shapes": [{
                "type": "circle",
                "diameter": 8,
                "fill": { "hex": "#3D2B1F" },
                "overlays": [{
                    "type": "circle",
                    "diameter": 3,
                    "fill": { "hex": "#FFFFFF" },
                    "offsetX": 2,
                    "offsetY": -2
                }]
            }]
        }
        """
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: Data(json.utf8))
        let overlays = descriptor.shapes[0].common.overlays

        XCTAssertEqual(overlays.count, 1)
        if case .circle(let d) = overlays[0] {
            XCTAssertEqual(d.diameter, 3)
            XCTAssertEqual(d.common.offsetX, 2)
        } else {
            XCTFail("Expected circle overlay")
        }
    }

    func testDecodesQuadCurve() throws {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "test",
            "layerOrder": "expression",
            "shapes": [{
                "type": "quadCurve",
                "startX": 66,
                "startY": 74.5,
                "endX": 84,
                "endY": 74.5,
                "controlX": 75,
                "controlY": 80.5,
                "lineWidth": 1.5,
                "strokeColor": { "hex": "#3D2B1F" }
            }]
        }
        """
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: Data(json.utf8))

        if case .quadCurve(let d) = descriptor.shapes[0] {
            XCTAssertEqual(d.startX, 66)
            XCTAssertEqual(d.controlY, 80.5)
            XCTAssertEqual(d.lineWidth, 1.5)
        } else {
            XCTFail("Expected quadCurve")
        }
    }

    func testRoundTripEncoding() throws {
        let data = Data(Self.sampleJSON.utf8)
        let original = try JSONDecoder().decode(ItemDescriptor.self, from: data)
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ItemDescriptor.self, from: encoded)

        XCTAssertEqual(decoded.schemaVersion, original.schemaVersion)
        XCTAssertEqual(decoded.itemId, original.itemId)
        XCTAssertEqual(decoded.layerOrder, original.layerOrder)
        XCTAssertEqual(decoded.shapes.count, original.shapes.count)
    }
}

// MARK: - LayerOrder String Init

final class LayerOrderStringTests: XCTestCase {

    func testValidNames() {
        let cases: [(String, LayerOrder)] = [
            ("background", .background), ("body", .body), ("shoes", .shoes),
            ("bottom", .bottom), ("top", .top), ("accessory", .accessory),
            ("hair", .hair), ("pet", .pet), ("expression", .expression)
        ]
        for (name, expected) in cases {
            XCTAssertEqual(LayerOrder(string: name), expected)
        }
    }

    func testInvalidName() {
        XCTAssertNil(LayerOrder(string: "invalid"))
        XCTAssertNil(LayerOrder(string: ""))
        XCTAssertNil(LayerOrder(string: "Top"))
    }

    func testNameRoundTrip() {
        for order in LayerOrder.allCases {
            XCTAssertEqual(LayerOrder(string: order.name), order)
        }
    }
}

// MARK: - Validator

final class ValidatorTests: XCTestCase {

    func testValidDescriptor() {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "top_tshirt",
            "layerOrder": "top",
            "shapes": [{
                "type": "roundedRectangle",
                "width": 65,
                "height": 57,
                "cornerRadius": 9,
                "fill": { "palette": "primary" }
            }]
        }
        """
        let errors = ShapeDescriptorValidator.validate(json: Data(json.utf8))
        XCTAssertTrue(errors.isEmpty, "Expected no errors, got: \(errors)")
    }

    func testInvalidSchemaVersion() {
        let descriptor = ItemDescriptor(schemaVersion: 99, itemId: "test", layerOrder: "top", shapes: [
            .roundedRectangle(.init(width: 10, height: 10, cornerRadius: 4, fill: .palette("primary")))
        ])
        let errors = ShapeDescriptorValidator.validate(descriptor)
        XCTAssertTrue(errors.contains { $0.path == "schemaVersion" })
    }

    func testEmptyItemId() {
        let descriptor = ItemDescriptor(itemId: "", layerOrder: "top", shapes: [
            .circle(.init(diameter: 10, fill: .palette("primary")))
        ])
        let errors = ShapeDescriptorValidator.validate(descriptor)
        XCTAssertTrue(errors.contains { $0.path == "itemId" })
    }

    func testInvalidLayerOrder() {
        let descriptor = ItemDescriptor(itemId: "test", layerOrder: "invalid", shapes: [
            .circle(.init(diameter: 10, fill: .palette("primary")))
        ])
        let errors = ShapeDescriptorValidator.validate(descriptor)
        XCTAssertTrue(errors.contains { $0.path == "layerOrder" })
    }

    func testEmptyShapes() {
        let descriptor = ItemDescriptor(itemId: "test", layerOrder: "top", shapes: [])
        let errors = ShapeDescriptorValidator.validate(descriptor)
        XCTAssertTrue(errors.contains { $0.path == "shapes" })
    }

    func testNegativeWidth() {
        let descriptor = ItemDescriptor(itemId: "test", layerOrder: "top", shapes: [
            .roundedRectangle(.init(width: -10, height: 10, cornerRadius: 4, fill: .palette("primary")))
        ])
        let errors = ShapeDescriptorValidator.validate(descriptor)
        XCTAssertTrue(errors.contains { $0.path == "shapes[0].width" })
    }

    func testInvalidPaletteName() {
        let descriptor = ItemDescriptor(itemId: "test", layerOrder: "top", shapes: [
            .circle(.init(diameter: 10, fill: .palette("invalid")))
        ])
        let errors = ShapeDescriptorValidator.validate(descriptor)
        XCTAssertTrue(errors.contains { $0.path == "shapes[0].fill" })
    }

    func testInvalidHexColor() {
        let descriptor = ItemDescriptor(itemId: "test", layerOrder: "top", shapes: [
            .circle(.init(diameter: 10, fill: .hex("not-a-color", opacity: 1.0)))
        ])
        let errors = ShapeDescriptorValidator.validate(descriptor)
        XCTAssertTrue(errors.contains { $0.path == "shapes[0].fill" })
    }

    func testInvalidJSON() {
        let errors = ShapeDescriptorValidator.validate(json: Data("not json".utf8))
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].path, "root")
    }
}

// MARK: - DynamicAvatarLayer

final class DynamicAvatarLayerTests: XCTestCase {

    private var testPalette: ColourPalette {
        ColourPalette(
            primary: ColourPalette.from(hex: "#FF0000"),
            secondary: ColourPalette.from(hex: "#CC0000"),
            accent: ColourPalette.from(hex: "#FF6666")
        )
    }

    func testCreatesFromJSON() throws {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "top_tshirt",
            "layerOrder": "top",
            "shapes": [{
                "type": "roundedRectangle",
                "width": 65,
                "height": 57,
                "cornerRadius": 9,
                "fill": { "palette": "primary" }
            }]
        }
        """
        let layer = try DynamicAvatarLayer.from(
            json: Data(json.utf8),
            palette: testPalette,
            skinTone: .medium
        )

        XCTAssertEqual(layer.itemID, "top_tshirt")
        XCTAssertEqual(layer.layerOrder, .top)
    }

    func testRejectsUnsupportedVersion() {
        let json = """
        {
            "schemaVersion": 99,
            "itemId": "test",
            "layerOrder": "top",
            "shapes": [{ "type": "circle", "diameter": 10, "fill": { "palette": "primary" } }]
        }
        """
        XCTAssertThrowsError(
            try DynamicAvatarLayer.from(json: Data(json.utf8), palette: testPalette, skinTone: .medium)
        )
    }

    func testRejectsInvalidLayerOrder() {
        let json = """
        {
            "schemaVersion": 1,
            "itemId": "test",
            "layerOrder": "invalid",
            "shapes": [{ "type": "circle", "diameter": 10, "fill": { "palette": "primary" } }]
        }
        """
        XCTAssertThrowsError(
            try DynamicAvatarLayer.from(json: Data(json.utf8), palette: testPalette, skinTone: .medium)
        )
    }
}
