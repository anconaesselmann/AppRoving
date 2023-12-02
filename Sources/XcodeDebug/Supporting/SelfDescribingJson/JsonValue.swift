//  Created by Axel Ancona Esselmann on 12/1/23.
//

import Foundation

public enum JsonValue {

    public enum TypeNames: String {
        case bool, int, double, string, date, `enum`
    }

    public enum Error: Swift.Error {
        case invalidJson, missingType, missingNullabillity, isNull, invalidType, typeMismatch
    }

    case bool(Bool)
    case optionalBool(Bool?)
    case int(Int)
    case optionalInt(Int?)
    case double(Double)
    case optionalDouble(Double?)
    case string(String)
    case optionalString(String?)
    case date(Date)
    case optionalDate(Date?)
    case `enum`(String)
    case optionalEnum(String?)

    public init(_ any: Any?) throws {
        guard let json = any as? [String: Any] else {
            throw Error.invalidJson
        }
        guard let typeString = json["type"] as? String else {
            throw Error.missingType
        }
        guard let typeName = TypeNames(rawValue: typeString) else {
            throw Error.invalidType
        }
        guard let nullable = json["nullable"] as? Bool else {
            throw Error.missingNullabillity
        }
        var anyValue = json["value"]
        if !nullable {
            guard let value = anyValue else {
                throw Error.isNull
            }
            if let nsObject = value as? NSObject, nsObject == NSNull() {
                throw Error.isNull
            }
            try self.init(value: value, typeName: typeName)
        } else {
            if let nsObject = anyValue as? NSObject, nsObject == NSNull() {
                anyValue = nil
            }
            try self.init(optionalValue: anyValue, typeName: typeName)
        }
    }

    init(value: Any, typeName: TypeNames) throws {
        switch typeName {
        case .bool:
            guard let bool = value as? Bool else {
                throw Error.typeMismatch
            }
            self = .bool(bool)
        case .int:
            guard let int = value as? Int else {
                throw Error.typeMismatch
            }
            self = .int(int)
        case .double:
            guard let double = value as? Double else {
                throw Error.typeMismatch
            }
            self = .double(double)
        case .string:
            guard let string = value as? String else {
                throw Error.typeMismatch
            }
            self = .string(string)
        case .date:
            guard let date = try? Date(fromJsonValue: value) else {
                throw Error.typeMismatch
            }
            self = .date(date)
        case .enum:
            guard let enumValue = value as? String else {
                throw Error.typeMismatch
            }
            self = .enum(enumValue)
        }
    }

    init(optionalValue: Any?, typeName: TypeNames) throws {
        switch (typeName, optionalValue) {
        case (.bool, nil):
            self = .optionalBool(nil)
        case (.bool, let bool as Bool):
            self = .optionalBool(bool)

        case (.int, nil):
            self = .optionalInt(nil)
        case (.int, let int as Int):
            self = .optionalInt(int)

        case (.double, nil):
            self = .optionalDouble(nil)
        case (.double, let double as Double):
            self = .optionalDouble(double)

        case (.string, nil):
            self = .optionalString(nil)
        case (.string, let string as String):
            self = .optionalString(string)

        case (.date, nil):
            self = .optionalDate(nil)
        case (.date, let double as Double):
            let date = try Date(fromJsonValue: double)
            self = .optionalDate(date)

        case (.enum, nil):
            self = .optionalEnum(nil)
        case (.enum, let rawValue as String):
            self = .optionalEnum(rawValue)
        default:
            throw Error.typeMismatch
        }
    }

    public var typeName: TypeNames {
        switch self {
        case .bool, .optionalBool:
            return .bool
        case .int, .optionalInt:
            return .int
        case .double, .optionalDouble:
            return .double
        case .string, .optionalString:
            return .string
        case .date, .optionalDate:
            return .date
        case .enum, .optionalEnum:
            return .enum
        }
    }

    public var encodableValue: Any? {
        switch self {
        case .bool(let bool):
            return bool
        case .optionalBool(let bool):
            return bool
        case .int(let int):
            return int
        case .optionalInt(let int):
            return int
        case .double(let double):
            return double
        case .optionalDouble(let double):
            return double
        case .string(let string):
            return string
        case .optionalString(let string):
            return string
        case .date(let date):
            return try? date.encoded()
        case .optionalDate(let date):
            return try? date?.encoded()
        case .enum(let rawValue):
            return rawValue
        case .optionalEnum(let rawValue):
            return rawValue
        }
    }

