//  Created by Axel Ancona Esselmann on 11/10/23.
//

import Foundation

public protocol DebugSettings: Codable {
    static var name: String { get }
    init()
}
