//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

public protocol XCDebugValueCompatible {
    var typeString: String { get }
}

public extension XCDebugValueCompatible {
    var typeString: String {
        (try? XCDebugValueType(type(of: self)).rawValue) ?? "INCOMPATIBLE"
    }
}
