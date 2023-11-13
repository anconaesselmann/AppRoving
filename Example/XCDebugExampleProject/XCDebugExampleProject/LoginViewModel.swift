//  Created by Axel Ancona Esselmann on 11/12/23.
//

import Foundation
import Combine
import XcodeDebug

@MainActor
class LoginViewModel: ObservableObject {

    private var bag = Set<AnyCancellable>()

    init() {
        onXCDebugChange {
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
