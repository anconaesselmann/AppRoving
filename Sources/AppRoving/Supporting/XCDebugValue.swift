//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public protocol XCDebugEvent: RawRepresentable where RawValue == String { }

public extension XCDebugValue {
    init<V>(
        caption: String? = nil,
        description: String? = nil
    ) where T == Optional<V> {
        self.wrappedValue = nil
        self.caption = caption
        self.description = description
    }
}

public extension XCDebugValue {
    init(
        wrappedValue: T,
        caption: String? = nil,
        description: String? = nil
    ) {
        self.wrappedValue = wrappedValue
        self.caption = caption
        self.description = description
    }
}

class EventManager {
    static let shared = EventManager()
    var events: [AnyHashable: [String]] = [:]
}

@propertyWrapper
public struct XCDebugValue<T>: Codable
    where T: Codable
{
    enum CodingKeys: CodingKey {
        case type, value, caption, description, nullable, cases, event, history
    }

    public 
    private(set)
    var wrappedValue: T

    public
    private(set)
    var caption: String?

    public
    private(set)
    var description: String?

    internal var history: [String]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wrappedValue = try container.decode(T.self, forKey: .value)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        history = try container.decodeIfPresent([String].self, forKey: .history)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let type = try XCDebugValueType(self.wrappedValue, type: T.self)
        try container.encode(type.typeString, forKey: .type)
        try container.encode(type.nullable, forKey: .nullable)
        if type.isEvent {
            try container.encode(type.isEvent, forKey: .event)
        }
        try container.encodeIfPresent(type.cases, forKey: .cases)
        if let enumValue = wrappedValue as? (any XCDebugEnum) {
            let stringValue = enumValue.stringValue
            try container.encode(stringValue, forKey: .value)
        } else {
            try container.encode(wrappedValue, forKey: .value)
        }
        try container.encodeIfPresent(caption, forKey: .caption)
        try container.encodeIfPresent(description, forKey: .description)
    }

    public var projectedValue: Self { self }
}

public protocol XCDebugEnum: Codable, CaseIterable, RawRepresentable {
    var stringValue: String { get }
    init(stringValue: String) throws
}

enum XCDebugEnumError: Swift.Error {
    case invalidStringRepresentation
}

public extension XCDebugEnum {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        try self.init(stringValue: stringValue)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let stringValue = self.stringValue
        try container.encode(stringValue)
    }
}

public extension XCDebugEnum where RawValue == String {
    init(stringValue: String) throws {
        self.init(rawValue: stringValue)!
    }
    var stringValue: String {
        rawValue
    }
}

public extension XCDebugEnum where RawValue == Int {
    init(stringValue: String) throws {
        guard let intValue = Int(stringValue) else {
            throw XCDebugEnumError.invalidStringRepresentation
        }
        self.init(rawValue: intValue)!
    }

    var stringValue: String {
        "\(rawValue)"
    }
}

public extension XCDebugEnum where RawValue == Double {
    init(stringValue: String) throws {
        guard let doubleValue = Double(stringValue) else {
            throw XCDebugEnumError.invalidStringRepresentation
        }
        self.init(rawValue: doubleValue)!
    }

    var stringValue: String {
        "\(rawValue)"
    }
}
