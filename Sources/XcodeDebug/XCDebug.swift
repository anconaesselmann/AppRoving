//  Created by Axel Ancona Esselmann on 11/11/23.
//

import Foundation
import Combine

public func XCDebugStart(_ onChange: @escaping () -> Void) throws {
    onChange()
    try XCDebugger.shared.startMonitoring()
    XCDebugger.shared.onChange = onChange
}

public func XCDebugStop() {
    XCDebugger.shared.stopMonitoring()
}

public func XCDebug<Settings, Value>(_ keyPath: KeyPath<Settings, Value>) -> Value
    where Settings: DebugSettings
{
    XCDebugger.shared.get(keyPath)
}

public func XCDebug<Settings, Value>(_ keyPath: KeyPath<Settings, Value?>) -> Value?
    where Settings: DebugSettings
{
    XCDebugger.shared.get(keyPath)
}

public extension XCDebugger {
    static var change: ObservableObjectPublisher {
        XCDebugger.shared.objectWillChange
    }
}

public var XCDebugChanges: ObservableObjectPublisher {
    XCDebugger.shared.objectWillChange
}

public func onXCDebugChange(_ onChange: @escaping () -> Void) -> AnyCancellable {
    XCDebugger.shared.objectWillChange.sink(receiveValue: onChange)
}


import FileUrlExtensions

struct Status: Codable {

    init() {
        self.enabled = Set<String>()
    }

    var enabled: Set<String>

    func updated(with data: Data) throws -> Self {
        return try DefaultEncoders.decoder.decode(Self.self, from: data)
    }

    func data() throws -> Data {
        try DefaultEncoders.encoder.encode(self)
    }

    func isEnabled(_ key: String) -> Bool {
        enabled.contains(key)
    }
}
