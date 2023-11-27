//  Created by Axel Ancona Esselmann on 11/26/23.
//

import Foundation

struct AppInfo {
    static func saveAppIcon() throws {
        if let appIconData = Data(pngDataFor: "AppIcon") {
            let iconLocation = try URL.xcdebugSettingsFolderLocation()
                .add("AppIcon.png")
            try appIconData.write(to: iconLocation)
        }
    }

    static func markBuildTime() throws {
        let url = try URL.buildTimeFileLocation()
        let bundle = Bundle.main
        let buildInfo = BuildInfo(
            lastBuilt: Date(),
            appName: bundle.displayName,
            appVersion: bundle.appVersion,
            buildVersion: bundle.buildVersion
        )
        let data = try DefaultCoders.encoder.encode(buildInfo)
        try data.write(to: url)
    }
}
