import Foundation

/**
 Base class for attribute.
 Applications usually does not use this class at all.
 */
public class RawAttribute {
    /**
     Key of the attribute in JSON.
     This property is used for error message.
     */
    public let key: String
    
    var rawValue: Any?
    
    let rawRead: AnyObject? throws -> Any?
    let rawWrite: Any? throws -> AnyObject?
    
    init(key: String, read: AnyObject? throws -> Any?, write: Any? throws -> AnyObject?) {
        self.key = key
        self.rawRead = read
        self.rawWrite = write
    }
    
    func readValue(rawValue: AnyObject?) throws {
        self.rawValue = try self.rawRead(rawValue)
    }
    
    func writeValue() throws -> AnyObject? {
        return try self.rawWrite(self.rawValue)
    }
}

class Ref<T> {
    var value: T
    
    init(value: T) {
        self.value = value
    }
}

/**
 Attribute which cannot be omitted.
 */
public class RequiredAttribute<T> : RawAttribute {
    let skipped: Ref<Bool>
    
    var fallback: Ref<(Void -> T)?>
    var read: AnyObject throws -> T
    var write: T throws -> AnyObject
    
    init(key: String, read: AnyObject throws -> T, write: T throws -> AnyObject) {
        let skipped = Ref(value: false)
        let fallback: Ref<(Void -> T)?> = Ref(value: nil)
        
        let rawRead: AnyObject? throws -> Any? = { value in
            if let value = value {
                return try read(value)
            } else {
                if let fallback = fallback.value {
                    return fallback()
                } else {
                    throw JSONObjectError.RequiredAttributeMissing(key: key)
                }
            }
        }
        let rawWrite: Any? throws -> AnyObject? = { value in
            if skipped.value {
                return nil
            }
            
            if let value = value {
                return try write(value as! T)
            } else {
                throw JSONObjectError.RequiredAttributeMissing(key: key)
            }
        }
        
        self.skipped = skipped
        self.read = read
        self.write = write
        self.fallback = fallback
        
        super.init(key: key, read: rawRead, write: rawWrite)
    }
    
    /**
     Read/write values of JSON object.
     */
    public var value : T {
        get {
            return self.rawValue as! T
        }
        
        set(value) {
            self.rawValue = value
        }
    }
    
    /**
     Mark this attribute allowed to be blank on write.
     This method can be used for readonly attributes of API.
     
     Use this method for server side generated attributes like `id` or `created_at`.
     Assume these attributes always exists JSON from server, but client cannot generate the value.
     Call `skip` on convert to JSON, and let the attribute blank.
     */
    public func skip() {
        self.skipped.value = true
    }
}

/**
 Optional attribute.
 */
public class OptionalAttribute<T> : RawAttribute {
    init(key: String, read: AnyObject? throws -> T?, write: T? throws -> AnyObject?) {
        let rawRead: AnyObject? throws -> Any? = { try read($0) }
        let rawWrite: Any? throws -> AnyObject? = { try write($0 as! T?) }
        
        super.init(key: key, read: rawRead, write: rawWrite)
    }
    
    /**
     Read/write values of JSON object.
     
     On read, `nil` if the attribute is missing in JSON, or `null`.
     On write, assigning `nil` skips attribute in JSON, not writing `null`.
     */
    public var value : T? {
        get {
            return self.rawValue as! T?
        }
        
        set(value) {
            self.rawValue = value
        }
    }
}
