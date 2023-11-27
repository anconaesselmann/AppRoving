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



‼️ XcodeDebug alert:
    Mac application has to be registered with Xcode Debugger.

Import-URL for Xcode Debugger:
    \(appUrl.backport.path(percentEncoded: false))


Note:
    To paste this URL in Xcode Debugger
    open the recource import dialogue (command + i),
    bring up the \"Go to:\" dialogue (command + shift + g)
    and paste the URL (command + v)

Note:
    If you already registered this simulator and this is
    the first time you are building your project after
    setting up XCDebug open or foreground Xcode Debugger
    and re-build your project.

"""
        print(message)
    }

    static func simulatorNotify() throws {
        guard let simulatorUrl = try URL.simulatorFolderLocation() else {
            return
        }

        let message = """



‼️ XcodeDebug alert:
    Simulator has to be registered with Xcode Debugger.

Import-URL for Xcode Debugger:
    \(simulatorUrl.backport.path(percentEncoded: false))


Note:
    To paste this URL in Xcode Debugger
    open the recource import dialogue (command + i),
    bring up the \"Go to:\" dialogue (command + shift + g)
    and paste the URL (command + v)

Note:
    If you already registered this simulator and this is
    the first time you are building your project after
    setting up XCDebug open or foreground Xcode Debugger
    and re-build your project.

"""
        print(message)
    }

}
