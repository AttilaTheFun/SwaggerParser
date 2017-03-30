import ObjectMapper

public struct Information: ImmutableMappable {

    /// The title of the application.
    let title: String

    /// A short description of the application.
    let description: String?

    /// The Terms of Service for the API.
    let termsOfService: String?

    /// The contact information for the exposed API.
    let contact: Contact?

    /// The license information for the exposed API.
    let license: License?

    /// Provides the version of the application API (not to be confused with the specification version).
    let version: Version

    public init(map: Map) throws {
        title = try map.value("title")
        description = try? map.value("description")
        termsOfService = try? map.value("termsOfService")
        contact = try? map.value("contact")
        license = try? map.value("license")
        version = try map.value("version", using: VersionTransform())
    }
}
