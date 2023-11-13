//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

@propertyWrapper
public struct XCDebugValue<T>: Codable
    where T: Codable, T: XCDebugValueCompatible
{
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    private enum CodingKeys: CodingKey {
        case typeName, value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wrappedValue = try container.decode(T.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let typeString = try XCDebugValueType(T.self).rawValue
        try container.encode(typeString, forKey: .typeName)
        try container.encode(wrappedValue, forKey: .value)
    }
}
