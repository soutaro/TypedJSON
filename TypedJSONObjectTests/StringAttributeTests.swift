import XCTest
@testable import TypedJSONObject

class StringAttributeTests: XCTestCase {
    class TestObject : Object {
        var requiredAttribute: RequiredAttribute<String>!
        var requiredAttributeWithDefault: RequiredAttribute<String>!
        var optionalAttribute: OptionalAttribute<String>!
        
        override func setupAttributes() {
            self.requiredAttribute = self.requiredStringAttribute("required_attribute")
            self.requiredAttributeWithDefault = self.requiredStringAttribute("required_attribute_with_default", or: "default value")
            self.optionalAttribute = self.optionalStringAttribute("optional_attribute")
        }
    }

    func testRead() {
        let input: [String: AnyObject] = [
            "required_attribute": "Test1",
            "required_attribute_with_default": "Test2",
            "optional_attribute": "Test3"
        ]
        
        try! TestObject.readJSON(input) { object in
            XCTAssertEqual(object.requiredAttribute.value, "Test1")
            XCTAssertEqual(object.requiredAttributeWithDefault.value, "Test2")
            XCTAssertEqual(object.optionalAttribute.value, "Test3")
        }
    }
    
    func testReadMissing() {
        let input: [String: AnyObject] = [
            "required_attribute": "Test1",
        ]
        
        try! TestObject.readJSON(input) { object in
            XCTAssertEqual(object.requiredAttributeWithDefault.value, "default value")
            XCTAssertEqual(object.optionalAttribute.value, nil)
        }
    }
    
    func testWrite() {
        let output = try! TestObject.writeJSON { (object) in
            object.requiredAttribute.value = "Test1"
            object.requiredAttributeWithDefault.value = "Test2"
            object.optionalAttribute.value = "Test3"
        }
        
        XCTAssertEqual(["required_attribute": "Test1", "required_attribute_with_default": "Test2", "optional_attribute": "Test3"] as [String: AnyObject], output)
    }
}
