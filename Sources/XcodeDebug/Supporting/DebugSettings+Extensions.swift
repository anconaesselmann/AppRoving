//  Created by Axel Ancona Esselmann on 11/12/23.
//

import Foundation
import FileUrlExtensions

public extension DebugSettings {
    static var fileName: String {
        key + XCDebugConstants.jsonFileExtensions
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
        dict[XCDebugConstants.displayName] = Self.name
        dict[XCDebugConstants.key] = Self.key
        return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
}
