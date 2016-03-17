import Foundation

/**
 Errors thrown from Object.
 */
public enum JSONObjectError : ErrorType {
    /**
     Thrown when required attribute is missing.
     */
    case RequiredAttributeMissing(key: String)
    
    /**
     Thrown when attribute value cannot be converted to expected type.
     */
    case ConversionFailure(key: String, value: Any?)
    
    /**
     Thrown when array contains unexpected value or type.
     */
    case ArrayContainsUnexpectedElement(index: Int, element: AnyObject)
    
    /**
     Not thrown from the library.
     Throw this error if you want to halt JSON reading when unknown attribute is given.
     */
    case UnknownAttribute(key: String)
}
