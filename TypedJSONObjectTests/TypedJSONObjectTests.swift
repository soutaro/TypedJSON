import XCTest
import TypedJSONObject

class TypedJSONObjectTests: XCTestCase {
    class TestObject : Object {
        var id: RequiredAttribute<Int>!
        var name: RequiredAttribute<String>!
        var phone: OptionalAttribute<String>!
        
        override func setupAttributes() {
            self.id = self.requiredIntegerAttribute("id")
            self.name = self.requiredStringAttribute("name", or: "Json Fried")
            self.phone = self.optionalStringAttribute("phone")
        }
    }
    
    func testReadExample() {
        let dictionary = [ "id": 3 as AnyObject, "name": "soutaro" as AnyObject ]

        try! TestObject.readJSON(dictionary) { object in
            XCTAssertEqual(3, object.id.value)
            XCTAssertEqual("soutaro", object.name.value)
            XCTAssertNil(object.phone.value)
        }
    }
    
    func testWriteExample() {
        let dictionary = try! TestObject.writeJSON { object in
            object.id.value = 1234
            object.name.value = "soutaro"
            object.phone.value = "1234-5678"
        }
        
        XCTAssertEqual(1234, dictionary["id"] as? Int)
        XCTAssertEqual("soutaro", dictionary["name"] as? String)
        XCTAssertEqual("1234-5678", dictionary["phone"] as? String)
    }
}
