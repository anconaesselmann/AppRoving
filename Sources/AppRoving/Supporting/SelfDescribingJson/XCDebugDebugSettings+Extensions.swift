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

    init(_ data: Data) throws {
        self = try SelfDescribingJson(data)
            .properties(as: Self.self)
    }

    func updated(with data: Data) throws -> Self {
        try Self(data)
    }

    func selfDescribingData() throws -> Data {
        try SelfDescribingJson(self)
            .data()
    }

    func writeToFile(at url: URL) throws {
        let data = try selfDescribingData()
        try data.write(to: url)
    }

    func updateFile(at url: URL) throws {
        let comparisonData = try Self().selfDescribingData()
        guard
            let comparisonJsonDict = try JSONSerialization.jsonObject(with: comparisonData) as? SelfDescribingJson.JSON,
            let comparisonProperties: SelfDescribingJson.JSON = comparisonJsonDict[.properties]
        else {
            throw DebugSettingsError.invalidData
        }
        let comparisonKeys = Set(comparisonProperties.keys)
        let existingData = try Data(contentsOf: url, options: .mappedIfSafe)
        guard
            var jsonDict = try JSONSerialization.jsonObject(with: existingData) as? SelfDescribingJson.JSON,
            var properties: SelfDescribingJson.JSON = jsonDict[.properties]
        else {
            throw DebugSettingsError.invalidData
        }
        let version = jsonDict["version"] as? String
        let comparisonVersion = comparisonJsonDict["version"] as? String
        guard version == comparisonVersion else {
            try comparisonData.write(to: url)
            return
        }
        let keys = Set(properties.keys)

        let missingKeys = comparisonKeys.subtracting(keys)
        let obsoleteKeys = keys.subtracting(comparisonKeys)
        if !(missingKeys.isEmpty && obsoleteKeys.isEmpty) {
            for missingKey in missingKeys {
                properties[missingKey] = comparisonProperties[missingKey]
            }
            for obsoleteKey in obsoleteKeys {
                properties.removeValue(forKey: obsoleteKey)
            }
        }
        for key in keys {
            if
                var value = properties[key] as? SelfDescribingJson.JSON,
                let comparisonValue = comparisonProperties[key] as? SelfDescribingJson.JSON,
                let type = value["type"] as? String,
                let comparisonType = comparisonValue["type"] as? String,
                type == comparisonType,
                let nullable = value["nullable"] as? Bool,
                let comparisonNullable = comparisonValue["nullable"] as? Bool,
                nullable == comparisonNullable
            {
                continue
            } else {
                properties[key] = comparisonProperties[key]
            }
        }
        for key in keys {
            if
                var value = properties[key] as? SelfDescribingJson.JSON,
                let isEvent = value["event"] as? Bool,
                isEvent
            {
                value["history"] = nil
                properties[key] = value
            }
        }
        jsonDict[.properties] = properties
        let data = try JSONSerialization.data(
            withJSONObject: jsonDict,
            options: [.sortedKeys, .prettyPrinted]
        )
        try data.write(to: url)
    }
}
