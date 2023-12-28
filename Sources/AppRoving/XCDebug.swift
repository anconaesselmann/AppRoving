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

    static func getEvents<Settings, Value>(_ keyPath: KeyPath<Settings, XCDebugValue<Value>>) -> [(UUID, Value)]
        where Settings: DebugSettings, Value: Codable, Value: XCDebugEvent
    {
        shared.getEvents(keyPath)
    }

    static var changed: ObservableObjectPublisher {
        shared.objectWillChange
    }

    static func onChange(_ onChange: @escaping () -> Void) -> AnyCancellable {
        shared.objectWillChange.sink(receiveValue: onChange)
    }
}

public func update<Object: AnyObject, Settings: DebugSettings>(
    _ object: Object,
    using type: Settings.Type
) -> ARSubscription<Object, Settings> {
    ARSubscription(
        settingsType: type,
        object: object,
        perform: []
    )
}

public struct ARSubscription<Object: AnyObject, Settings: DebugSettings> {
    internal var settingsType: Settings.Type
    internal weak var object: Object?
    internal var perform: [() -> Void]
    internal var updater: Updater = Updater()

    internal class Updater {
        internal var onUpdate: (() -> Void)? = nil

        internal func update() {
            onUpdate?()
        }
    }

    public func notify<O: ObservableObjectPublisher>(_ publisher: O) -> Self {
        updater.onUpdate = { [weak publisher] in
            publisher?.send()
        }
        return self
    }

    public func bind<Value: Codable>(
        _ settingsKeyPath: KeyPath<Settings, Value?>,
        _ keyPath: ReferenceWritableKeyPath<Object, Value>,
        default defaultValue: Value? = nil
    ) -> ARSubscription {
        var onChange = { [weak object] in
            if let value: Value = XCDebugger.get(settingsKeyPath) {
                object?[keyPath: keyPath] = value
                updater.update()
            } else if let defaultValue = defaultValue {
                object?[keyPath: keyPath] = defaultValue
                updater.update()
            }
        }
        return ARSubscription(
            settingsType: settingsType,
            object: object,
            perform: perform + [onChange],
            updater: updater
        )
    }

    public func on<Value>(
        _ settingsKeyPath: KeyPath<Settings, XCDebugValue<Value>>,
        call action: @escaping (Value) -> Void
    ) -> Self 
        where Value: XCDebugEvent
    {
        let action = action
        var onChange = {
            let events = XCDebugger.getEvents(settingsKeyPath)
            while let new = EventProcessor.shared.process(events) {
                action(new)
            }
        }
        return ARSubscription(
            settingsType: settingsType,
            object: object,
            perform: perform + [onChange],
            updater: updater
        )
    }

    @discardableResult
    public func store(in set: inout Set<AnyCancellable>) -> Self {
        let onChange = {
            for action in perform {
                action()
            }
        }
        let subscription = XCDebugger.onChange(onChange)
        set.insert(subscription)
        return self
    }

    @discardableResult
    public func run() -> Self {
        for action in perform {
            action()
        }
        return self
    }
}

private class EventProcessor {
    static let shared = EventProcessor()

    var uuids = Set<UUID>()

    func process<V>(_ events: [(UUID, V)]) -> V? {
        var processed = Set<UUID>()
        for (uuid, event) in events {
            if uuids.contains(uuid) {
                processed.insert(uuid)
            } else {
                processed.insert(uuid)
                uuids = processed
                return event
            }
        }
        return nil
    }
}
