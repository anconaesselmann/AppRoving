//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

enum EventId: String {
    case loginButton = "086715e1-a939-410c-afb8-11d5b4935cec"

    var uuid: UUID {
        UUID(uuidString: self.rawValue)!
    }
}
