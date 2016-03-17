import Foundation

func stringFromJSON(key: String) -> (AnyObject throws -> String) {
    return { value in
        switch value {
        case let string as String:
            return string
        default:
            throw JSONObjectError.ConversionFailure(key: key, value: value)
        }
    }
}

func intFromJSON(key: String) -> (AnyObject throws -> Int) {
    return { value in
        switch value {
        case let number as NSNumber:
            return number.integerValue
        default:
            throw JSONObjectError.ConversionFailure(key: key, value: value)
        }
    }
}

func floatFromJSON(key: String) -> (AnyObject throws -> Double) {
    return { value in
        switch value {
        case let number as NSNumber:
            return number.doubleValue
        default:
            throw JSONObjectError.ConversionFailure(key: key, value: value)
        }
    }
}

func boolFromJSON(key: String) -> (AnyObject throws -> Bool) {
    return { value in
        switch value {
        case let number as NSNumber:
            return number.boolValue
        default:
            throw JSONObjectError.ConversionFailure(key: key, value: value)
        }
    }
}

func decimalNumberFromJSON(key: String) -> (AnyObject throws -> NSDecimalNumber) {
    return { value in
        switch value {
        case let number as NSNumber:
            return NSDecimalNumber(string: number.stringValue)
        case let string as String:
            let number = NSDecimalNumber(string: string)
            if number == NSDecimalNumber.notANumber() {
                throw JSONObjectError.ConversionFailure(key: key, value: string)
            } else {
                return number
            }
        default:
            throw JSONObjectError.ConversionFailure(key: key, value: value)
        }
    }
}

func arrayFromJSON(key: String) -> (AnyObject throws -> [AnyObject]) {
    return { value in
        switch value {
        case let array as [AnyObject]:
            return array
        default:
            throw JSONObjectError.ConversionFailure(key: key, value: value)
        }
    }
}

func objectFromJSON(key: String) -> (AnyObject throws -> [String: AnyObject]) {
    return { value in
        switch value {
        case let object as [String: AnyObject]:
            return object
        default:
            throw JSONObjectError.ConversionFailure(key: key, value: value)
        }
    }
}

func optionalFromJSON<T>(translater: AnyObject throws -> T) -> (AnyObject? throws -> T?) {
    return { value in
        if let value = value {
            return try translater(value)
        } else {
            return nil
        }
    }
}

func optionalToJSON<T>(translater: T throws -> AnyObject) -> (T? throws -> AnyObject?) {
    return { value in
        if let value = value {
            return try translater(value)
        } else {
            return nil
        }
    }
}

