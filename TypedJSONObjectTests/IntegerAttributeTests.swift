import XCTest
@testable import TypedJSONObject

class IntegerAttributeTests: XCTestCase {
    class TestObject: Object {
        var requiredAttribute: RequiredAttribute<Int>!
        var requiredAttributeWithDefault: RequiredAttribute<Int>!
        var optionalAttribute: OptionalAttribute<Int>!
        
        override func setupAttributes() {
            self.requiredAttribute = self.requiredIntegerAttribute("required")
            self.requiredAttributeWithDefault = self.requiredIntegerAttribute("required_with_default", or: 3)
            self.optionalAttribute = self.optionalIntegerAttribute("optional")
        }
    }

    func testRead() {
        let dictionary: [String: AnyObject] = [
            "required": 1,
            "required_with_default": 2,
            "optional": 3
        ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(1, object.requiredAttribute.value)
            XCTAssertEqual(2, object.requiredAttributeWithDefault.value)
            XCTAssertEqual(3, object.optionalAttribute.value)
        }
    }

    func testReadMissing() {
        let dictionary: [String: AnyObject] = [
            "required": 1,
        ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(3, object.requiredAttributeWithDefault.value)
            XCTAssertEqual(nil, object.optionalAttribute.value)
        }
    }
    
    func testWrite() {
        let dictionary = try! TestObject.writeJSON { object in
            object.requiredAttribute.value = 1
            object.requiredAttributeWithDefault.value = 2
            object.optionalAttribute.value = 3
        }
        
        XCTAssertEqual(["required": 1, "required_with_default": 2, "optional": 3], dictionary)
    }
}
