
public struct Information {

    /// The title of the application.
    public let title: String

    /// A short description of the application.
    public let description: String?

    /// The Terms of Service for the API.
    public let termsOfService: String?

    /// The contact information for the exposed API.
    public let contact: Contact?

    /// The license information for the exposed API.
    public let license: License?

    /// Provides the version of the application API (not to be confused with the specification version).
    public let version: Version
}

struct InformationBuilder: Codable {
    let title: String
    let description: String?
    let termsOfService: String?
    let contact: ContactBuilder?
    let license: LicenseBuilder?
    let version: Version
}

extension InformationBuilder: Builder {
    typealias Building = Information

    func build(_ swagger: SwaggerBuilder) throws -> Information {
        return Information(title: self.title,
                           description: self.description,
                           termsOfService: self.termsOfService,
                           contact: try self.contact?.build(swagger),
                           license: try self.license?.build(swagger),
                           version: self.version)
    }
}
