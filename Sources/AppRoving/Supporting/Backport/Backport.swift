//  Created by Axel Ancona Esselmann on 11/27/23.
//

import Foundation

struct Backport<Content> {
    let content: Content

    init(_ content: Content) {
        self.content = content
    }
}
