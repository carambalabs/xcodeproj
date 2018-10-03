
import XCTest
@testable import xcodeproj
import AEXML

extension String {
    var cleaned: String {
        return self
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "   ", with: "")
    }
}

class AEXML_XcodeFormatTests: XCTestCase {

    private let expectedXml =
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <child
       abc = "123"
       def = "456">
    </child>
    """

    func test_elements_are_sorted_when_original_sorted() {
        validateAttributes(attributes: [
            "abc": "123",
            "def": "456",
            ])
    }

    func test_elements_are_sorted_when_original_unsorted() {
        validateAttributes(attributes: [
            "def": "456",
            "abc": "123",
        ])
    }

    func validateAttributes(attributes: [String:String], line: UInt = #line) {
        let document = AEXMLDocument()
        let child = document.addChild(name: "child")
        child.attributes = attributes
        let result = document.xmlXcodeFormat
        XCTAssertEqual(expectedXml.cleaned, result.cleaned, line: line)
    }
}
