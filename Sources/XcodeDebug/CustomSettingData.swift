//  Created by Axel Ancona Esselmann on 11/10/23.
//

import Foundation

public struct CustomSettingData {
    public let name: String
    public let key: String
    public var dict: [String: Any]
}

public extension CustomSettingData {
    func data() throws -> Data {
        var dict = self.dict
        dict[Constants.displayName] = name
        dict[Constants.key] = key
        return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
}
