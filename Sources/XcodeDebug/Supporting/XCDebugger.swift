//  Created by Axel Ancona Esselmann on 11/8/23.
//

import Foundation
import Combine

final public class XCDebugger: ObservableObject {

    public static let shared = XCDebugger()

    public var onChange: (() -> Void)?
    public var onLog: ((Result<String, Error>) -> Void)?

    public var hasChanged = PassthroughSubject<Void, Never>()

    private var customUrlWatchers: [URLWatcher] = []
    private var statusUrlWatcher: URLWatcher?

    private var customSettings: [String: any DebugSettings] = [:]

    private var monitoring: Bool = false

    private var status: XCDebugStatus = XCDebugStatus()

    private var bag = Set<AnyCancellable>()

    private init() { }

    @MainActor
    public func get<Settings, Value>(_ keyPath: KeyPath<Settings, Value>) -> Value?
        where Settings: DebugSettings
    {
        guard monitoring else {
            return nil
        }
        var settings: Settings
        if let existing = customSettings[Settings.key] as? Settings {
            settings = existing
        }  else {
            settings = Settings()
            do {
                let url = try URL.debugFolderLocation()
                    .add(Settings.fileName)
                if url.exists() {
                    let data = try Data(contentsOf: url, options: .mappedIfSafe)
                    settings = try settings.fromSelfDescribingData(data)
                } else {
                    let data = try settings.selfDescribingData()
                    try data.write(to: url)
                    startMonitoring(customUrl: url)
                }
                customSettings[Settings.key] = settings // Todo: saw crash here. Likely needs to be isolated to a serial thread
            } catch {
                log(error)
            }
        }
        guard status.isEnabled(Settings.key) else {
            return nil
        }
        return settings[keyPath: keyPath]
    }

    public func startMonitoring() throws {
        // TODO: Create all settings files here. Don't create when accessing.
        let appInitializationStatusFileLocation = try URL.appInitializationStatusFileLocation()
        if !appInitializationStatusFileLocation.exists() {
            try XCDebugSetupInstructions.notify()
        }
        let directoryUrl = try URL.debugFolderLocation()
        stopMonitoring()
        monitoring = true
        let urls = (directoryUrl.subdirectories ?? [])
            .filter { $0.fileExtension.lowercased() == "json" }

        try startMonitoringSettings()
        for url in urls {
            startMonitoring(customUrl: url)
        }
        try markBuildTime()
    }

    private func markBuildTime() throws {
        let url = try URL.buildTimeFileLocation()
        let buildInfo = BuildInfo(lastBuilt: .now)
        let data = try DefaultCoders.encoder.encode(buildInfo)
        try data.write(to: url)
    }

    public func stopMonitoring() {
        monitoring = false
        bag = Set()
        customUrlWatchers = []
        statusUrlWatcher = nil
    }

    private func startMonitoring(customUrl url: URL) {
        let watcher = URLWatcher(url: url, delay: 1)
        Task { [weak self] in
            guard let self = self else {
                return
            }
            do {
                let key = url.fileName
                for try await data in watcher {
                    if let settings = customSettings[key] {
                        customSettings[key] = try settings.fromSelfDescribingData(data) // TODO: crashes after debug folder is whiped
                        self.onChange?()
                        Task { @MainActor in
                            self.hasChanged.send()
                            self.objectWillChange.send()
                        }
                    }
                }
            } catch {
                log(error)
            }
        }
        .eraseToAnyCancellable()
        .store(in: &bag)
        customUrlWatchers.append(watcher)
    }

    private func startMonitoringSettings() throws {
        let url = try URL.appStatusFileLocation()
        if !url.exists() {
            let data = try status.data()
            try data.write(to: url)
            startMonitoring(customUrl: url)
        }
        let watcher = URLWatcher(url: url, delay: 1)
        Task { [weak self] in
            guard let self = self else {
                return
            }
            do {
                for try await data in watcher {
                    self.status = try self.status.updated(with: data)
                    self.onChange?()
                    Task { @MainActor in
                        self.hasChanged.send()
                        self.objectWillChange.send()
                    }
                }
            } catch {
                log(error)
            }
        }
        .eraseToAnyCancellable()
        .store(in: &bag)
        statusUrlWatcher = watcher
    }

    private func log(_ error: Error) {
        onLog?(.failure(error))
    }
    private func log(_ message: String) {
        onLog?(.success(message))
    }
}
