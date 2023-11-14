//  Created by Axel Ancona Esselmann on 11/13/23.
//

import SwiftUI

class NavManager: ObservableObject {

    private init() {}

    static let shared = NavManager()

    @Published
    @MainActor
    var path = NavigationPath()
}
