//  Created by Axel Ancona Esselmann on 11/13/23.
//

import SwiftUI
import Combine

@MainActor
class NavManager: ObservableObject {

    var bag = Set<AnyCancellable>()

    static let shared = NavManager()

    @Published
    @MainActor
    var path: [Screen] = []

    private init() {
        XCDebug.changed.sink {
            self.updateAfterRemoteScreenChangeRequest()
        }.store(in: &bag)
    }

    func updateAfterRemoteScreenChangeRequest() {
        if let screen = XCDebug.get(\LoginDebug.anEnum) {
            Task { @MainActor in
                if let index = path.firstIndex(where: { existing in
                    existing.rawValue == screen.rawValue
                }) {
                    if path.last != screen {
                        path = Array(path[0...index])
                    }
                } else {
                    path.append(screen)
                }
            }
        } else {
            Task { @MainActor in
                path = []
            }
        }
    }
}
