import Foundation
import ObjectMapper

public struct License {

    /// The license name used for the API.
    public let name: String

    /// A URL to the license used for the API.
    public let url: URL?
}

struct LicenseBuilder: Builder {

    typealias Building = License

    let name: String
    let url: URL?

    init(map: Map) throws {
        name = try map.value("name")
        url = try? map.value("url")
    }

    func build(_ swagger: SwaggerBuilder) throws -> License {
        return License(name: name, url: url)
    }
}
