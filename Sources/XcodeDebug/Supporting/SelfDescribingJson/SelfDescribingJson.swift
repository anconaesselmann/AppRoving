//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public struct SelfDescribingJson {

    public typealias JSON = [String: Any]

    public enum Keys: String {
        case name, key, properties, value
    }

    public var name: String, key: String
    public var properties: [String: Any]

    public init(_ data: Data) throws {
        guard
            let jsonDict = try JSONSerialization.jsonObject(with: data) as? JSON,
            let name: String = jsonDict[.name],
            let key:  String = jsonDict[.key],
            let properties: JSON = jsonDict[.properties]
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
        guard var properties = jsonData as? JSON else {
            throw CustomSettingsError.notAValidDictionary
        }
        name = T.name
        key  = T.key
        self.properties = properties
    }

    private func mapValue(_ any: Any) -> Any {
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

    public func data() throws -> Data {
        var dict = JSON()
        dict[.properties] = properties.reduce(into: JSON()) {
            $0[$1.key] = mapValue($1.value)
        }
        dict[.name] = name
        dict[.key]  = key
        return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }

    public func properties<T>(as type: T.Type) throws -> T
        where T: Decodable
    {
        let data = try JSONSerialization.data(withJSONObject: properties, options: .prettyPrinted)
        return try DefaultCoders.decoder.decode(T.self, from: data)
    }
}
