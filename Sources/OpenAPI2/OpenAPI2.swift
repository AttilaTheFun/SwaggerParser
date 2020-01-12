import Foundation
import OpenAPI

private let kSchemaBuilderReferenceResolver = ReferenceResolver<SchemaBuilder>()
extension SchemaBuilder: ResolvableType {
    static var path: String { return "definitions" }
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

public struct OpenAPI2 {

    /// Specifies the Swagger Specification version being used. It can be used by the Swagger UI and other 
    /// clients to interpret the API listing. The value MUST be "2.0".
    public let version: Version

    /// Provides metadata about the API. The metadata can be used by the clients if needed.
    public let information: Information

    /// The host (name or ip) serving the API. This MUST be the host only and does not include the scheme nor 
    /// sub-paths. It MAY include a port. If the host is not included, the host serving the documentation is 
    /// to be used (including the port).
    public let host: URL?

    /// The base path on which the API is served, which is relative to the host. 
    /// If it is not included, the API is served directly under the host. 
    /// The value MUST start with a leading slash (/). 
    /// The basePath does not support path templating.
    public let basePath: String?

    /// The transfer protocol of the API.
    /// If the schemes is not included, the default scheme to be used is the one used to 
    /// access the Swagger definition itself.
    public let schemes: [TransferScheme]?

    /// A list of MIME types the APIs can consume. 
    /// This is global to all APIs but can be overridden on specific API calls.
    public let consumes: [String]

    /// A list of MIME types the APIs can produce.
    /// This is global to all APIs but can be overridden on specific API calls.
    public let produces: [String]

    /// The available paths and operations for the API.
    public let paths: [String: Path]

    /// An object to hold data types produced and consumed by operations.
    public let definitions: [String: Schema]

    /// An object to hold parameters that can be used across operations.
    /// This property does NOT define global parameters for all operations.
    public let parameters: [String: Parameter]

    /// An object to hold responses that can be used across operations.
    /// This property does NOT define global responses for all operations.
    public let responses: [String: Response]

    /// Declares the security schemes to be used in the specification.
    /// This does not enforce the security schemes on the operations and only serves to provide the relevant 
    /// details for each scheme.
    public let securityDefinitions: [String : SecuritySchema]

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

extension OpenAPI2 {
    public init(from string: String, decoder: StringDecoder = JSONDecoder()) throws {
        let builder = try decoder.decode(OpenAPI2Builder.self, from: string)
        self = try builder.build(builder)
    }
}

struct OpenAPI2Builder: Codable {
    let version: Version
    let informationBuilder: InformationBuilder
    let host: URL?
    let basePath: String?
    let schemes: [TransferScheme]?
    let consumes: [String]
    let produces: [String]
    let pathBuilders: [String: PathBuilder]
    let definitionBuilders: [String: SchemaBuilder]
    let parameterBuilders: [String: ParameterBuilder]
    let responseBuilders: [String: ResponseBuilder]
    let securityDefinitionBuilders: [String: SecuritySchemaBuilder]
    let securityRequirements: [SecurityRequirement]
    let tagBuilders: [TagBuilder]
    let externalDocumentationBuilder: ExternalDocumentationBuilder?

    enum CodingKeys: String, CodingKey {
        case version = "swagger"
        case information = "info"
        case host
        case basePath
        case schemes
        case consumes
        case produces
        case paths
        case definitions
        case parameters
        case responses
        case securityDefinitions
        case security
        case tags
        case externalDocumentation = "externalDocs"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let decodedVersion = try values.decode(Version.self, forKey: .version)
        if decodedVersion.major != 2 || decodedVersion.minor != 0 || decodedVersion.patch != nil {
            throw SwaggerVersionError()
        }

