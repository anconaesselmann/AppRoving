//  Created by Axel Ancona Esselmann on 11/8/23.
//

import Foundation
import FileUrlExtensions
import Combine
import YetAnotherLogger

final public class XCDebugger: ObservableObject, Logging {

    public static let shared = XCDebugger()

    private var customUrlWatchers: [URLWatcher] = []

    private var bag = Set<AnyCancellable>()

    private init() { }

    public var onChange: (() -> Void)?

    public var hasChanged = PassthroughSubject<Void, Never>()

    private var customSettings: [String: any DebugSettings] = [:]

    private var monitoring: Bool = false

    public func get<Settings, Value>(_ keyPath: KeyPath<Settings, Value>) -> Value
        where Settings: DebugSettings
    {
        guard monitoring else {
            return Settings()[keyPath: keyPath]
        }
        var settings: Settings
        if let existing = customSettings[Settings.key] as? Settings {
            settings = existing
        }  else {
            settings = Settings()
            do {
                let url = try debugFolderLocation()
                    .add(Settings.fileName)
                if url.exists() {
                    let data = try Data(contentsOf: url, options: .mappedIfSafe)
                    settings = try settings.updated(with: data)
                } else {
                    let data = try settings.data()
                    try data.write(to: url)
                    startMonitoring(customUrl: url)
                }
                customSettings[Settings.key] = settings
            } catch {
                print(error)
            }
        }
        return settings[keyPath: keyPath]
    }

    public func startMonitoring() throws {
        let directoryUrl = try debugFolderLocation()
        stopMonitoring()
        monitoring = true
        let urls = (directoryUrl.subdirectories ?? [])
            .filter { $0.fileExtension.lowercased() == "json" }

        for url in urls {
            startMonitoring(customUrl: url)
        }
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
                        customSettings[key] = try settings.updated(with: data)
                        self.onChange?()
                        Task { @MainActor in
                            self.hasChanged.send()
                            self.objectWillChange.send()
                        }
                    }
                }
            } catch {
                critical(error)
            }
        }
        .eraseToAnyCancellable()
        .store(in: &bag)
        customUrlWatchers.append(watcher)
        log("Watching XCDebug settings at: \(url.path(percentEncoded: false))")
    }

    public func stopMonitoring() {
        monitoring = false
        bag = Set()
        customUrlWatchers = []
    }

    private func debugFolderLocation() throws -> URL {
        try URL.appLibraryDirectory()
            .appendingPathComponent("debug")
            .create()
    }
}
