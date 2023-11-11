//  Created by Axel Ancona Esselmann on 11/10/23.
//

import Foundation
import FileUrlExtensions

extension String {
    var lowercasingFirst: String { prefix(1).lowercased() + dropFirst() }
    var uppercasingFirst: String { prefix(1).uppercased() + dropFirst() }

    var camelCased: String {
        guard !isEmpty else { return "" }
        let parts = components(separatedBy: .alphanumerics.inverted)
        let first = parts.first!.lowercasingFirst
        let rest = parts.dropFirst().map { $0.uppercasingFirst }

        return ([first] + rest).joined()
    }
}

public protocol CustomDebugSettings: Codable {
    static var name: String { get }

    init()

    func data() throws -> Data
}

public extension CustomDebugSettings {
    static var fileName: String {
        key + ".json"
    }

    static var key: String {
        Self.name.camelCased
    }

    func updated(with data: Data) throws -> Self {
        try DefaultEncoders.decoder.decode(Self.self, from: data)
    }
}

public enum CustomSettingsError: Error {
    case notAValidDictionary
}

public extension CustomDebugSettings {
    func data() throws -> Data {
        let data = try DefaultEncoders.encoder.encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        guard var dict = jsonData as? [String: Any] else {
            throw CustomSettingsError.notAValidDictionary
        }
        return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
}

public struct CustomSettingData {
    public let name: String
    public var dict: [String: Any]
}

//extension CustomSettingData: Decodable {
//    init(from decoder: Decoder) throws {
//
//    }
//}

public extension Data {
    func decodeCustomSettingData() throws -> CustomSettingData {
        let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
        guard 
            var dict = jsonObject as? [String: Any],
            let name = dict["name"] as? String
        else {
            throw CustomSettingsError.notAValidDictionary
        }
        dict["name"] = nil
        return .init(name: name, dict: dict)
    }
}
