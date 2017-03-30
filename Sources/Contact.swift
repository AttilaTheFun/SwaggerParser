import Foundation
import ObjectMapper

public struct Contact: ImmutableMappable {

    /// The identifying name of the contact person/organization.
    public let name: String?

    /// The URL pointing to the contact information.
    public let url: URL?

    /// The email address of the contact person/organization.
    public let email: String?

    public init(map: Map) throws {
        name = try map.value("name")
        url = try? map.value("url")
        email = try? map.value("email")
    }
}
