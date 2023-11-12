//  Created by Axel Ancona Esselmann on 11/11/23.
//

import SwiftUI
import XcodeDebug

@main
struct XCDebugExampleProjectApp: App {

    #if DEBUG
    init() {
        do {
            try XCDebugStart {

            }
        } catch {
            print(error)
        }
    }
    #endif


    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
