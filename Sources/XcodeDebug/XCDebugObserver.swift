//  Created by Axel Ancona Esselmann on 11/21/23.
//

import Foundation
import Combine

public class XCDebugObserver: ObservableObject {

    private var bag: AnyCancellable?

    public init() {
        bag = XCDebugger.onChange { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
