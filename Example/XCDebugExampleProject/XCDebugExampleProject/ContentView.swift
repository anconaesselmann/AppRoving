//  Created by Axel Ancona Esselmann on 11/11/23.
//

import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {

    private var bag = Set<AnyCancellable>()

    init() {
        XCDebugger.shared.objectWillChange.sink {
            self.objectWillChange.send()
        }.store(in: &bag)
    }

    var name: String {
        if XCDebug(\LoginDebug.debugging) {
            return XCDebug(\LoginDebug.name)
        } else {
            return "NA"
        }
    }
}

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

import XcodeDebug

struct LoginDebug: CustomDebugSettings {
    static let name: String = "Login"

    var debugging: Bool = false
    var name: String = ""
}
