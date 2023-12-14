//  Created by Axel Ancona Esselmann on 11/27/23.
//

import Foundation
import Combine

extension URLWatcher {
    func sink(
        receiveValue: @escaping ((Self.Element) throws -> Void),
        onError: ((Error) -> Void)? = nil
    ) -> AnyCancellable {
        Task {
            do {
                for try await data in self {
                    try receiveValue(data)
                }
            } catch {
                onError?(error)
            }
        }
        .eraseToAnyCancellable()
    }
}
