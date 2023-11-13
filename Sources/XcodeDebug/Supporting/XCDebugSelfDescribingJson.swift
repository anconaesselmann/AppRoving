//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public struct SelfDescribingJson {
    public var name: String
    public var key: String
    public var properties: [String: Any]

    public init(_ data: Data) throws {
        guard
            let jsonDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let name = jsonDict[XCDebugConstants.displayName] as? String,
            let key = jsonDict[XCDebugConstants.key] as? String,
            let properties = jsonDict[XCDebugConstants.properties] as? [String: Any]
        else {
            throw DebugSettingsError.invalidData
        }
        self.key = key
        self.name = name
        self.properties = properties
    }

    public init<T>(_ setting: T) throws
        where T: DebugSettings, T: Encodable
    {
        let data = try DefaultCoders.encoder.encode(setting)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        guard var properties = jsonData as? [String: Any] else {
            throw CustomSettingsError.notAValidDictionary
        }
        name = T.name
        key = T.key
        self.properties = properties
    }

    public func data() throws -> Data {
        var dict = [String: Any]()
        dict[XCDebugConstants.properties] = properties
        dict[XCDebugConstants.displayName] = name
        dict[XCDebugConstants.key] = key
        return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }

    public func properties<T>(as type: T.Type) throws -> T
        where T: Decodable
    {
        let data = try JSONSerialization.data(withJSONObject: properties, options: .prettyPrinted)
        return try DefaultCoders.decoder.decode(T.self, from: data)
    }
}
