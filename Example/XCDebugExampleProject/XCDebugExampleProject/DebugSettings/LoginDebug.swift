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

    @XCDebugValue(caption: "A number", description: "This is a number")
    var aNumber: Int? = nil

    @XCDebugValue(caption: "A Double", description: "This is a Double")
    var aDouble: Double? = nil

    @XCDebugValue(caption: "An enum", description: "This is an enum")
    var anEnum: Screen = .loggedIn
}

struct GeneralDebug: DebugSettings {
    static let name: String = "General"

    @XCDebugValue
    var enableFootnote: Bool = false
}
