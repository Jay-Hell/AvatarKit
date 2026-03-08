import XCTest
@testable import AvatarKit

final class LayerOrderTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(LayerOrder.background.rawValue, 0)
        XCTAssertEqual(LayerOrder.body.rawValue, 10)
        XCTAssertEqual(LayerOrder.shoes.rawValue, 20)
        XCTAssertEqual(LayerOrder.bottom.rawValue, 30)
        XCTAssertEqual(LayerOrder.top.rawValue, 40)
        XCTAssertEqual(LayerOrder.accessory.rawValue, 50)
        XCTAssertEqual(LayerOrder.hair.rawValue, 60)
        XCTAssertEqual(LayerOrder.pet.rawValue, 70)
        XCTAssertEqual(LayerOrder.expression.rawValue, 80)
    }

    func testLayerOrderComparable() {
        XCTAssertTrue(LayerOrder.background < LayerOrder.body)
        XCTAssertTrue(LayerOrder.hair < LayerOrder.expression)
    }

    func testAllCasesCount() {
        XCTAssertEqual(LayerOrder.allCases.count, 9)
    }
}

final class AvatarConfigurationTests: XCTestCase {
    func testDefaultConfigurationSkinTone() {
        let config = AvatarConfiguration.defaultConfiguration
        XCTAssertEqual(config.skinTone, .medium)
    }

    func testDefaultConfigurationEquippedItemsEmpty() {
        let config = AvatarConfiguration.defaultConfiguration
        XCTAssertTrue(config.equippedItems.isEmpty)
    }

    func testCustomConfiguration() {
        let config = AvatarConfiguration(skinTone: .dark)
        XCTAssertEqual(config.skinTone, .dark)
        XCTAssertTrue(config.equippedItems.isEmpty)
    }
}
