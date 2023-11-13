//  Created by Axel Ancona Esselmann on 11/11/23.
//

import Foundation
import Combine

internal extension Task {
    func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
}
