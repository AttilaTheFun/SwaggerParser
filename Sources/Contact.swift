import Foundation
import ObjectMapper

public struct Contact {

    /// The identifying name of the contact person/organization.
    public let name: String?

    /// The URL pointing to the contact information.
    public let url: URL?

    /// The email address of the contact person/organization.
    public let email: String?
}

struct ContactBuilder: Builder {

    typealias Building = Contact

    let name: String?
    let url: URL?
    let email: String?

    init(map: Map) throws {
        name = try map.value("name")
        url = try? map.value("url")
        email = try? map.value("email")
    }

    func build(_ swagger: SwaggerBuilder) throws -> Contact {
        return Contact(name: self.name, url: self.url, email: self.email)
    }
}
