//  Created by Axel Ancona Esselmann on 11/8/23.
//

import Foundation
import Combine

final public class XCDebugger: ObservableObject {

    public static let shared = XCDebugger()

    internal var onChange: (() -> Void)?
    internal var onLog: ((Result<String, Error>) -> Void)?

    private var urlWatchers: [URLWatcher] = []

    private var customSettings: [String: any DebugSettings] = [:]

    private var monitoring: Bool = false

    private var status: XCDebugStatus = XCDebugStatus()

    private var bag = Set<AnyCancellable>()

    private init() { }

    public func get<Settings, Value>(_ keyPath: KeyPath<Settings, Value>) -> Value?
        where Settings: DebugSettings
    {
        guard monitoring else {
            return nil
        }
        guard status.isEnabled(Settings.key) else {
            return nil
        }
        guard let settings = customSettings[Settings.key] as? Settings else {
            assertionFailure()
            return nil
        }
        return settings[keyPath: keyPath]
    }

    internal func startMonitoring() throws {
        let appInitFilePath = try URL.appInitFilePath()
        if !appInitFilePath.exists() {
            try XCDebugSetupInstructions.notify()
        }
        try AppInfo.saveAppIcon()
        try AppInfo.markBuildTime()

        try startMonitoringAppStatus()

        monitoring = true
    }

    @discardableResult
    public func register<Settings>(_ type: Settings.Type) throws -> Self
        where Settings: DebugSettings
    {
        let settings = Settings()
        let url = try URL.debugFolderLocation()
            .add(Settings.fileName)
        if url.exists() {
            try settings.updateFile(at: url)
        } else {
            try settings.writeToFile(at: url)
        }
        customSettings[Settings.key] = settings
        startMonitoring(customUrl: url)
        return self
    }

    public func stopMonitoring() {
        monitoring = false
        bag = Set()
        urlWatchers = []
    }

    private func startMonitoring(customUrl url: URL) {
        let watcher = URLWatcher(url: url, delay: 1)
        urlWatchers.append(watcher)
        watcher.sink { data in
            Task { @MainActor [weak self] in
                try self?.dataHasChanged(url: url, data: data)
            }
        } onError: { [weak self] error in
            self?.log(error)
        }.store(in: &bag)
    }

    @MainActor
    private func dataHasChanged(url: URL, data: Data) throws {
        let key = url.fileName
        guard var settings = customSettings[key] else {
            assertionFailure()
            return
        }
        customSettings[key] = try settings.updated(with: data)
        onChange?()
        objectWillChange.send()
    }

    private func startMonitoringAppStatus() throws {
        let url = try URL.appStatusFileLocation()
        if !url.exists() {
            let data = try status.data()
            try data.write(to: url)
        }
        let watcher = URLWatcher(url: url, delay: 1)
        urlWatchers.append(watcher)
        watcher.sink { data in
            Task { @MainActor [weak self] in
                try self?.appStatusHasChanged(data: data)
            }
        } onError: { [weak self] error in
            self?.log(error)
        }.store(in: &bag)
    }

    @MainActor
    private func appStatusHasChanged(data: Data) throws {
        status = try status.updated(with: data)
        onChange?()
        objectWillChange.send()
    }

    private func log(_ error: Error) {
        onLog?(.failure(error))
    }
    private func log(_ message: String) {
        onLog?(.success(message))
    }
}
