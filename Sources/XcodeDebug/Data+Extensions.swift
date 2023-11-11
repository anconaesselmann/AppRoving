//  Created by Axel Ancona Esselmann on 11/10/23.
//

import Foundation

public extension Data {
    func decodeCustomSettingData() throws -> CustomSettingData {
        let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
        guard
            var dict = jsonObject as? [String: Any],
            let name = dict[Constants.displayName] as? String,
            let key = dict[Constants.key] as? String
        else {
            throw CustomSettingsError.notAValidDictionary
        }
        dict[Constants.displayName] = nil
        dict[Constants.key] = nil
        return .init(name: name, key: key, dict: dict)
    }
}
