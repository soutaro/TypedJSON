import XCTest
@testable import TypedJSONObject

class DoubleAttributeTests: XCTestCase {
    class TestObject: Object {
        var requiredAttribute: RequiredAttribute<Double>!
        var requiredAttributeWithDefault: RequiredAttribute<Double>!
        var optionalAttribute: OptionalAttribute<Double>!
        
        override func setupAttributes() {
            self.requiredAttribute = self.requiredFloatAttribute("required")
            self.requiredAttributeWithDefault = self.requiredFloatAttribute("required_with_default", or: 3.14)
            self.optionalAttribute = self.optionalFloatAttribute("optional")
        }
    }
    
    func testRead() {
        let dictionary: [String: AnyObject] = [
            "required": 1.3,
            "required_with_default": 2.1,
            "optional": 3.5
        ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(1.3, object.requiredAttribute.value)
            XCTAssertEqual(2.1, object.requiredAttributeWithDefault.value)
            XCTAssertEqual(3.5, object.optionalAttribute.value)
        }
    }
    
    func testReadMissing() {
        let dictionary: [String: AnyObject] = [
            "required": 1,
            ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(3.14, object.requiredAttributeWithDefault.value)
            XCTAssertEqual(nil, object.optionalAttribute.value)
        }
    }
    
    func testWrite() {
        let dictionary = try! TestObject.writeJSON { object in
            object.requiredAttribute.value = 1.5
            object.requiredAttributeWithDefault.value = 2.2
            object.optionalAttribute.value = 3.111
        }
        
        XCTAssertEqual(["required": 1.5, "required_with_default": 2.2, "optional": 3.111], dictionary)
    }
}
