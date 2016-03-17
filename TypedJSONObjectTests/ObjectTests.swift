import XCTest
@testable import TypedJSONObject

class ObjectTests: XCTestCase {
    class ObjectType : Object {
        var requiredAttribute: RequiredAttribute<String>!
        var optionalAttribute: OptionalAttribute<String>!
        
        override func setupAttributes() {
            self.requiredAttribute = self.requiredStringAttribute("required")
            self.optionalAttribute = self.optionalStringAttribute("optional")
        }
    }
    
    func testConversionErrorOnRead() {
        let dictionary = ["required": 123]
        
        do {
            try ObjectType.readJSON(dictionary) { object in }
        } catch JSONObjectError.ConversionFailure(key: let key, value: let value) {
            XCTAssertEqual("required", key)
            XCTAssertEqual(123, value as? Int)
        } catch {
            XCTAssert(false, "unexpected error")
        }
    }
    
    func testMissingErrorOnRead() {
        let dictionary: [String: AnyObject] = [:]
        
        do {
            try ObjectType.readJSON(dictionary) { object in }
        } catch JSONObjectError.RequiredAttributeMissing(key: let key) {
            XCTAssertEqual("required", key)
        } catch {
            XCTAssert(false, "unexpected error")
        }
    }

    func testNullOnRequiredAttributeIsTreatedAsMissing() {
        let dictionary: [String: AnyObject] = ["required": NSNull()]
        
        do {
            try ObjectType.readJSON(dictionary) { object in }
        } catch JSONObjectError.RequiredAttributeMissing(key: let key) {
            XCTAssertEqual("required", key)
        } catch {
            XCTAssert(false, "unexpected error")
        }
    }

    func testNullOnOptionalAttributeIsTreatedAsMissing() {
        let dictionary: [String: AnyObject] = ["required": "hoge", "optional": NSNull()]
        
        try! ObjectType.readJSON(dictionary) { object in
            XCTAssertNil(object.optionalAttribute.value)
        }
    }

    func testMissingErrorOnWrite() {
        do {
            try ObjectType.writeJSON { object in
                // Wirte nothing
            }
        } catch JSONObjectError.RequiredAttributeMissing(key: let key) {
            XCTAssertEqual("required", key)
        } catch {
            XCTAssert(false, "unexpected error")
        }
    }
    
    func testSkippingRequiredAttribute() {
        try! ObjectType.writeJSON { object in
            // Skip required attribute
            object.requiredAttribute.skip()
        }
    }
    
    func testReadArray() {
        let json: [AnyObject] = [["required": "first"], NSNull()]
        
        let array: [(required: String, optional: String?)?] = try! ObjectType.readJSONArray(json) { object in
            (required: object.requiredAttribute.value, optional: object.optionalAttribute.value)
        }
        
        XCTAssertEqual(2, array.count)
        
        XCTAssertEqual("first", array[0]!.required)
        XCTAssertNil(array[0]!.optional)
        
        XCTAssertNil(array[1])
    }
    
    func testReadArrayThrowsErrorIfNonObjectValueIsIncluded() {
        do {
            try ObjectType.readJSONArray([1,2,3]) { x in 123 }
        } catch JSONObjectError.ArrayContainsUnexpectedElement(_) {
            XCTAssert(true, "Throws error")
        } catch {
            XCTAssert(false, "Unexpected error")
        }
    }
    
    func testWriteArray() {
        let array = ["hello", "world"]
        
        let json = try! ObjectType.writeJSONArray(array) { (object, element) in
            object.requiredAttribute.value = element
        }
        
        XCTAssertEqual([["required": "hello"], ["required": "world"]], json)
    }
}
