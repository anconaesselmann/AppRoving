//  Created by Axel Ancona Esselmann on 11/27/23.
//

import Foundation

extension Backport where Content == URL {
    func path(percentEncoded: Bool = true) -> String {
        if
            #available(iOS 16.0, *),
            #available(tvOS 16.0, *),
            #available(macOS 13.0, *),
            #available(watchOS 9.0, *) 
        {
            return content.path(percentEncoded: false)
        } else {
            return content.absoluteString
        }
    }
}

extension URL {
    var backport: Backport<URL> {
        Backport(self)
    }
}
