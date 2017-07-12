import Foundation
import ObjectMapper

public struct SecurityRequirement: ImmutableMappable {
    public let name: String
    public let scopes: [String]

    public init(map: Map) throws {
        guard let name = map.JSON.keys.first else {
            throw DecodingError("SecurityRequirement: Name not found.")
        }

        self.name = name
        self.scopes = try map.value(name)
    }
}
