//  Created by Axel Ancona Esselmann on 11/21/23.
//

import Foundation

struct XCDebugSetupInstructions {
    static func notify() throws {
        #if os(macOS)
        try macOsNotify()
        #else
        try simulatorNotify()
        #endif
    }

    static func macOsNotify() throws {
        let appUrl = try URL.appLibraryDirectory()

        let message = """



‼️ AppRoving alert:
    Mac application has to be registered with AppRover.

Import-URL for AppRover:
    \(appUrl.backport.path(percentEncoded: false))


Note:
    To paste this URL in AppRover
    open the recource import dialogue (command + i),
    bring up the \"Go to:\" dialogue (command + shift + g)
    and paste the URL (command + v)

Note:
    If you already registered this simulator and this is
    the first time you are building your project after
    setting up AppRoving open or foreground AppRover
    and re-build your project.

"""
        print(message)
    }

    static func simulatorNotify() throws {
        guard let simulatorUrl = try URL.simulatorFolderLocation() else {
            return
        }

        let message = """



‼️ AppRoving alert:
    Simulator has to be registered with AppRover.

Import-URL for AppRover:
    \(simulatorUrl.backport.path(percentEncoded: false))


Note:
    To paste this URL in AppRover
    open the recource import dialogue (command + i),
    bring up the \"Go to:\" dialogue (command + shift + g)
    and paste the URL (command + v)

Note:
    If you already registered this simulator and this is
    the first time you are building your project after
    setting up AppRoving open or foreground AppRover
    and re-build your project.

"""
        print(message)
    }

}
