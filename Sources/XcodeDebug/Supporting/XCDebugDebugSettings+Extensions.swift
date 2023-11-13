//  Created by Axel Ancona Esselmann on 11/12/23.
//

import Foundation

public enum DebugSettingsError: Swift.Error {
    case invalidData
}

public extension DebugSettings {
    static var fileName: String {
        key + XCDebugConstants.jsonFileExtensions
    }

    static var key: String {
        Self.name.camelCased
    }

    func fromSelfDescribingData(_ data: Data) throws -> Self {
        guard
            let jsonDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let propertyDict = jsonDict[XCDebugConstants.properties] as? [String: Any]
        else {
            throw DebugSettingsError.invalidData
        }
        let propertyData = try JSONSerialization.data(withJSONObject: propertyDict, options: .prettyPrinted)
        return try DefaultCoders.decoder.decode(Self.self, from: propertyData)
    }

    func selfDescribingData() throws -> Data {
        let data = try DefaultCoders.encoder.encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        guard var properties = jsonData as? [String: Any] else {
            throw CustomSettingsError.notAValidDictionary
        }
        var dict = [String: Any]()
        dict[XCDebugConstants.properties] = properties
        dict[XCDebugConstants.displayName] = Self.name
        dict[XCDebugConstants.key] = Self.key
        return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
}
