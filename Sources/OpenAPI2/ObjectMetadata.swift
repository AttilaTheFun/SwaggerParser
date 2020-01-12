import OpenAPI

public struct ObjectMetadata {

    /// The minimum number of properties. If set it must be a non-negative integer.
    public let minProperties: Int?

    /// The maximum number of properties. If set it must be a non-negative integer.
    public let maxProperties: Int?

    /// Adds support for polymorphism.
    /// The discriminator is the schema property name that is used to differentiate between other schema
    /// that inherit this schema. The property name used MUST be defined at this schema and it MUST be in the
    /// required property list. When used, the value MUST be the name of this schema or any schema that
    /// inherits it.
    public let discriminator: String?

    /// Determines whether or not the schema should be considered abstract. This
    /// can be used to indicate that a schema is an interface rather than a
    /// concrete model object.
    ///
    /// Corresponds to the boolean value for `x-abstract`. The default value is
    /// false.
    public let abstract: Bool
}

struct ObjectMetadataBuilder: Codable {
    let minProperties: Int?
    let maxProperties: Int?
    let discriminator: String?
    let abstract: Bool

    enum CodingKeys: String, CodingKey {
        case minProperties
        case maxProperties
        case discriminator
        case abstract = "x-abstract"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.minProperties = try values.decodeIfPresent(Int.self, forKey: .minProperties)
        self.maxProperties = try values.decodeIfPresent(Int.self, forKey: .maxProperties)
        self.discriminator = try values.decodeIfPresent(String.self, forKey: .discriminator)
        self.abstract = (try values.decodeIfPresent(Bool.self, forKey: .abstract)) ?? false
    }
}

extension ObjectMetadataBuilder: Builder {
    typealias Building = ObjectMetadata

    func build(_ swagger: SwaggerBuilder) throws -> ObjectMetadata {
        return ObjectMetadata(
            minProperties: self.minProperties,
            maxProperties: self.maxProperties,
            discriminator: self.discriminator,
            abstract: self.abstract)
    }
}

