//  Created by Axel Ancona Esselmann on 11/10/23.
//

import Foundation

public struct Setting: Identifiable {
    public enum Value {
        case bool(Bool)
        case string(String)
        case int(Int)
        case double(Double)
        case other(Any)
    }
    public let key: String
    public let name: String
    public let value: Value

    public var id: String { key }

    public init(key: String, name: String, value: Value) {
        self.key = key
        self.name = name
        self.value = value
    }

    public init?(key: String, rawValue: Any) {
        let name = key.deSnakeCased
        let value: Value
        switch rawValue {
        case let boolValue as Bool:
            value = .bool(boolValue)
        case let stringValue as String:
            value = .string(stringValue)
        case let intValue as Int:
            value = .int(intValue)
        case let doubleValue as Double:
            value = .double(doubleValue)
        default:
            value = .other(rawValue)
        }
        self.init(key: key, name: name, value: value)
    }
}
