import Foundation
import ObjectMapper

public struct License: ImmutableMappable {

    /// The license name used for the API.
    public let name: String

    /// A URL to the license used for the API.
    public let url: URL?

    public init(map: Map) throws {
        name = try map.value("name")
        url = try? map.value("url")
        
    }
}