public extension Object {
    /**
     Returns required attribute of string.
     */
    public func requiredStringAttribute(key: String) -> RequiredAttribute<String> {
        let read = stringFromJSON(key)
        let write: String throws -> AnyObject = { $0 }
        
        return self.requiredAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of string with function to generate default value.
     The given function is invoked everytime when the attribute is missing.
     */
    public func requiredStringAttribute(key: String, defaults: Void -> String) -> RequiredAttribute<String> {
        let attribute = self.requiredStringAttribute(key)
        attribute.fallback.value = defaults
        return attribute
    }
    
    /**
     Returns required attribute of string with default value.
     */
    public func requiredStringAttribute(key: String, or: String) -> RequiredAttribute<String> {
        return self.requiredStringAttribute(key, defaults: { or })
    }
    
    /**
     Returns optional attribute of string.
     */
    public func optionalStringAttribute(key: String) -> OptionalAttribute<String> {
        let read = optionalFromJSON(stringFromJSON(key))
        let write: String? throws -> AnyObject? = { $0 }
        
        return self.optionalAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of integer.
     This translates number value of JSON to Int of Swift.
     */
    public func requiredIntegerAttribute(key: String) -> RequiredAttribute<Int> {
        let read = intFromJSON(key)
        let write: Int throws -> AnyObject = { NSNumber(integer: $0) }
        
        return self.requiredAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of integer with function to generate default value.
     The given function is invoked everytime when the attribute is missing.
     */
    public func requiredIntegerAttribute(key: String, defaults: Void -> Int) -> RequiredAttribute<Int> {
        let attr = self.requiredIntegerAttribute(key)
        attr.fallback.value = defaults
        return attr
    }
    
    /**
     Returns required attribute of integer with default value.
     */
    public func requiredIntegerAttribute(key: String, or: Int) -> RequiredAttribute<Int> {
        return self.requiredIntegerAttribute(key, defaults: { or })
    }
    
    /**
     Returns optional attribute of integer.
     */
    public func optionalIntegerAttribute(key: String) -> OptionalAttribute<Int> {
        let read = optionalFromJSON(intFromJSON(key))
        let write: Int? throws -> AnyObject? = optionalToJSON { NSNumber(integer: $0) }
            
        return self.optionalAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of float.
     This translates number value of JSON to Double of Swift.
     */
    public func requiredFloatAttribute(key: String) -> RequiredAttribute<Double> {
        let read = floatFromJSON(key)
        let write: Double throws -> AnyObject = { NSNumber(double: $0) }
            
        return self.requiredAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of float with function to generate default value.
     The given function is invoked everytime when the attribute is missing.
     */
    public func requiredFloatAttribute(key: String, defaults: Void -> Double) -> RequiredAttribute<Double> {
        let attr = self.requiredFloatAttribute(key)
        attr.fallback.value = defaults
        return attr
    }
    
    /**
     Returns required attribute of float with default value.
     */
    public func requiredFloatAttribute(key: String, or: Double) -> RequiredAttribute<Double> {
        return self.requiredFloatAttribute(key, defaults: { or })
    }
    
    /**
     Returns optional attribute of float.
     */
    public func optionalFloatAttribute(key: String) -> OptionalAttribute<Double> {
        let read = optionalFromJSON(floatFromJSON(key))
        let write: Double? throws -> AnyObject? = optionalToJSON { NSNumber(double: $0) }
        
        return self.optionalAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of bool.
     
     This translates NSNumber to Bool.
     */
    public func requiredBooleanAttribute(key: String) -> RequiredAttribute<Bool> {
        let read = boolFromJSON(key)
        let write: Bool throws -> AnyObject = { NSNumber(bool: $0) }
        
        return self.requiredAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of bool with function to generate default value.
     The given function is invoked everytime when the attribute is missing.
     */
    public func requiredBooleanAttribute(key: String, defaults: Void -> Bool) -> RequiredAttribute<Bool> {
        let attr = self.requiredBooleanAttribute(key)
        attr.fallback.value = defaults
        return attr
    }
    
    /**
     Returns required attribute of bool with default value.
     */
    public func requiredBooleanAttribute(key: String, or: Bool) -> RequiredAttribute<Bool> {
        return self.requiredBooleanAttribute(key, defaults: { or })
    }
    
    /**
     Returns optional attribute of bool.
     */
    public func optionalBooleanAttribute(key: String) -> OptionalAttribute<Bool> {
        let read = optionalFromJSON(boolFromJSON(key))
        let write = optionalToJSON { NSNumber(bool: $0) }
        
        return self.optionalAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of NSDecimalNumber.
     
     This translates string attribute to NSDecimalNumber, or throws an error if the string cannot be translated to NSDecimalNumber (NaN is yielded from `NSDecimalNumber(string:)`).
     String is primary JSON representation of NSDecimalNumber.
     
     This also translates number attribute to NSDecimalNumber safely.
     */
    public func requiredDecimalNumberAttribute(key: String) -> RequiredAttribute<NSDecimalNumber> {
        let read = decimalNumberFromJSON(key)
        let write: NSDecimalNumber throws -> AnyObject = { $0.stringValue }
        
        return self.requiredAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of NSDecimalNumber with function to generate default value.
     The given function is invoked everytime when the attribute is missing.
     */
    public func requiredDecimalNumberAttribute(key: String, defaults: Void -> NSDecimalNumber) -> RequiredAttribute<NSDecimalNumber> {
        let attr = self.requiredDecimalNumberAttribute(key)
        attr.fallback.value = defaults
        return attr
    }
    
    /**
     Returns required attribute of NSDecimalNumber with default value.
     */
    public func requiredDecimalNumberAttribute(key: String, or: NSDecimalNumber) -> RequiredAttribute<NSDecimalNumber> {
        return self.requiredDecimalNumberAttribute(key, defaults: { or })
    }
    
    /**
     Returns optional attribute of NSDecimalNumber.
     */
    public func optionalDecimalNumberAttribute(key: String) -> OptionalAttribute<NSDecimalNumber> {
        let read = optionalFromJSON(decimalNumberFromJSON(key))
        let write: NSDecimalNumber? throws -> AnyObject? = optionalToJSON { $0.stringValue }
        
        return self.optionalAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of array.
     */
    public func requiredArrayAttribute(key: String) -> RequiredAttribute<[AnyObject]> {
        let read = arrayFromJSON(key)
        let write: [AnyObject] throws -> AnyObject = { $0 }
        
        return self.requiredAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of array with function to generate default value.
     The given function is invoked everytime when the attribute is missing.
     */
    public func requiredArrayAttribute(key: String, defaults: Void -> [AnyObject]) -> RequiredAttribute<[AnyObject]> {
        let attr = self.requiredArrayAttribute(key)
        attr.fallback.value = defaults
        return attr
    }
    
    /**
     Returns required attribute of array with default value.
     */
    public func requiredArrayAttribute(key: String, or: [AnyObject]) -> RequiredAttribute<[AnyObject]> {
        return self.requiredArrayAttribute(key, defaults: { or })
    }
    
    /**
     Returns optional attribute of array.
     */
    public func optionalArrayAttribute(key: String) -> OptionalAttribute<[AnyObject]> {
        let read = optionalFromJSON(arrayFromJSON(key))
        let write: [AnyObject]? throws -> AnyObject? = optionalToJSON { $0 }
        
        return self.optionalAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of object.
     */
    public func requiredObjectAttribute(key: String) -> RequiredAttribute<[String: AnyObject]> {
        let read = objectFromJSON(key)
        let write: [String: AnyObject] throws -> AnyObject = { $0 }
        
        return self.requiredAttribute(key, read: read, write: write)
    }
    
    /**
     Returns required attribute of object with function to generate default value.
     The given function is invoked everytime when the attribute is missing.
     */
    public func requiredObjectAttribute(key: String, defaults: Void -> [String: AnyObject]) -> RequiredAttribute<[String: AnyObject]> {
        let attr = self.requiredObjectAttribute(key)
        attr.fallback.value = defaults
        return attr
    }
    
    /**
     Returns required attribute of object with default value.
     */
    public func requiredObjectAttribute(key: String, or: [String: AnyObject]) -> RequiredAttribute<[String: AnyObject]> {
        return self.requiredObjectAttribute(key, defaults:  { or })
    }
    
    /**
     Returns optional attribute of object.
     */
    public func optionalObjectAttribute(key: String) -> OptionalAttribute<[String: AnyObject]> {
        let read = optionalFromJSON(objectFromJSON(key))
        let write: [String: AnyObject]? throws -> AnyObject? = optionalToJSON { $0 }
        
        return self.optionalAttribute(key, read: read, write: write)
    }
}