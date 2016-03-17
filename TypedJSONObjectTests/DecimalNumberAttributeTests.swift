import XCTest
@testable import TypedJSONObject

class DecimalNumberAttributeTests: XCTestCase {
    class TestObject: Object {
        var requiredAttribute: RequiredAttribute<NSDecimalNumber>!
        var requiredAttributeWithDefault: RequiredAttribute<NSDecimalNumber>!
        var optionalAttribute: OptionalAttribute<NSDecimalNumber>!
        
        override func setupAttributes() {
            self.requiredAttribute = self.requiredDecimalNumberAttribute("required")
            self.requiredAttributeWithDefault = self.requiredDecimalNumberAttribute("required_with_default", or: NSDecimalNumber(string: "0.1"))
            self.optionalAttribute = self.optionalDecimalNumberAttribute("optional")
        }
    }
    
    func testRead() {
        let dictionary: [String: AnyObject] = [
            "required": "100",
            "required_with_default": 15.97,
            "optional": 200
        ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(NSDecimalNumber(string: "100"), object.requiredAttribute.value)
            XCTAssertEqual(NSDecimalNumber(string: "15.97"), object.requiredAttributeWithDefault.value)
            XCTAssertEqual(NSDecimalNumber(string: "200"), object.optionalAttribute.value)
        }
    }
    
    func testReadMissing() {
        let dictionary: [String: AnyObject] = [
            "required": 1,
            ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(NSDecimalNumber(string: "0.1"), object.requiredAttributeWithDefault.value)
            XCTAssertEqual(nil, object.optionalAttribute.value)
        }
    }
    
    func testWrite() {
        let dictionary = try! TestObject.writeJSON { object in
            object.requiredAttribute.value = NSDecimalNumber(string: "200")
            object.requiredAttributeWithDefault.value = NSDecimalNumber(string: "300")
            object.optionalAttribute.value = NSDecimalNumber(string: "400")
        }
        
        XCTAssertEqual(["required": "200", "required_with_default": "300", "optional": "400"], dictionary)
    }
}
