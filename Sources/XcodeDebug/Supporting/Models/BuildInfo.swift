//  Created by Axel Ancona Esselmann on 11/19/23.
//

import Foundation

public struct BuildInfo: Codable {
    public let lastBuilt: Date

    init(lastBuilt: Date) {
        self.lastBuilt = lastBuilt
    }
}
