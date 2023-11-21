//  Created by Axel Ancona Esselmann on 11/19/23.
//

import SwiftUI

struct ContentView: View {

#if DEBUG
    @StateObject
    var debug = XCDebugObserver()
#endif
    
    var body: some View {
        VStack {
            Text("Hello, world")
                .font(.headline)
            if XCDebug.get(\GeneralDebug.enableFootnote) {
                Text("Footnonte")
                    .font(.footnote)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
