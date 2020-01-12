import Foundation
import OpenAPI

private let kSchemaBuilderReferenceResolver = ReferenceResolver<SchemaBuilder>()
extension SchemaBuilder: ResolvableType {
    static var path: String { return "schemas" }
    static var resolver: ReferenceResolver<SchemaBuilder> { return kSchemaBuilderReferenceResolver }
}

private let kParameterBuilderReferenceResolver = ReferenceResolver<ParameterBuilder>()
extension ParameterBuilder: ResolvableType {
    static var path: String { return "parameters" }
    static var resolver: ReferenceResolver<ParameterBuilder> { return kParameterBuilderReferenceResolver }
}

private let kResponseBuilderReferenceResolver = ReferenceResolver<ResponseBuilder>()
extension ResponseBuilder: ResolvableType {
    static var path: String { return "responses" }
    static var resolver: ReferenceResolver<ResponseBuilder> { return kResponseBuilderReferenceResolver }
}

private let kSecuritySchemaBuilderReferenceResolver = ReferenceResolver<SecuritySchemaBuilder>()
extension SecuritySchemaBuilder: ResolvableType {
    static var path: String { return "securitySchemes" }
    static var resolver: ReferenceResolver<SecuritySchemaBuilder> { return kSecuritySchemaBuilderReferenceResolver }
}

private let kExampleBuilderReferenceResolver = ReferenceResolver<ExampleBuilder>()
extension ExampleBuilder: ResolvableType {
    static var path: String { return "examples" }
    static var resolver: ReferenceResolver<ExampleBuilder> { return kExampleBuilderReferenceResolver }
}

private let kRequestBodyBuilderReferenceResolver = ReferenceResolver<RequestBodyBuilder>()
extension RequestBodyBuilder: ResolvableType {
    static var path: String { return "requestBodies" }
    static var resolver: ReferenceResolver<RequestBodyBuilder> { return kRequestBodyBuilderReferenceResolver }
}

private let kHeaderBuilderReferenceResolver = ReferenceResolver<HeaderBuilder>()
extension HeaderBuilder: ResolvableType {
    static var path: String { return "headers" }
    static var resolver: ReferenceResolver<HeaderBuilder> { return kHeaderBuilderReferenceResolver }
}

private let kLinkBuilderReferenceResolver = ReferenceResolver<LinkBuilder>()
extension LinkBuilder: ResolvableType {
    static var path: String { return "links" }
    static var resolver: ReferenceResolver<LinkBuilder> { return kLinkBuilderReferenceResolver }
}

private let kCallbackBuilderReferenceResolver = ReferenceResolver<CallbackBuilder>()
extension CallbackBuilder: ResolvableType {
    static var path: String { return "callbacks" }
    static var resolver: ReferenceResolver<CallbackBuilder> { return kCallbackBuilderReferenceResolver }
}

public struct OpenAPI3 {

    /// Specifies the Swagger Specification version being used. It can be used by the Swagger UI and other
    /// clients to interpret the API listing. The value MUST be "3.0.*".
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

extension OpenAPI3 {
    public init(from string: String, decoder: StringDecoder = JSONDecoder()) throws {
        let builder = try decoder.decode(OpenAPI3Builder.self, from: string)
        self = try builder.build(builder)
    }
}

struct OpenAPI3Builder: Codable {
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

extension OpenAPI3Builder: Builder {
    typealias Building = OpenAPI3

    func build(_ swagger: SwaggerBuilder) throws -> OpenAPI3 {

        // Pre-resolve and cache references to fix circular references:
        let referenceResolvers: [Setupable] = [
            SchemaBuilder.resolver,
            ParameterBuilder.resolver,
            ResponseBuilder.resolver,
            SecuritySchemaBuilder.resolver,
            ExampleBuilder.resolver,
            RequestBodyBuilder.resolver,
            HeaderBuilder.resolver,
            LinkBuilder.resolver,
            CallbackBuilder.resolver
        ]
        referenceResolvers.forEach { $0.setup() }

        let components = try self.components?.build(swagger)

        // If the servers property is not provided, or is an empty array,
        // the default value would be a Server Object with a url value of /.
        var servers = try self.serverBuilders?.map { try $0.build(swagger) }
        if servers?.isEmpty ?? true {
            servers = [Server(url: "/", description: "Default value", variables: nil)]
        }

        let paths = try self.pathBuilders.mapValues { try $0.build(swagger) }
        let tags = try self.tagBuilders.map { try $0.build(swagger) }
        let externalDocumentation = try self.externalDocumentationBuilder?.build(swagger)
        
        // Clean up resolvers:
        referenceResolvers.forEach { $0.teardown() }

        return OpenAPI3(version: self.version,
                        information: try self.informationBuilder.build(swagger),
                        servers: servers,
                        paths: paths,
                        components: components,
                        securityRequirements: self.securityRequirements,
                        tags: tags,
                        externalDocumentation: externalDocumentation)
    }
}

extension OpenAPI3Builder: SwaggerBuilder {
    func resolveBuilderName(from components: [String], at path: String) throws -> String {
        guard components.count == 4 && components[0] == "#" && components[2] == path else {
            throw ResolverError.invalidPath
        }
        return components[3]
    }

    func resolveBuilder(for name: String, at path: String) throws -> Any? {
        switch path {
        case SchemaBuilder.path: return components?.schemas[name]
        case ParameterBuilder.path: return components?.parameters[name]
        case ResponseBuilder.path: return components?.responses[name]
        case SecuritySchemaBuilder.path: return components?.securitySchemes[name]
        case ExampleBuilder.path: return components?.examples[name]
        case RequestBodyBuilder.path: return components?.requestBodies[name]
        case HeaderBuilder.path: return components?.headers[name]
        case LinkBuilder.path: return components?.headers[name]
        case CallbackBuilder.path: return components?.callbacks[name]
        default: throw ResolverError.unsupportedReference
        }
    }
}
