import Foundation

public struct Swagger {

    /// Specifies the Swagger Specification version being used. It can be used by the Swagger UI and other 
    /// clients to interpret the API listing. The value MUST be "2.0".
    public let version: Version

    /// Provides metadata about the API. The metadata can be used by the clients if needed.
    public let information: Information

    /// An array of Server Objects, which provide connectivity information to a target server.
    /// If the servers property is not provided, or is an empty array, the default value would be a Server Object with a url value of /.
    public let servers: [Server]?

    /// The available paths and operations for the API.
    public let paths: [String: Path]
    
    /// An element to hold various schemas for the specification.
    public let components: Components?

    /// A declaration of which security schemes are applied for the API as a whole.
    /// The list of values describes alternative security schemes that can be used 
    /// (that is, there is a logical OR between the security requirements). 
    /// Individual operations can override this definition.
    public let securityRequirements: [SecurityRequirement]

    /// A list of tags used by the specification with additional metadata. 
    /// The order of the tags can be used to reflect on their order by the parsing tools. 
    /// Not all tags that are used by the Operation must be declared.
    /// The tags that are not declared may be organized randomly or based on the tools' logic. 
    /// Each tag name in the list MUST be unique.
    public let tags: [Tag]

    /// Additional external documentation.
    public let externalDocumentation: ExternalDocumentation?
}

extension Swagger {
    public init(from string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw DecodingError("Unable to extract data from string in utf8 encoding")
        }

        let decoder = JSONDecoder()
        let builder = try decoder.decode(SwaggerBuilder.self, from: data)
        self = try builder.build(builder)
    }
}

struct SwaggerBuilder: Codable {
    let version: Version
    let informationBuilder: InformationBuilder
    let serverBuilders: [ServerBuilder]?
    let pathBuilders: [String: PathBuilder]
    let components: ComponentsBuilder?
    let securityRequirements: [SecurityRequirement]
    let tagBuilders: [TagBuilder]
    let externalDocumentationBuilder: ExternalDocumentationBuilder?

    enum CodingKeys: String, CodingKey {
        case version = "openapi"
        case information = "info"
        case servers
        case paths
        case components
        case security
        case tags
        case externalDocumentation = "externalDocs"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let decodedVersion = try values.decode(Version.self, forKey: .version)
        if decodedVersion.major != 3 || decodedVersion.minor != 0 {
            throw SwaggerVersionError()
        }

        self.version = decodedVersion
        self.informationBuilder = try values.decode(InformationBuilder.self, forKey: .information)
        self.serverBuilders = try values.decodeIfPresent([ServerBuilder].self, forKey: .servers)
        self.pathBuilders = try values.decode([String: PathBuilder].self, forKey: .paths)
        self.components = try values.decodeIfPresent(ComponentsBuilder.self, forKey: .components)
        self.securityRequirements = try values.decodeIfPresent([SecurityRequirement].self, forKey: .security) ?? []
        self.tagBuilders = try values.decodeIfPresent([TagBuilder].self, forKey: .tags) ?? []
        self.externalDocumentationBuilder = try values.decodeIfPresent(ExternalDocumentationBuilder.self,
                                                                       forKey: .externalDocumentation)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.version, forKey: .version)
        try container.encode(self.informationBuilder, forKey: .information)
        try container.encode(self.serverBuilders, forKey: .servers)
        try container.encode(self.securityRequirements, forKey: .security)
        try container.encode(self.tagBuilders, forKey: .tags)
        try container.encode(self.externalDocumentationBuilder, forKey: .externalDocumentation)
    }
}

extension SwaggerBuilder: Builder {
    typealias Building = Swagger

    func build(_ swagger: SwaggerBuilder) throws -> Swagger {

        // Pre-resolve and cache references to fix circular references:
        SchemaBuilder.resolver.setup()
        ParameterBuilder.resolver.setup()
        ResponseBuilder.resolver.setup()
        
        // If the servers property is not provided, or is an empty array,
        // the default value would be a Server Object with a url value of /.
        var servers = try self.serverBuilders?.map { try $0.build(swagger) }
        if servers?.isEmpty ?? true {
            servers = [Server(url: "/", description: "Default value", variables: nil)]
        }

        let paths = try self.pathBuilders.mapValues { try $0.build(swagger) }

        // Clean up resolvers:
        SchemaBuilder.resolver.teardown()
        ParameterBuilder.resolver.teardown()
        ResponseBuilder.resolver.teardown()

        let tags = try self.tagBuilders.map { try $0.build(swagger) }
        let externalDocumentation = try self.externalDocumentationBuilder?.build(swagger)
        return Swagger(
            version: self.version,
            information: try self.informationBuilder.build(swagger),
            servers: servers,
            paths: paths,
            components: try self.components?.build(swagger),
            securityRequirements: self.securityRequirements,
            tags: tags,
            externalDocumentation: externalDocumentation)
    }
}

