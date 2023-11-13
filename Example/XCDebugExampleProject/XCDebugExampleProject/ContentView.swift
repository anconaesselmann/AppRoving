//  Created by Axel Ancona Esselmann on 11/11/23.
//

import SwiftUI
import XcodeDebug

struct ContentView: View {

    @StateObject
    var debugger = XCDebugger.shared

    @StateObject
    var vm = LoginViewModel()

    var body: some View {
        VStack {
            if XCDebug(\LoginDebug.debugging) {
                Text("Debugging")
            }
            Text("Hello, world!")
            Text(vm.name)
        }
        .padding()
    }
}
