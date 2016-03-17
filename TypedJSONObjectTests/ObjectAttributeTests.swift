import XCTest
@testable import TypedJSONObject

class ObjectAttributeTests: XCTestCase {
    class TestObject: Object {
        var requiredAttribute: RequiredAttribute<[String: AnyObject]>!
        var requiredAttributeWithDefault: RequiredAttribute<[String: AnyObject]>!
        var optionalAttribute: OptionalAttribute<[String: AnyObject]>!
        
        override func setupAttributes() {
            self.requiredAttribute = self.requiredObjectAttribute("required")
            self.requiredAttributeWithDefault = self.requiredObjectAttribute("required_with_default", or: ["key": "value"])
            self.optionalAttribute = self.optionalObjectAttribute("optional")
        }
    }
    
    func testRead() {
        let dictionary: [String: AnyObject] = [
            "required": ["key": 1],
            "required_with_default": ["key": 2],
            "optional": ["key": 3]
        ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(["key": 1], object.requiredAttribute.value)
            XCTAssertEqual(["key": 2], object.requiredAttributeWithDefault.value)
            XCTAssertEqual(["key": 3], object.optionalAttribute.value!)
        }
    }
    
    func testReadMissing() {
        let dictionary: [String: AnyObject] = [
            "required": [:],
            ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(["key": "value"], object.requiredAttributeWithDefault.value)
            XCTAssertNil(object.optionalAttribute.value)
        }
    }
    
    func testWrite() {
        let dictionary = try! TestObject.writeJSON { object in
            object.requiredAttribute.value = ["key": 1]
            object.requiredAttributeWithDefault.value = ["key": 2]
            object.optionalAttribute.value = ["key": 3]
        }
        
        XCTAssertEqual(["required": ["key": 1], "required_with_default": ["key": 2], "optional": ["key": 3]], dictionary)
    }
}
