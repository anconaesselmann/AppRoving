//  Created by Axel Ancona Esselmann on 11/14/23.
//

import Foundation

public extension Dictionary where Key == String {
    subscript(key: SelfDescribingJson.Keys) -> Value? {
        get {
            self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }

    subscript<T>(key: SelfDescribingJson.Keys) -> T? {
        get {
            self[key.rawValue] as? T
        }
        set {
            if newValue == nil {
                self[key.rawValue] = nil
            } else if let newValue = newValue as? Value {
                self[key.rawValue] = newValue
            }
        }
    }
}
