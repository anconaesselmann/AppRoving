//  Created by Axel Ancona Esselmann on 11/12/23.
//

import Foundation

public struct XCDebugStatus: Codable {

    public init() {
        self.disabled = Set<String>()
    }

    private var disabled: Set<String>

    public func updated(with data: Data) throws -> Self {
        return try DefaultCoders.decoder.decode(Self.self, from: data)
    }

    public func data() throws -> Data {
        try DefaultCoders.encoder.encode(self)
    }

    public func isEnabled(_ key: String) -> Bool {
        !disabled.contains(key)
    }

    public mutating func setStatus(for key: String, value isSet: Bool) {
        if isSet {
            disabled.remove(key)
        } else {
            disabled.insert(key)
        }
    }
}
