//  Created by Axel Ancona Esselmann on 11/11/23.
//

import Foundation
import Combine

public extension XCDebugger {
    static func start(_ onChange: (() -> Void)? = nil, onLog: (((Result<String, Error>)) -> Void)? = nil) throws {
        shared.onLog = onLog
        onChange?()
        try shared.startMonitoring()
        shared.onChange = onChange
    }

    static func stop() {
        shared.stopMonitoring()
    }

    static func get<Settings>(_ keyPath: KeyPath<Settings, Bool>) -> Bool
        where Settings: DebugSettings
    {
        shared.get(keyPath)
    }

    static func get<Settings, Value>(_ keyPath: KeyPath<Settings, Value?>) -> Value?
        where Settings: DebugSettings, Value: XCDebugValueCompatible
    {
        shared.get(keyPath)
    }

    static var changed: ObservableObjectPublisher {
        shared.objectWillChange
    }

    static func onChange(_ onChange: @escaping () -> Void) -> AnyCancellable {
        shared.objectWillChange.sink(receiveValue: onChange)
    }
}