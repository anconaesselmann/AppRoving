//  Created by Axel Ancona Esselmann on 11/12/23.
//

import Foundation

public enum DebugSettingsError: Swift.Error {
    case invalidData
    case unregisteredFile
}

public extension DebugSettings {
    static var fileName: String {
        key + XCDebugConstants.jsonFileExtensions
    }

    static var key: String {
        Self.name.camelCased
    }

    func fromSelfDescribingData(_ data: Data) throws -> Self {
        try SelfDescribingJson(data)
            .properties(as: Self.self)
    }

    func selfDescribingData() throws -> Data {
        try SelfDescribingJson(self)
            .data()
    }
}
