import XCTest
@testable import TypedJSONObject

class BooleanAttributeTests: XCTestCase {
    class TestObject: Object {
        var requiredAttribute: RequiredAttribute<Bool>!
        var requiredAttributeWithDefault: RequiredAttribute<Bool>!
        var optionalAttribute: OptionalAttribute<Bool>!
        
        override func setupAttributes() {
            self.requiredAttribute = self.requiredBooleanAttribute("required")
            self.requiredAttributeWithDefault = self.requiredBooleanAttribute("required_with_default", or: true)
            self.optionalAttribute = self.optionalBooleanAttribute("optional")
        }
    }
    
    func testRead() {
        let dictionary: [String: AnyObject] = [
            "required": true,
            "required_with_default": false,
            "optional": true
        ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(true, object.requiredAttribute.value)
            XCTAssertEqual(false, object.requiredAttributeWithDefault.value)
            XCTAssertEqual(true, object.optionalAttribute.value)
        }
    }
    
    func testReadMissing() {
        let dictionary: [String: AnyObject] = [
            "required": true,
            ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(true, object.requiredAttributeWithDefault.value)
            XCTAssertEqual(nil, object.optionalAttribute.value)
        }
    }
    
    func testWrite() {
        let dictionary = try! TestObject.writeJSON { object in
            object.requiredAttribute.value = true
            object.requiredAttributeWithDefault.value = true
            object.optionalAttribute.value = true
        }
        
        XCTAssertEqual(["required": true, "required_with_default": true, "optional": true], dictionary)
    }
}
