import Foundation

public struct License {

    /// The license name used for the API.
    public let name: String

    /// A URL to the license used for the API.
    public let url: URL?
}

public struct LicenseBuilder: Codable {
    let name: String
    let url: URL?
}

extension LicenseBuilder: Builder {
    public typealias Building = License

    public func build(_ swagger: SwaggerBuilder) throws -> License {
        return License(name: self.name, url: self.url)
    }
}
