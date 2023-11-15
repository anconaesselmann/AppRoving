//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public struct XCDebugValueType {
    public enum ValueType: String {
        case bool, int, double, string, date, uuid, url, `enum`, object
    }

    public enum Error: Swift.Error {
        case unsupportedType
    }

    public let valueType: ValueType
    public let nullable: Bool
    public let cases: [String]?

    var typeString: String {
        valueType.rawValue
    }

    public init(type: String, nullable: Bool, cases: [String]?) throws {
        self.nullable = nullable

        guard let valueType = ValueType(rawValue: type) else {
            throw Error.unsupportedType
        }
        self.valueType = valueType
        self.cases = cases
    }

    public init<T>(_ value: T, type: T.Type) throws
        where T: Codable
    {
        var cases: [String]?
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
            switch value {
            case let e as (any CaseIterable & RawRepresentable) where e.rawValue is String:
                self.valueType = .enum
                self.nullable = false
                cases = e.allCases as? [String]
            case let e as (any CaseIterable & RawRepresentable)? where e?.rawValue is String:
                self.valueType = .enum
                self.nullable = true
                cases = e?.allCases as? [String]
            default:
                throw Error.unsupportedType
            }
        }
        self.cases = cases
    }
}

extension CaseIterable 
    where Self: RawRepresentable
{
    var allCases: [Self.RawValue] {
        let type = type(of: self)
        let allCases = type.allCases
        return allCases.map { $0.rawValue }
    }
}
