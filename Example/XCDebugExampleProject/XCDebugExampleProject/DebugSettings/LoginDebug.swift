//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation
import XcodeDebug

struct LoginDebug: DebugSettings {
    static let name: String = "Login"

    @XCDebugValue(caption: "User Name", description: "This is the user name")
    var userName: String? = nil

    @XCDebugValue(caption: "Password", description: "This is the user's password")
    var password: String? = nil

    @XCDebugValue(caption: "User birthday", description: "This is the date the user was born")
    var birthday: Date? = nil
}

struct GeneralDebug: DebugSettings {
    static let name: String = "General"

    @XCDebugValue
    var enableFootnote: Bool = false
}