        self.version = decodedVersion
        self.informationBuilder = try values.decode(InformationBuilder.self, forKey: .information)
        self.host = try values.decodeIfPresent(URL.self, forKey: .host)
        self.basePath = try values.decodeIfPresent(String.self, forKey: .basePath)
        self.schemes = try values.decodeIfPresent([TransferScheme].self, forKey: .schemes)
        self.consumes = try values.decodeIfPresent([String].self, forKey: .consumes) ?? []
        self.produces = try values.decodeIfPresent([String].self, forKey: .produces) ?? []
        self.pathBuilders = try values.decode([String: PathBuilder].self, forKey: .paths)
        self.definitionBuilders = try values.decodeIfPresent([String: SchemaBuilder].self,
                                                      forKey: .definitions) ?? [:]
        self.parameterBuilders = try values.decodeIfPresent([String: ParameterBuilder].self,
                                                     forKey: .parameters) ?? [:]
        self.responseBuilders = try values.decodeIfPresent([String: ResponseBuilder].self, forKey: .responses) ?? [:]
        self.securityDefinitionBuilders = try values.decodeIfPresent([String: SecuritySchemaBuilder].self,
                                                              forKey: .securityDefinitions) ?? [:]
        self.securityRequirements = try values.decodeIfPresent([SecurityRequirement].self, forKey: .security) ?? []
        self.tagBuilders = try values.decodeIfPresent([TagBuilder].self, forKey: .tags) ?? []
        self.externalDocumentationBuilder = try values.decodeIfPresent(ExternalDocumentationBuilder.self,
                                                                       forKey: .externalDocumentation)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.version, forKey: .version)
        try container.encode(self.informationBuilder, forKey: .information)
        try container.encode(self.host, forKey: .host)
        try container.encode(self.basePath, forKey: .basePath)
        try container.encode(self.schemes, forKey: .schemes)
        try container.encode(self.consumes, forKey: .consumes)
        try container.encode(self.produces, forKey: .produces)
        try container.encode(self.pathBuilders, forKey: .paths)
        try container.encode(self.definitionBuilders, forKey: .definitions)
        try container.encode(self.parameterBuilders, forKey: .parameters)
        try container.encode(self.responseBuilders, forKey: .responses)
        try container.encode(self.securityDefinitionBuilders, forKey: .securityDefinitions)
        try container.encode(self.securityRequirements, forKey: .security)
        try container.encode(self.tagBuilders, forKey: .tags)
        try container.encode(self.externalDocumentationBuilder, forKey: .externalDocumentation)
    }
}

extension OpenAPI2Builder: Builder {
    typealias Building = OpenAPI2

    func build(_ swagger: SwaggerBuilder) throws -> OpenAPI2 {

        // Pre-resolve and cache references to fix circular references:
        SchemaBuilder.resolver.setup()
        ParameterBuilder.resolver.setup()
        ResponseBuilder.resolver.setup()

        try self.definitionBuilders.values.forEach { try _ = $0.build(swagger) }
        try self.parameterBuilders.values.forEach { try _ = $0.build(swagger) }
        try self.responseBuilders.values.forEach { try _ = $0.build(swagger) }

        let paths = try self.pathBuilders.mapValues { try $0.build(swagger) }
        let definitions = try self.definitionBuilders.mapValues { try $0.build(swagger) }
        let parameters = try self.parameterBuilders.mapValues { try $0.build(swagger) }
        let responses = try self.responseBuilders.mapValues { try $0.build(swagger) }
        let securityDefinitions = try self.securityDefinitionBuilders.mapValues { try $0.build(swagger) }

        // Clean up resolvers:
        SchemaBuilder.resolver.teardown()
        ParameterBuilder.resolver.teardown()
        ResponseBuilder.resolver.teardown()

        let tags = try self.tagBuilders.map { try $0.build(swagger) }
        let externalDocumentation = try self.externalDocumentationBuilder?.build(swagger)
        return OpenAPI2(version: self.version,
                        information: try self.informationBuilder.build(swagger),
                        host: self.host,
                        basePath: self.basePath,
                        schemes: self.schemes,
                        consumes: self.consumes,
                        produces: self.produces,
                        paths: paths,
                        definitions: definitions,
                        parameters: parameters,
                        responses: responses,
                        securityDefinitions: securityDefinitions,
                        securityRequirements: self.securityRequirements,
                        tags: tags,
                        externalDocumentation: externalDocumentation)
    }
}



extension OpenAPI2Builder: SwaggerBuilder {
    func resolveBuilderName(from components: [String], at path: String) throws -> String {
        guard components.count == 3 && components[0] == "#" && components[1] == path else {
            throw ResolverError.invalidPath
        }
        return components[2]
    }

    func resolveBuilder(for name: String, at path: String) throws -> Any? {
        switch path {
        case SchemaBuilder.path: return definitionBuilders[name]
        case ParameterBuilder.path: return parameterBuilders[name]
        case ResponseBuilder.path: return responseBuilders[name]
        default: throw ResolverError.unsupportedReference
        }
    }
}

