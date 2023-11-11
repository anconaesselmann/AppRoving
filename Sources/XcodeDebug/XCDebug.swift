//  Created by Axel Ancona Esselmann on 11/11/23.
//

import Foundation

public func XCDebugStart(_ onChange: @escaping () -> Void) throws {
    onChange()
    try XCDebugger.shared.startMonitoring()
    XCDebugger.shared.onChange = onChange
}

public func XCDebugStop() {
    XCDebugger.shared.stopMonitoring()
}

public func XCDebug<Settings, Value>(_ keyPath: KeyPath<Settings, Value>) -> Value
    where Settings: CustomDebugSettings
{
    XCDebugger.shared.get(keyPath)
}