    public var actualValue: Any? {
        switch self {
        case .bool(let bool):
            return bool
        case .optionalBool(let bool):
            return bool
        case .int(let int):
            return int
        case .optionalInt(let int):
            return int
        case .double(let double):
            return double
        case .optionalDouble(let double):
            return double
        case .string(let string):
            return string
        case .optionalString(let string):
            return string
        case .date(let date):
            return date
        case .optionalDate(let date):
            return date
        case .enum(let rawValue):
            return rawValue
        case .optionalEnum(let rawValue):
            return rawValue
        }
    }

    public var stringValue: String {
        switch self {
        case .bool(let bool):
            return bool ? "true" : "false"
        case .optionalBool(let bool):
            guard let bool = bool else {
                return "nil"
            }
            return bool ? "true" : "false"
        case .int(let int):
            return "\(int)"
        case .optionalInt(let int):
            guard let int = int else {
                return "nil"
            }
            return "\(int)"
        case .optionalDouble(let double):
            guard let double = double else {
                return "nil"
            }
            return "\(double)"
        case .double(let double):
            return "\(double)"
        case .optionalString(let string):
            guard let string = string else {
                return "nil"
            }
            return string
        case .string(let string):
            return string
        case .optionalDate(let date):
            guard let date = date else {
                return "nil"
            }
            return date.formatted()
        case .date(let date):
            return date.formatted()
        case .optionalEnum(let stringValue):
            guard let stringValue = stringValue else {
                return "nil"
            }
            return stringValue
        case .enum(let stringValue):
            return stringValue
        }
    }

    public var isNil: Bool {
        switch self {
        case .bool, .int, .double, .string, .date, .enum:
            return false
        case .optionalBool(let value):
            return value == nil
        case .optionalInt(let value):
            return value == nil
        case .optionalDouble(let value):
            return value == nil
        case .optionalString(let value):
            return value == nil
        case .optionalDate(let value):
            return value == nil
        case .optionalEnum(let value):
            return value == nil
        }
    }

    public mutating func update(_ newValue: Any?) throws {
        switch (self, newValue) {
        case (.optionalBool, let bool as Bool):
            self = .optionalBool(bool)
        case (.optionalBool, nil):
            self = .optionalBool(nil)
        case (.bool, let bool as Bool):
            self = .bool(bool)

        case (.optionalInt, let int as Int):
            self = .optionalInt(int)
        case (.optionalInt, nil):
            self = .optionalInt(nil)
        case (.int, let int as Int):
            self = .int(int)

        case (.optionalDouble, let double as Double):
            self = .optionalDouble(double)
        case (.optionalDouble, nil):
            self = .optionalDouble(nil)
        case (.double, let double as Double):
            self = .double(double)

        case (.optionalString, let string as String):
            self = .optionalString(string)
        case (.optionalString, nil):
            self = .optionalString(nil)
        case (.string, let string as String):
            self = .string(string)

        case (.optionalDate, let date as Date):
            self = .optionalDate(date)
        case (.optionalDate, nil):
            self = .optionalDate(nil)
        case (.date, let date as Date):
            self = .date(date)

        case (.optionalEnum, let rawValue as String):
            self = .optionalEnum(rawValue)
        case (.optionalEnum, nil):
            self = .optionalEnum(nil)
        case (.enum, let rawValue as String):
            self = .enum(rawValue)

        default:
            throw Error.invalidType
        }
    }

    public var isNullable: Bool {
        switch self {
        case .optionalBool, .optionalInt, .optionalDouble, .optionalString, .optionalDate, .optionalEnum:
            return true
        case .bool, .int, .double, .string, .date, .enum:
            return false
        }
    }

    public var json: [String: Any] {
        [
            "type": typeName.rawValue,
            "value": encodableValue ?? NSNull(),
            "nullable": isNullable
        ]
    }
}

private extension Date {

    enum Error: Swift.Error {
        case encodingError, decodingError
    }

    func encoded() throws -> Double {
        let data = try JSONEncoder().encode(self)
        guard
            let string = String(data: data, encoding: .utf8),
            let double = Double(string)
        else {
            throw Error.encodingError
        }
        return double
    }

    func formatted() -> String {
        ISO8601Format()
    }

    init(fromJsonValue value: Any) throws {
        guard
            let double = value as? Double,
            let data = "\(double)".data(using: .utf8),
            let date = try? JSONDecoder().decode(Date.self, from: data)
        else {
            throw Error.decodingError
        }
        self = date
    }
}
