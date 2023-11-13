//  Created by Axel Ancona Esselmann on 11/11/23.
//

import SwiftUI

struct ContentView: View {

#if DEBUG
    @StateObject
    var debugger = XCDebug.shared
#endif

    @StateObject
    var vm = LoginViewModel()

    var body: some View {
        VStack {
            if XCDebug.get(\LoginDebug.debugging) {
                Text("Debugging")
            }
            Text("Hello, world!")
            Text(vm.name)
        }
        .padding()
    }
}
