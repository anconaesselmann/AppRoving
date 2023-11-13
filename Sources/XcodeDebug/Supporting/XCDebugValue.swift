//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

private enum XCDebugValueCodingKeys: CodingKey {
    case type, value, caption, description, nullable
}

@propertyWrapper
public struct XCDebugValue<T>: Codable
    where T: Codable, T: XCDebugValueCompatible
{
    public var wrappedValue: T
    public var caption: String?
    public var description: String?

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public init(wrappedValue: T, caption: String, description: String? = nil) {
        self.wrappedValue = wrappedValue
        self.caption = caption
        self.description = description
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: XCDebugValueCodingKeys.self)
        wrappedValue = try container.decode(T.self, forKey: .value)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: XCDebugValueCodingKeys.self)
        let type = try XCDebugValueType(T.self)
        try container.encode(type.typeString, forKey: .type)
        try container.encode(type.nullable, forKey: .nullable)
        try container.encode(wrappedValue, forKey: .value)
        try container.encodeIfPresent(caption, forKey: .caption)
        try container.encodeIfPresent(description, forKey: .description)
    }
}
