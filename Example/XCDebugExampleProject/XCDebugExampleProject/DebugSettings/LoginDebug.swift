//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation
import AppRoving

enum IntEnum: Int, XCDebugEnum {
    case zero, one, two
}

enum DoubleEnum: Double, XCDebugEnum {
    case zero, one, two
}

extension Screen: XCDebugEnum { }

struct LoginDebug: DebugSettings {
    static let name: String = "Login"

    @XCDebugValue(caption: "User Name", description: "This is the user name")
    var userName: String?

    @XCDebugValue(caption: "Password", description: "This is the user's password")
    var password: String?

    @XCDebugValue(caption: "User birthday", description: "This is the date the user was born")
    var birthday: Date?

    @XCDebugValue(caption: "A number", description: "This is a number")
    var aNumber: Int?

    @XCDebugValue(caption: "A Double", description: "This is a Double")
    var aDouble: Double? = nil

    @XCDebugValue(caption: "An enum", description: "This is an enum")
    var anEnum: Screen? = .loggedIn

    @XCDebugValue(caption: "An int enum", description: "This is an int enum")
    var anIntEnum: IntEnum? = .zero

    @XCDebugValue(caption: "An double enum", description: "This is a double enum")
    var aDoubleEnum: DoubleEnum? = .zero
}

struct GeneralDebug: DebugSettings {
    static let name: String = "General"

    @XCDebugValue
    var enableFootnote: Bool = false
}
