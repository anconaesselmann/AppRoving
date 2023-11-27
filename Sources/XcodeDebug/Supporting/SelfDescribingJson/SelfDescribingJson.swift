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
        dict[.properties] = properties.reduce(into: JSON()) {
            $0[$1.key] = Self.mapValue($1.value)
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

    public subscript<Value>(key: String) -> Value? {
        get {
            guard var value = properties[key] as? [String: Any] else {
                return nil
            }
            return Self.unMapValue(value[.value])
        }
        set {
            guard var value = properties[key] as? [String: Any] else {
                return
            }
            if let updated = newValue {
                value[.value] = updated
            } else {
                value[.value] = NSNull()
            }
            properties[key] = value
        }
    }

    public mutating func nilValue(_ key: String) {
        guard var value = properties[key] as? [String: Any] else {
            return
        }
        value[.value] = NSNull()
        properties[key] = value
    }

    private static func mapValue(_ any: Any) -> Any {
        guard
            var dict = any as? JSON,
            let value = dict[.value]
        else {
            return any
        }
        switch value {
        case let date as Date:
            guard
                let data = try? JSONEncoder().encode(date),
                let string = String(data: data, encoding: .utf8),
                let double = Double(string)
            else {
                return any
            }
            dict[.value] = double
        default: ()
        }
        return dict
    }

    private static func unMapValue<T>(_ any: Any?) -> T? {
        switch T.self {
        case is Date.Type:
            guard 
                let double = any as? Double,
                let data = "\(double)".data(using: .utf8),
                let date = try? JSONDecoder().decode(Date.self, from: data)
            else {
                // TODO: Decide if when decoding I map based on type string to avoid having
                // either the mapped or unmapped based on edit
                return any as? T
            }
            return date as? T
        default:
            return any as? T
        }
    }
}
