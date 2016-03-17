import Foundation

/**
 Internal protocol. This is exposed to your application just because of Swift's limitation.
 */
public protocol ObjectProtocol : class {
    init()
    func _internalRead(object: [String : AnyObject], block: Any -> Void) throws
    func _internalWrite(block: Any -> Void) throws -> [String : AnyObject]
}

public extension ObjectProtocol {
    /**
     Takes JSON object dictionary and yields given block with typed object.
     Throws an exception if given object is invalid.
     */
    static func readJSON<T>(object: [String: AnyObject], block: Self -> T) throws -> T {
        var result: T! = nil
        try Self()._internalRead(object) { this in
            result = block(this as! Self)
        }
        return result
    }
    
    /**
     Takes JSON array and yields given block with typed object.
     
     Returned array is optional because the JSON array may contain null.
     Throws `JSONObjectError.ArrayContainsUnexpectedElement` if array contains value other than object.
     */
    static func readJSONArray<T>(array: [AnyObject], block: Self -> T) throws -> [T?] {
        var result: [T?] = []
        
        try array.enumerate().forEach { pair in
            let index = pair.index
            let element = pair.element
            
            switch element {
            case is NSNull:
                result.append(nil)
            case let object as [String: AnyObject]:
                let value = try Self.readJSON(object, block: block)
                result.append(value)
            default:
                throw JSONObjectError.ArrayContainsUnexpectedElement(index: index, element: element)
            }
        }
        
        return result
    }
    
    /**
     Takes block to update to generate JSON object dictionary, and return a dictionary.
     Throws an exception if update object is invalid.
     */
    static func writeJSON(block: Self -> Void) throws -> [String: AnyObject] {
        return try Self()._internalWrite { this in
            block(this as! Self)
        }
    }
    
    /**
     Takes array and block to translate and returns array.
     */
    static func writeJSONArray<T>(array: [T], block: (object: Self, element: T) -> Void) throws -> [AnyObject] {
        var result: [AnyObject] = []
        
        for element in array {
            let json = try Self.writeJSON { object in
                block(object: object, element: element)
            }
            result.append(json)
        }
        
        return result
    }
}

/**
 Base class to make JSON object typed.
 Define your custom sub class and use it to manipulate JSON object.
 */
public class Object : ObjectProtocol {
    var attributes: [String: RawAttribute]
    
    required public init() {
        self.attributes = [:]
    }
    
    /**
     Override this method to assign attributes.
     
     The default implementation does nothing.
     */
    public func setupAttributes() {
        // To be implemented in sub class
    }
    
    /**
     Will be called if given JSON object contains unknown attribute.
     Raise an exception to halt processing, or print error message.
     
     The default implementation does nothing.
     */
    public func handleUnknownAttribute(key: String, value: AnyObject?) throws {
        // To be implemented in sub class
    }
    
    public func _internalRead(object: [String : AnyObject], block: Any -> Void) throws {
        self.setupAttributes()
        
        for (key, attribute) in self.attributes {
            let value = object[key]
            try attribute.readValue(value is NSNull ? nil : value)
        }
        
        for (key, value) in object {
            if self.attributes[key] == nil {
                try self.handleUnknownAttribute(key, value: value is NSNull ? nil : value)
            }
        }
        
        block(self)
    }
    
    public func _internalWrite(block: Any -> Void) throws -> [String : AnyObject] {
        self.setupAttributes()
        
        block(self)
        
        var object : [String: AnyObject] = [:]
        for (key, attribute) in self.attributes {
            let value = try attribute.writeValue()
            object[key] = value
        }
        
        return object
    }

    /**
     Returns RequiredAttribute initialized with given read/write functions, and puts the attribute to internal registry.
     Use this method to define your custom attribute.
     */
    public func requiredAttribute<T>(key: String, read: AnyObject throws -> T, write: T throws -> AnyObject) -> RequiredAttribute<T> {
        let attribute = RequiredAttribute(key: key, read: read, write: write)
        self.attributes[key] = attribute
        return attribute
    }
    
    /**
     Returns OptionalAttribute initialized with given read/write functions, and puts the attribute to internal registry.
     Use this method to define your custom attribute.
     */
    public func optionalAttribute<T>(key: String, read: AnyObject? throws -> T?, write: T? throws -> AnyObject?) -> OptionalAttribute<T> {
        let attribute = OptionalAttribute(key: key, read: read, write: write)
        self.attributes[key] = attribute
        return attribute
    }
}
