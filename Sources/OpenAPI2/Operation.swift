import OpenAPI

public struct Operation {

    /// A list of tags for API documentation control. 
    /// Tags can be used for logical grouping of operations by resources or any other qualifier.
    public let tags: [String]

    /// A short summary of what the operation does. This field SHOULD be less than 120 characters.
    public let summary: String?

    /// A verbose explanation of the operation behavior.
    /// Github-Flavored Markdown syntax can be used for rich text representation.
    public let description: String?

    /// Additional external documentation for this operation.
    public let externalDocumentation: ExternalDocumentation?

    /// A list of parameters that are applicable for this operation. 
    /// If a parameter is already defined at the Path Item, the new definition will override it, 
    /// but can never remove it. The list MUST NOT include duplicated parameters.
    /// There can be one "body" parameter at most.
    public let parameters: [Either<Parameter, Structure<Parameter>>]

    /// The list of possible responses as they are returned from executing this operation.
    public let responses: [Int : Either<Response, Structure<Response>>]

    /// The documentation of responses other than the ones declared for specific HTTP response codes.
    /// It can be used to cover undeclared responses.
    public let defaultResponse: Either<Response, Structure<Response>>?

    /// Declares this operation to be deprecated. Usage of the declared operation should be refrained. 
    /// Default value is false.
    public let deprecated: Bool

    /// A unique string used to identify the operation
    public let identifier: String?

    /// A list of which security schemes are applied to this operation.
    /// The list of values describes alternative security schemes that can be used 
    /// (that is, there is a logical OR between the security requirements).
    /// This definition overrides any declared top-level security.
    /// To remove a top-level security declaration, an empty array is used.
    public let security: [SecurityRequirement]?
}

struct OperationBuilder: Codable {
    let summary: String?
    let description: String?
    let deprecated: Bool
    let identifier: String?
    let tags: [String]
    let security: [SecurityRequirement]?
    let externalDocumentationBuilder: ExternalDocumentationBuilder?

    let parameters: [Reference<ParameterBuilder>]
    let responses: [Int : Reference<ResponseBuilder>]
    let defaultResponse: Reference<ResponseBuilder>?

    enum CodingKeys: String, CodingKey {
        case summary
        case description
        case deprecated
        case identifier = "operationId"
        case tags
        case security
        case externalDocumentation = "externalDocs"

        case parameters
        case responses
        case defaultResponse = "default"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.summary = try values.decodeIfPresent(String.self, forKey: .summary)
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
        self.deprecated = try values.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false
        self.identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        self.tags = try values.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.security = try values.decodeIfPresent([SecurityRequirement].self, forKey: .security)
        self.externalDocumentationBuilder = try values.decodeIfPresent(ExternalDocumentationBuilder.self,
                                                                       forKey: .externalDocumentation)

        self.parameters = try values.decodeIfPresent([Reference<ParameterBuilder>].self,
                                                     forKey: .parameters) ?? []
        let allResponses = try values.decode([String: Reference<ResponseBuilder>].self, forKey: .responses)
        let intTuples = allResponses.compactMap { key, value in return Int(key).flatMap { ($0, value) } }
        self.responses = Dictionary(uniqueKeysWithValues: intTuples)
        self.defaultResponse = allResponses["default"]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.summary, forKey: .summary)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.deprecated, forKey: .deprecated)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.tags, forKey: .tags)
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

        let defaultResponse = try self.defaultResponse.map { response in
            try ResponseBuilder.resolve(swagger, reference: response)
        }

        return Operation(
            tags: self.tags,
            summary: self.summary,
            description: self.description,
            externalDocumentation: externalDocumentation,
            parameters: parameters,
            responses: responses,
            defaultResponse: defaultResponse,
            deprecated: self.deprecated,
            identifier: self.identifier,
            security: self.security)
    }
}
