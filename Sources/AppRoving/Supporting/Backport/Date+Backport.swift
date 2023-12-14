//  Created by Axel Ancona Esselmann on 12/13/23.
//

import Foundation

extension Date {
    var backport: Backport<Date> {
        Backport(self)
    }
}

extension Backport where Content == Date {
    func ISO8601Format() -> String {
        if
            #available(iOS 15.0, *),
            #available(tvOS 15.0, *),
            #available(macOS 13.0, *),
            #available(watchOS 9.0, *)
        {
            return content.ISO8601Format()
        } else {
            return ""
        }
    }
}
