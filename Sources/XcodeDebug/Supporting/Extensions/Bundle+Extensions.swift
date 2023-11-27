//  Created by Axel Ancona Esselmann on 11/22/23.
//

import Foundation

internal extension Bundle {
    var appName: String {
        bundleIdentifier?.components(separatedBy: ".").last ?? ""
    }
    
    var displayName: String? {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
