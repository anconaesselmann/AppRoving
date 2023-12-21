//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public struct XCDebugValueType: Equatable {
    public enum ValueType: String {
        case bool, int, double, string, date, uuid, url, `enum`, object
    }

    public enum Error: Swift.Error {
        case unsupportedType
    }

    public let valueType: ValueType
    public let nullable: Bool
    public let isEvent: Bool
    public let cases: [String]?

    var typeString: String {
        valueType.rawValue
    }

    public init(type: String, nullable: Bool, cases: [String]?, isEvent: Bool) throws {
        self.nullable = nullable

        guard let valueType = ValueType(rawValue: type) else {
            throw Error.unsupportedType
        }
        self.valueType = valueType
        self.cases = cases
        self.isEvent = isEvent
    }

    public init<T>(_ value: T, type: T.Type) throws
        where T: Codable
    {
        var cases: [String]?
        self.nullable = T.self is OptionalProtocol.Type
        switch type {
        case is Bool.Type, is Bool?.Type:
            self.valueType = .bool
        case is Int.Type, is Int?.Type:
            self.valueType = .int
        case is Double.Type, is Double?.Type:
            self.valueType = .double
        case is String.Type, is String?.Type:
            self.valueType = .string
        case is Date.Type, is Date?.Type:
            self.valueType = .date
        case is UUID.Type, is UUID?.Type:
            self.valueType = .uuid
        case is URL.Type, is URL?.Type:
            self.valueType = .url
        default:
            switch value {
            case let e as (any CaseIterable & RawRepresentable):
                self.valueType = .enum
                cases = e.allCases.map { "\($0)" } as? [String]
            default:
                throw Error.unsupportedType
            }
        }
        self.cases = cases
        if value is (any XCDebugEvent) {
            self.isEvent = true
        } else {
            self.isEvent = false
        }
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

protocol OptionalProtocol {}

extension Optional : OptionalProtocol {
    var wrappedValue: Wrapped? {
        switch self {
        case .some(let value): return value
        case .none: return nil
        }
    }

    static var wrappedType: Wrapped.Type {
        Wrapped.self
    }

}
