//  Created by Axel Ancona Esselmann on 11/12/23.
//

import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {

    private var bag = Set<AnyCancellable>()

    init() {
#if DEBUG
        XCDebug.onChange {
            self.objectWillChange.send()
        }.store(in: &bag)
#endif
    }

    var name: String {
        XCDebug.get(\LoginDebug.caption) ?? "NA"
    }
}
