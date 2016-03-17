import XCTest
@testable import TypedJSONObject

class ArrayAttributeTests: XCTestCase {
    class TestObject: Object {
        var requiredAttribute: RequiredAttribute<[AnyObject]>!
        var requiredAttributeWithDefault: RequiredAttribute<[AnyObject]>!
        var optionalAttribute: OptionalAttribute<[AnyObject]>!
        
        override func setupAttributes() {
            self.requiredAttribute = self.requiredArrayAttribute("required")
            self.requiredAttributeWithDefault = self.requiredArrayAttribute("required_with_default", or: ["hello"])
            self.optionalAttribute = self.optionalArrayAttribute("optional")
        }
    }
    
    func testRead() {
        let dictionary: [String: AnyObject] = [
            "required": [1],
            "required_with_default": [2],
            "optional": [3]
        ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual([1], object.requiredAttribute.value)
            XCTAssertEqual([2], object.requiredAttributeWithDefault.value)
            XCTAssertEqual([3], object.optionalAttribute.value!)
        }
    }
    
    func testReadMissing() {
        let dictionary: [String: AnyObject] = [
            "required": [1],
            ]
        
        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(["hello"], object.requiredAttributeWithDefault.value)
            XCTAssertNil(object.optionalAttribute.value)
        }
    }
    
    func testWrite() {
        let dictionary = try! TestObject.writeJSON { object in
            object.requiredAttribute.value = ["a"]
            object.requiredAttributeWithDefault.value = ["b"]
            object.optionalAttribute.value = ["c"]
        }
        
        XCTAssertEqual(["required": ["a"], "required_with_default": ["b"], "optional": ["c"]], dictionary)
    }
}
