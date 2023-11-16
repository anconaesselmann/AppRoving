//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

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

@propertyWrapper
public struct XCDebugValue<T>: Codable
    where T: Codable
{
    enum CodingKeys: CodingKey {
        case type, value, caption, description, nullable, cases
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wrappedValue = try container.decode(T.self, forKey: .value)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let type = try XCDebugValueType(self.wrappedValue, type: T.self)
        try container.encode(type.typeString, forKey: .type)
        try container.encode(type.nullable, forKey: .nullable)
        try container.encodeIfPresent(type.cases, forKey: .cases)
        try container.encode(wrappedValue, forKey: .value)
        try container.encodeIfPresent(caption, forKey: .caption)
        try container.encodeIfPresent(description, forKey: .description)
    }
}
