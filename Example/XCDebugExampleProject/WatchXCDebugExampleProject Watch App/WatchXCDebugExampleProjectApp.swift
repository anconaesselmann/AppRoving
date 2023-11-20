//  Created by Axel Ancona Esselmann on 11/19/23.
//

import SwiftUI

#if DEBUG
import XcodeDebug
typealias XCDebug = XcodeDebug.XCDebugger
#else
import Combine
struct XCDebug {
    static func get<Settings>(_ keyPath: KeyPath<Settings, Bool>) -> Bool { false }
    static func get<Settings, Value>(_ keyPath: KeyPath<Settings, Value?>) -> Value? { nil }
    static var changed: AnyPublisher<(), Never> { Just(()).eraseToAnyPublisher() }
    static func onChange(_ onChange: @escaping () -> Void) -> AnyCancellable { AnyCancellable(Just(()).sink { _ in }) }
}
@propertyWrapper
struct XCDebugValue<T> { var wrappedValue: T }
protocol DebugSettings { }
#endif

@main
struct WatchXCDebugExampleProject_Watch_AppApp: App {

    init() {
#if DEBUG
        do {
            try XCDebugger.start {

            } onLog: {
                print($0)
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
