
public struct Components {
    
    /// An object to hold reusable Schema Objects.
    public let schemas: [String: Either<Schema, Structure<Schema>>]
    
    /// An object to hold reusable Response Objects.
    public let responses: [String: Either<Response, Structure<Response>>]
    
    /// An object to hold reusable Parameter Objects.
    public let parameters: [String: Either<Parameter, Structure<Parameter>>]
    
    /// An object to hold reusable Example Objects.
    public let examples: [String: Either<Example, Structure<Example>>]
    
    /// An object to hold reusable Request Body Objects.
    public let requestBodies: [String: Either<RequestBody, Structure<RequestBody>>]
    
    /// An object to hold reusable Header Objects.
    // TODO: public let headers: [String: Either<Header, Structure<Header>>]
    
    /// An object to hold reusable Security Scheme Objects.
    public let securitySchemes: [String: Either<SecuritySchema, Structure<SecuritySchema>>]
    
    /// An object to hold reusable Link Objects.
    // TODO: public let links: [String: Either<Link, Structure<Link>>]
    
    /// An object to hold reusable Callback Objects.
    // TODO: public let callbacks: [String: Either<Callback, Structure<Callback>>]
}

struct ComponentsBuilder: Codable {
    let schemas: [String: Reference<SchemaBuilder>]
    let responses: [String: Reference<ResponseBuilder>]
    let parameters: [String: Reference<ParameterBuilder>]
    let examples: [String: Reference<ExampleBuilder>]
    let requestBodies: [String: Reference<RequestBodyBuilder>]
    //let headers: [String: Reference<HeaderBuilder>]
    let securitySchemes: [String: Reference<SecuritySchemaBuilder>]
    //let links: [String: Reference<LinkBuilder>]
    //let callbacks: [String: Reference<CallbackBuilder>]

    enum CodingKeys: String, CodingKey {
        case schemas
        case responses
        case parameters
        case securitySchemes
        case examples
        case requestBodies
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.schemas = try values.decodeIfPresent([String: Reference<SchemaBuilder>].self,
                                                  forKey: .schemas) ?? [:]
        self.responses = try values.decodeIfPresent([String: Reference<ResponseBuilder>].self,
                                                    forKey: .responses) ?? [:]
        self.parameters = try values.decodeIfPresent([String: Reference<ParameterBuilder>].self,
                                                     forKey: .parameters) ?? [:]
        self.securitySchemes = try values.decodeIfPresent([String: Reference<SecuritySchemaBuilder>].self,
                                                          forKey: .securitySchemes) ?? [:]
        self.examples = try values.decodeIfPresent([String: Reference<ExampleBuilder>].self,
                                                   forKey: .examples) ?? [:]
        self.requestBodies = try values.decodeIfPresent([String: Reference<RequestBodyBuilder>].self,
                                                        forKey: .requestBodies) ?? [:]
    }
}

extension ComponentsBuilder: Builder {
    typealias Building = Components
    
    func build(_ swagger: SwaggerBuilder) throws -> Components {
        let schemas = try self.schemas.mapValues {
            try SchemaBuilder.resolve(swagger, reference: $0)
        }
        let responses = try self.responses.mapValues {
            try ResponseBuilder.resolve(swagger, reference: $0)
        }
        let parameters = try self.parameters.mapValues {
            try ParameterBuilder.resolve(swagger, reference: $0)
        }
        let securitySchemes = try self.securitySchemes.mapValues {
            try SecuritySchemaBuilder.resolve(swagger, reference: $0)
        }
        let examples = try self.examples.mapValues {
            try ExampleBuilder.resolve(swagger, reference: $0)
        }
        let requestBodies = try self.requestBodies.mapValues {
            try RequestBodyBuilder.resolve(swagger, reference: $0)
        }
        return Components(schemas: schemas,
                          responses: responses,
                          parameters: parameters,
                          examples: examples,
                          requestBodies: requestBodies,
                          securitySchemes: securitySchemes)
    }
}
