//  Created by Axel Ancona Esselmann on 11/21/23.
//

import Foundation

struct XCDebugSetupInstructions {
    static func notify() {
        #if os(macOS)
        macOsNotify()
        #else
        simulatorNotify()
        #endif
    }

    static func macOsNotify() {
        print("App needs to be set up")
        assertionFailure()
    }

    static func simulatorNotify() {
        print("App needs to be set up")
        assertionFailure()
    }

}
