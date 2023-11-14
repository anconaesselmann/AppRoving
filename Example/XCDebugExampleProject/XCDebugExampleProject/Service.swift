//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation

struct Service {
    func logIn(email: String, password: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
