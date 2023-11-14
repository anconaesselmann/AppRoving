//  Created by Axel Ancona Esselmann on 11/11/23.
//

import SwiftUI

struct ContentView: View {

#if DEBUG
    @StateObject
    var debugger = XCDebug.shared
#endif

    @StateObject
    var navManager = NavManager.shared

    var body: some View {
        NavigationStack(path: $navManager.path) {
            VStack {
                GroupBox {
                    Text("Hello, world!")
                        .font(.headline)
                    if XCDebug.get(\GeneralDebug.enableFootnote) {
                        Text("Footnonte")
                            .font(.footnote)
                    }
                } label: {
                    Text("General")
                }
                GroupBox {
                    LoginView()
                } label: {
                    Text("Login")
                }
                Spacer()
            }
            .padding()
            .navigationDestination(for: Screen.self) { i in
                Text("Logged in")
            }
        }
    }
}
