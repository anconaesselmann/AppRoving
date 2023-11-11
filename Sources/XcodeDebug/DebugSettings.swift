//  Created by Axel Ancona Esselmann on 11/8/23.
//

import Foundation
import YetAnotherLogger

public struct DebugSettings: Codable {
    public var debugViews: Bool = false
    public var showViewNamesWhenDebugging: Bool = false
    public var showShowIdsWhenDebugging: Bool = false
    public var showRandomBackground: Bool = false
    public var supressLog: Bool = false
    public var supressDebug: Bool = false
    public var supressCritical: Bool = false
    public var supressTemp: Bool = false
    public var assertionFailuresEnabled: Bool = true
    public var subressed: Set<Logger.Priorities> {
        var result: [Logger.Priorities] = []
        if supressLog {
            result.append(.log)
        }
        if supressDebug {
            result.append(.debug)
        }
        if supressCritical {
            result.append(.critical)
        }
        if supressTemp {
            result.append(.temp)
        }
        return Set(result)
    }
    public var custom: [String: AnyCodable] = [:]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.debugViews = try container.decodeIfPresent(Bool.self, forKey: .debugViews) ?? false
        self.showViewNamesWhenDebugging = try container.decodeIfPresent(Bool.self, forKey: .showViewNamesWhenDebugging) ?? false
        self.showShowIdsWhenDebugging = try container.decodeIfPresent(Bool.self, forKey: .showShowIdsWhenDebugging) ?? false
        self.showRandomBackground = try container.decodeIfPresent(Bool.self, forKey: .showRandomBackground) ?? false
        self.supressLog = try container.decodeIfPresent(Bool.self, forKey: .supressLog) ?? false
        self.supressDebug = try container.decodeIfPresent(Bool.self, forKey: .supressDebug) ?? false
        self.supressCritical = try container.decodeIfPresent(Bool.self, forKey: .supressCritical) ?? false
        self.supressTemp = try container.decodeIfPresent(Bool.self, forKey: .supressTemp) ?? false
        self.assertionFailuresEnabled = try container.decodeIfPresent(Bool.self, forKey: .assertionFailuresEnabled) ?? true
        self.custom = try container.decodeIfPresent([String : AnyCodable].self, forKey: .custom) ?? [:]
    }

    public init() { }
}

public enum CodableValue: Codable {
    case bool(Bool)
    case int(Int)
    case double(Double)
}

public struct AnyCodable: Codable {
    var value: CodableValue
}
