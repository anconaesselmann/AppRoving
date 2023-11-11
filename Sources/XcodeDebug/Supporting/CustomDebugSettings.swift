//  Created by Axel Ancona Esselmann on 11/10/23.
//

import Foundation
import FileUrlExtensions

public protocol CustomDebugSettings: Codable {
    static var name: String { get }
    init()
}

public extension CustomDebugSettings {
    static var fileName: String {
        key + Constants.jsonFileExtensions
    }

    static var key: String {
        Self.name.camelCased
    }

    func updated(with data: Data) throws -> Self {
        try DefaultEncoders.decoder.decode(Self.self, from: data)
    }

    func data() throws -> Data {
        let data = try DefaultEncoders.encoder.encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        guard var dict = jsonData as? [String: Any] else {
            throw CustomSettingsError.notAValidDictionary
        }
        dict[Constants.displayName] = Self.name
        dict[Constants.key] = Self.key
        return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
}
