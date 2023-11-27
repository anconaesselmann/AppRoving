//  Created by Axel Ancona Esselmann on 11/27/23.
//

import Foundation

public struct Version: CustomStringConvertible, Codable, Equatable {

    public enum Error: Swift.Error {
        case invalidComponents
    }

    public let major: Int
    public let minor: Int?
    public let patch: Int?

    public init(major: Int, minor: Int? = nil, patch: Int? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public init?(_ versionComponents: [Int]) {
        guard let major = versionComponents.first else {
            return nil
        }
        self.major = major
        self.minor = versionComponents[safe: 1]
        self.patch = versionComponents[safe: 2]
    }

    public init(_ versionString: String) throws {
        guard let fromComponents = Version(versionString.split(separator: ".").compactMap { Int($0) }) else {
            throw Error.invalidComponents
        }
        self = fromComponents
    }

    public var description: String {
        [major, minor, patch]
            .compactMap { $0 }
            .map { String($0) }
            .joined(separator: ".")
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let versionString = try container.decode(String.self)
        try self.init(versionString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let versionString = [major, minor, patch]
            .compactMap { $0 }
            .map { String($0) }
            .joined(separator: ".")
        try container.encode(versionString)
    }
}
