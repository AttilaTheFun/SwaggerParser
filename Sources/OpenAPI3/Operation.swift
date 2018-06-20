import OpenAPI

public struct Operation {

    /// A list of tags for API documentation control.
    ///
    /// Tags can be used for logical grouping of operations by resources or any other qualifier.
    public let tags: [String]

    /// A short summary of what the operation does.
    public let summary: String?

    /// A verbose explanation of the operation behavior.
    ///
    /// CommonMark syntax MAY be used for rich text representation.
    public let description: String?

    /// Additional external documentation for this operation.
    public let externalDocumentation: ExternalDocumentation?

    /// Unique string used to identify the operation.
    ///
    /// The id MUST be unique among all operations described in the API.
    /// Tools and libraries MAY use the operationId to uniquely identify an operation, therefore, it is RECOMMENDED to follow common programming naming conventions.
    public let identifier: String?
    
    /// A list of parameters that are applicable for this operation.
    ///
    /// If a parameter is already defined at the Path Item, the new definition will override it but can never remove it. The list MUST NOT include duplicated parameters.
    /// A unique parameter is defined by a combination of a name and location.
    /// The list can use the Reference Object to link to parameters that are defined at the OpenAPI Object's components/parameters.
    public let parameters: [Either<Parameter, Structure<Parameter>>]
    
    /// The request body applicable for this operation.
    ///
    /// The requestBody is only supported in HTTP methods where the HTTP 1.1 specification RFC7231 has explicitly defined semantics for request bodies. In other cases where the HTTP spec is vague, requestBody SHALL be ignored by consumers.
    public let requestBody: Either<RequestBody, Structure<RequestBody>>?

    /// The list of possible responses as they are returned from executing this operation.
    public let responses: [Int : Either<Response, Structure<Response>>]
    
    /// A map of possible out-of band callbacks related to the parent operation.
    ///
    /// The key is a unique identifier for the Callback Object. Each value in the map is a Callback Object that describes a request that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
    public let callbacks: [String: Either<Callback, Structure<Callback>>]
    
    /// Declares this operation to be deprecated.
    /// Consumers SHOULD refrain from usage of the declared operation.
    /// Default value is false.
    public let deprecated: Bool

    /// A list of which security schemes are applied to this operation.
    /// The list of values describes alternative security schemes that can be used 
    /// (that is, there is a logical OR between the security requirements).
    /// This definition overrides any declared top-level security.
    /// To remove a top-level security declaration, an empty array is used.
    public let security: [SecurityRequirement]
    
    /// An alternative server array to service this operation.
    /// If an alternative server object is specified at the Path Item Object or Root level, it will be overridden by this value.
    public let servers: [Server]
}

struct OperationBuilder: Codable {
    let tags: [String]
    let summary: String?
    let description: String?
    let deprecated: Bool
    let identifier: String?
    let security: [SecurityRequirement]
    let externalDocumentationBuilder: ExternalDocumentationBuilder?
    let parameters: [Reference<ParameterBuilder>]
    let requestBody: Reference<RequestBodyBuilder>?
    let responses: [Int: Reference<ResponseBuilder>]
    let callbacks: [String: Reference<CallbackBuilder>]
    let defaultResponse: Reference<ResponseBuilder>?
    let servers: [ServerBuilder]

    enum CodingKeys: String, CodingKey {
        case tags
        case summary
        case description
        case deprecated
        case identifier = "operationId"
        case security
        case externalDocumentation = "externalDocs"
        case parameters
        case requestBody
        case responses
        case callbacks
        case servers
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.tags = try values.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.summary = try values.decodeIfPresent(String.self, forKey: .summary)
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
        self.deprecated = try values.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false
        self.identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        self.security = try values.decodeIfPresent([SecurityRequirement].self, forKey: .security) ?? []
        self.externalDocumentationBuilder = try values.decodeIfPresent(ExternalDocumentationBuilder.self,
                                                                       forKey: .externalDocumentation)
        self.parameters = try values.decodeIfPresent([Reference<ParameterBuilder>].self,
                                                     forKey: .parameters) ?? []
        self.requestBody = try values.decodeIfPresent(Reference<RequestBodyBuilder>.self, forKey: .requestBody)
        let allResponses = try values.decode([String: Reference<ResponseBuilder>].self, forKey: .responses)
        let intTuples = allResponses.compactMap { key, value in return Int(key).flatMap { ($0, value) } }
        self.responses = Dictionary(uniqueKeysWithValues: intTuples)
        self.defaultResponse = allResponses["default"]
        self.callbacks = try values.decodeIfPresent([String: Reference<CallbackBuilder>].self,
                                                    forKey: .callbacks) ?? [:]
        self.servers = try values.decodeIfPresent([ServerBuilder].self, forKey: .servers) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.tags, forKey: .tags)
        try container.encode(self.summary, forKey: .summary)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.deprecated, forKey: .deprecated)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.security, forKey: .security)
        try container.encode(self.externalDocumentationBuilder, forKey: .externalDocumentation)

        try container.encode(self.parameters, forKey: .parameters)
        var allResponses = [String: Reference<ResponseBuilder>]()
        allResponses["default"] = self.defaultResponse
        self.responses.forEach { allResponses[String($0)] = $1 }
        try container.encode(allResponses, forKey: .responses)
    }
}

extension OperationBuilder: Builder {
    typealias Building = Operation

    func build(_ swagger: SwaggerBuilder) throws -> Operation {
        let externalDocumentation = try self.externalDocumentationBuilder?.build(swagger)
        let parameters = try self.parameters.map { try ParameterBuilder.resolve(swagger, reference: $0) }
        let responses = try self.responses.mapValues { response in
            try ResponseBuilder.resolve(swagger, reference: response)
        }
        let callbacks = try self.callbacks.mapValues {
            try CallbackBuilder.resolve(swagger, reference: $0)
        }
        var requestBody: Either<RequestBody, Structure<RequestBody>>?
        if let requestBodyBuilder = self.requestBody {
            requestBody = try RequestBodyBuilder.resolve(swagger, reference: requestBodyBuilder)
        }
        let servers = try self.servers.map { try $0.build(swagger) }

        return Operation(tags: self.tags,
                         summary: self.summary,
                         description: self.description,
                         externalDocumentation: externalDocumentation,
                         identifier: self.identifier,
                         parameters: parameters,
                         requestBody: requestBody,
                         responses: responses,
                         callbacks: callbacks,
                         deprecated: self.deprecated,
                         security: self.security,
                         servers: servers)
    }
}
