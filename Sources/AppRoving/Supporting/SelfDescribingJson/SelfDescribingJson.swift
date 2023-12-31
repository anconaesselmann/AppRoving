//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public struct SelfDescribingJson {

    public typealias JSON = [String: Any]

    public enum Keys: String {
        case name, key, properties, value, version
    }

    public var name: String, key: String, version: Version
    public var properties: [String: Any]

    public init(_ data: Data) throws {
        guard
            let jsonDict = try JSONSerialization.jsonObject(with: data) as? JSON,
            let name: String = jsonDict[.name],
            let key:  String = jsonDict[.key],
            let properties: JSON = jsonDict[.properties],
            let versionString: String = jsonDict[.version]
        else {
            throw DebugSettingsError.invalidData
        }
        self.key = key
        self.name = name
        self.properties = properties
        self.version = try Version(versionString)
    }

    public init<T>(_ setting: T) throws
        where T: DebugSettings, T: Encodable
    {
        let data = try DefaultCoders.encoder.encode(setting)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        guard var properties = jsonData as? JSON else {
            throw CustomSettingsError.notAValidDictionary
        }
        name = T.name
        key  = T.key
        self.properties = properties
        version = XCDebugConstants.version
    }

    public func data() throws -> Data {
        var dict = JSON()
        dict[.properties] = try properties.reduce(into: JSON()) {
            let jsonValue = try JsonValue($1.value)
            guard var dict = $1.value as? [String: Any] else {
                assertionFailure()
                return
            }
            dict["value"] = jsonValue.encodableValue ?? NSNull()
            $0[$1.key] = dict
        }
        dict[.name] = name
        dict[.key]  = key
        dict[.version] = version.description
        return try JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys, .prettyPrinted])
    }

    public func properties<T>(as type: T.Type) throws -> T
        where T: Decodable
    {
        let data = try JSONSerialization.data(withJSONObject: properties, options: [.sortedKeys, .prettyPrinted])
        return try DefaultCoders.decoder.decode(T.self, from: data)
    }

    public subscript(historyForKey key: String) -> [String]? {
        get {
            guard var dict = properties[key] as? [String: Any] else {
                return nil
            }
            return dict["history"] as? [String]
        }
        set {
            guard var existingDict = properties[key] as? [String: Any] else {
                assertionFailure()
                return
            }
            guard let newElements = newValue else {
                existingDict["history"] = nil // NSNull() // TODO: Test
                return
            }
            existingDict["history"] = newElements
            properties[key] = existingDict
        }
    }

    public func isEvent(_ key: String) -> Bool {
        guard var json = properties[key] as? [String: Any] else {
            return false
        }
        return (json["event"] as? Bool) ?? false
    }

    public mutating func addToHistory(key: String) {
        guard let value = self[key]?.stringValue else {
            assertionFailure()
            return
        }
        let entry = "\(UUID().uuidString.lowercased()):\(value)"
        var existing = self[historyForKey: key] ?? []
        let max = 4
        if existing.count > max {
            existing = Array(existing.dropFirst(existing.count - max))
        }
        existing.append(entry)
        self[historyForKey: key] = existing
    }

    public subscript(key: String) -> JsonValue? {
        get {
            guard var dict = properties[key] as? [String: Any] else {
                return nil
            }
            do {
                return try JsonValue(dict)
            } catch {
                print(error)
                assertionFailure()
                return nil
            }
        }
        set {
            guard var existingDict = properties[key] as? [String: Any] else {
                assertionFailure()
                return
            }
            do {
                guard let newValue = newValue else {
                    existingDict["value"] = NSNull()
                    return
                }
                var jsonValue = try JsonValue(existingDict)
                try jsonValue.update(newValue.actualValue)
                existingDict["value"] = jsonValue.encodableValue ?? NSNull()
                properties[key] = existingDict
            } catch {
//                assertionFailure()
                print(error)
            }
        }
    }

    public mutating func nilValue(_ key: String) {
        guard var value = properties[key] as? [String: Any] else {
            return
        }
        value[.value] = NSNull()
        properties[key] = value
    }

    public func write(to url: URL) throws {
        let data = try data()
        try data.write(to: url)
    }
}
