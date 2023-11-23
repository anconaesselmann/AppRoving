//  Created by Axel Ancona Esselmann on 11/19/23.
//

import Foundation

public struct BuildInfo: Codable {
    public let lastBuilt: Date
    public let appName: String?
    public let appVersion: String?
    public let buildVersion: String?

    public init(lastBuilt: Date, appName: String?, appVersion: String?, buildVersion: String?) {
        self.lastBuilt = lastBuilt
        self.appName = appName
        self.appVersion = appVersion
        self.buildVersion = buildVersion
    }
}
