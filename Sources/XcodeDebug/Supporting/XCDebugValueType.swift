//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public enum XCDebugValueType: String {

    public enum Error: Swift.Error {
        case unsupportedType
    }

    case bool, int, double, string, date, uuid, url
    case optionalBool, optionalInt, optionalDouble, optionalString, optionalDate, optionalUuid, optionalUrl

    init<T>(_ type: T.Type) throws {
        switch type {
        case is Bool.Type: self = .bool
        case is Bool?.Type: self = .optionalBool
        case is Int.Type: self = .int
        case is Int?.Type: self = .optionalInt
        case is Double.Type: self = .double
        case is Double?.Type: self = .optionalDouble
        case is String.Type: self = .string
        case is String?.Type: self = .optionalString
        case is Date.Type: self = .date
        case is Date?.Type: self = .optionalDate
        case is UUID.Type: self = .uuid
        case is UUID?.Type: self = .optionalUuid
        case is URL.Type: self = .url
        case is URL?.Type: self = .optionalUrl
        default: throw Error.unsupportedType
        }
    }
}
