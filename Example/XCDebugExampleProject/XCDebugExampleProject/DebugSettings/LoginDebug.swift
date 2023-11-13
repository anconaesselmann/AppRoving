//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation
import XcodeDebug

struct LoginDebug: DebugSettings {
    static let name: String = "Login"

    @XCDebugValue
    var debugging: Bool = false

    @XCDebugValue
    var caption: String? = nil
}
