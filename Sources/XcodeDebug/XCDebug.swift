//  Created by Axel Ancona Esselmann on 11/11/23.
//

import Foundation
import Combine


public extension XCDebugger {

    @discardableResult
    func start() throws -> Self {
        onChange?()
        try startMonitoring()
        self.onChange = onChange
        return self
    }

    @discardableResult
    func onChange(_ onChange: @escaping () -> Void) -> Self {
        self.onChange = onChange
        onChange()
        return self
    }

    @discardableResult
    func onLog(onLog: @escaping (Result<String, Error>) -> Void) -> Self {
        self.onLog = onLog
        return self
    }

    static func register<Settings>(_ type: Settings.Type) throws -> XCDebugger
        where Settings: DebugSettings
    {
        try shared.register(type)
    }

    @discardableResult
    static func stop() -> XCDebugger {
        shared.stopMonitoring()
        return shared
    }

    @discardableResult
    static func get<Settings>(_ keyPath: KeyPath<Settings, Bool>) -> Bool
        where Settings: DebugSettings
    {
        shared.get(keyPath) ?? false
    }

    static func get<Settings, Value>(_ keyPath: KeyPath<Settings, Value?>) -> Value?
        where Settings: DebugSettings, Value: Codable
    {
        if let value = shared.get(keyPath) {
            return value
        } else {
            return nil
        }
    }

    static func get<Settings, Value>(_ keyPath: KeyPath<Settings, Value>) -> Value?
        where Settings: DebugSettings, Value: Codable
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
