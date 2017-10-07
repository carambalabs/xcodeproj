import Foundation
import XCTest
import xcproj

final class PBXVariantGroupSpec: XCTestCase {

    var subject: PBXVariantGroup!

    override func setUp() {
        super.setUp()
        self.subject = PBXVariantGroup(reference: "reference",
                                       children: ["child"],
                                       name: "name",
                                       sourceTree: .group)
    }

    func test_init_initializesTheModelWithTheCorrectAttributes() {
        XCTAssertEqual(subject.reference, "reference")
        XCTAssertEqual(subject.children, ["child"])
        XCTAssertEqual(subject.name, "name")
        XCTAssertEqual(subject.sourceTree, .group)
    }

    func test_init_setsTheCorrectDefaultValue_whenChildrenIsMissing() throws {
        var dictionary = testDictionary()
        dictionary.removeValue(forKey: "children")
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        let decoder = JSONDecoder()
        let subject = try decoder.decode(PBXVariantGroup.self, from: data)
        XCTAssertEqual(subject.children, [])
    }

    func test_init_setsTheCorrectDefaultValue_whenNameIsMissing() throws {
        var dictionary = testDictionary()
        dictionary.removeValue(forKey: "name")
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        let decoder = JSONDecoder()
        let subject = try decoder.decode(PBXVariantGroup.self, from: data)
        XCTAssertEqual(subject.name, "")
    }

    func test_init_setsTheCorrectDefaultValue_whenSourceTreeIsMissing() throws {
        var dictionary = testDictionary()
        dictionary.removeValue(forKey: "sourceTree")
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        let decoder = JSONDecoder()
        let subject = try decoder.decode(PBXVariantGroup.self, from: data)
        XCTAssertEqual(subject.sourceTree, .none)
    }

    func test_init_failsIfTheSourceTreeIsWrong() {
        var dictionary = testDictionary()
        dictionary["sourceTree"] = "asdgasdgas"
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode(PBXVariantGroup.self, from: data)
            XCTAssertTrue(false, "Expected to throw an error but it didn't")
        } catch {}
    }

    func test_itHasTheCorrectIsa() {
        XCTAssertEqual(PBXVariantGroup.isa, "PBXVariantGroup")
    }

    func test_equals_returnsTheCorrectValue() {
        let one = PBXVariantGroup(reference: "reference", children: ["a"], name: "name", sourceTree: .group)
        let another = PBXVariantGroup(reference: "reference", children: ["a"], name: "name", sourceTree: .group)
        XCTAssertEqual(one, another)
    }

    func test_hashValue_returnsTheReferenceHasValue() {
        XCTAssertEqual(subject.hashValue, subject.reference.hashValue)
    }

    private func testDictionary() -> [String: Any] {
        return [
            "children": ["child1", "child2"],
            "name": "name",
            "sourceTree": "SDKROOT",
            "reference": "reference"
        ]
    }

}
