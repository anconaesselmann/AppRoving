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
            do {
                // Remove this
                let url = try URL.debugFolderLocation()
                    .add(Settings.fileName)
                guard url.exists() else {
                    log(DebugSettingsError.unregisteredFile)
                    assertionFailure()
                    return nil
                }
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                settings = try Settings().fromSelfDescribingData(data)
                customSettings[Settings.key] = settings
            } catch {
                log(error)
                settings = Settings()
            }
        }
        guard status.isEnabled(Settings.key) else {
            return nil
        }
        return settings[keyPath: keyPath]
    }

    internal func startMonitoring() throws {
        try AppInfo.saveAppIcon()
        let appInitializationStatusFileLocation = try URL.appInitializationStatusFileLocation()
        if !appInitializationStatusFileLocation.exists() {
            try XCDebugSetupInstructions.notify()
        }
        monitoring = true

        try startMonitoringSettings()
        try AppInfo.markBuildTime()
    }

    @discardableResult
    public func register<Settings>(_ type: Settings.Type) throws -> Self
        where Settings: DebugSettings
    {
        let url = try URL.debugFolderLocation()
            .add(Settings.fileName)
        let settings: Settings
        if url.exists() {
            let comparisonData = try Settings().selfDescribingData()
            guard
                let jsonDict = try JSONSerialization.jsonObject(with: comparisonData) as? SelfDescribingJson.JSON,
                let comparisonProperties: SelfDescribingJson.JSON = jsonDict[.properties]
            else {
                throw DebugSettingsError.invalidData
            }
            let comparisonKeys = Set(comparisonProperties.keys)
            let existingData = try Data(contentsOf: url, options: .mappedIfSafe)
            guard
                var jsonDict = try JSONSerialization.jsonObject(with: existingData) as? SelfDescribingJson.JSON,
                var properties: SelfDescribingJson.JSON = jsonDict[.properties]
            else {
                throw DebugSettingsError.invalidData
            }
            let keys = Set(properties.keys)

            let missingKeys = comparisonKeys.subtracting(keys)
            let obsoleteKeys = keys.subtracting(comparisonKeys)
            if !(missingKeys.isEmpty && obsoleteKeys.isEmpty) {
                for missingKey in missingKeys {
                    properties[missingKey] = comparisonProperties[missingKey]
                }
                for obsoleteKey in obsoleteKeys {
                    properties.removeValue(forKey: obsoleteKey)
                }
            }
            for key in keys {
                if
                    var value = properties[key] as? SelfDescribingJson.JSON,
                    let comparisonValue = comparisonProperties[key] as? SelfDescribingJson.JSON,
                    let type = value["type"] as? String,
                    let comparisonType = comparisonValue["type"] as? String,
                    type == comparisonType,
                    let nullable = value["nullable"] as? Bool,
                    let comparisonNullable = comparisonValue["nullable"] as? Bool,
                    nullable == comparisonNullable
                {
                    continue
                } else {
                    properties[key] = comparisonProperties[key]
                }
            }
            jsonDict[.properties] = properties
            let data = try JSONSerialization.data(
                withJSONObject: jsonDict,
                options: [.sortedKeys, .prettyPrinted]
            )
            settings = try Settings().fromSelfDescribingData(data)
            try data.write(to: url)
        } else {
            settings = Settings()
            let data = try settings.selfDescribingData()
            try data.write(to: url)
        }
        customSettings[Settings.key] = settings
        startMonitoring(customUrl: url)
        return self
    }

    public func stopMonitoring() {
        monitoring = false
        bag = Set()
        customUrlWatchers = []
        statusUrlWatcher = nil
    }

    internal func startMonitoring(customUrl url: URL) {
        let watcher = URLWatcher(url: url, delay: 1)
        Task { [weak self] in
            guard let self = self else {
                return
            }
            do {
                let key = url.fileName
                for try await data in watcher {
                    if let settings = customSettings[key] {
                        customSettings[key] = try settings.fromSelfDescribingData(data)
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
