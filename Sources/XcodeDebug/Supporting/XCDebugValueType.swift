//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public struct XCDebugValueType {
    public enum ValueType: String {
        case bool, int, double, string, date, uuid, url
    }

    public enum Error: Swift.Error {
        case unsupportedType
    }

    public let valueType: ValueType
    public let nullable: Bool

    var typeString: String {
        valueType.rawValue
    }

    public init(type: String, nullable: Bool) throws {
        self.nullable = nullable

        guard let valueType = ValueType(rawValue: type) else {
            throw Error.unsupportedType
        }
        self.valueType = valueType
    }

    public init<T>(_ type: T.Type) throws {
        switch type {
        case is Bool.Type:
            self.valueType = .bool
            self.nullable = false
        case is Bool?.Type:
            self.valueType = .bool
            self.nullable = true
        case is Int.Type:
            self.valueType = .int
            self.nullable = false
        case is Int?.Type:
            self.valueType = .int
            self.nullable = true
        case is Double.Type:
            self.valueType = .double
            self.nullable = false
        case is Double?.Type:
            self.valueType = .double
            self.nullable = true
        case is String.Type:
            self.valueType = .string
            self.nullable = false
        case is String?.Type:
            self.valueType = .string
            self.nullable = true
        case is Date.Type:
            self.valueType = .date
            self.nullable = false
        case is Date?.Type:
            self.valueType = .date
            self.nullable = true
        case is UUID.Type:
            self.valueType = .uuid
            self.nullable = false
        case is UUID?.Type:
            self.valueType = .uuid
            self.nullable = true
        case is URL.Type:
            self.valueType = .url
            self.nullable = false
        case is URL?.Type:
            self.valueType = .url
            self.nullable = true
        default:
            throw Error.unsupportedType
        }
    }
}
