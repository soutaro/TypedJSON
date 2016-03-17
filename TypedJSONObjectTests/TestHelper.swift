import Foundation
import XCTest

func XCTAssertEqual(dictionary1: [String: AnyObject], _ dictionary2: [String: AnyObject]) {
    XCTAssertEqual(Array(dictionary1.keys), Array(dictionary2.keys))
    
    for key in dictionary1.keys {
        let value1 = dictionary1[key]!
        let value2 = dictionary2[key]!
        
        XCTAssert(value1.isEqual(value2), "@\(key):: \(value1) is not equal to \(value2)")
    }
}

func XCTAssertEqual(array1: [AnyObject], _ array2: [AnyObject]) {
    XCTAssertEqual(array1.count, array2.count)
    
    array1.enumerate().forEach { pair in
        let index = pair.index
        let element1 = pair.element
        let element2 = array2[index]
        XCTAssert(element1.isEqual(element2), "@\(index):: \(element1) is not equal to \(element2)")
    }
}