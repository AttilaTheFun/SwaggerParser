import OpenAPI

public struct Parameter {
    
    /// REQUIRED. The name of the parameter. Parameter names are case sensitive.
    ///
    /// If in is "path", the name field MUST correspond to the associated path segment from the path field in the Paths Object. See Path Templating for further information.
    ///
    /// If in is "header" and the name field is "Accept", "Content-Type" or "Authorization", the parameter definition SHALL be ignored.
    ///
    /// For all other cases, the name corresponds to the parameter name used by the in property.
    public let name: String
    
    /// REQUIRED. The location of the parameter.
    /// Possible values are "query", "header", "path" or "cookie".
    public let location: ParameterLocation
    
    /// A brief description of the parameter.
    /// This could contain examples of use. CommonMark syntax MAY be used for rich text representation.
    public let description: String?
    
    /// Determines whether this parameter is mandatory.
    /// If the parameter location is "path", this property is REQUIRED and its value MUST be true.
    /// Otherwise, the property MAY be included and its default value is false.
    public let required: Bool?
    
    /// Specifies that a parameter is deprecated and SHOULD be transitioned out of usage.
    public let deprecated: Bool?

    /// Sets the ability to pass empty-valued parameters.
    /// This is valid only for query parameters and allows sending a parameter with an empty value.
    /// Default value is false. If style is used, and if behavior is n/a (cannot be serialized), the value of allowEmptyValue SHALL be ignored.
    public let allowEmptyValue: Bool?
    
    /// Describes how the parameter value will be serialized depending on the type of the parameter value.
    /// Default values (based on value of in):
    /// for query - form; for path - simple; for header - simple; for cookie - form.
    public let style: SerializationStyle?
    
    /// When this is true, parameter values of type array or object generate separate parameters for each value of the array or key-value pair of the map. For other types of parameters this property has no effect. When style is form, the default value is true. For all other styles, the default value is false.
    public let explode: Bool?
    
    /// Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding. This property only applies to parameters with an in value of query. The default value is false.
    public let allowReserved: Bool?
    
    /// The schema defining the type used for the parameter.
    public let schema: Either<Schema, Structure<Schema>>?
    
    /// Example of the media type.
    ///
    /// The example SHOULD match the specified schema and encoding properties if present. The example object is mutually exclusive of the examples object. Furthermore, if referencing a schema which contains an example, the example value SHALL override the example provided by the schema. To represent examples of media types that cannot naturally be represented in JSON or YAML, a string value can contain the example with escaping where necessary.
    public let example: Any?
    
    /// Examples of the media type.
    ///
    /// Each example SHOULD contain a value in the correct format as specified in the parameter encoding. The examples object is mutually exclusive of the example object. Furthermore, if referencing a schema which contains an example, the examples value SHALL override the example provided by the schema.
    public let examples: [String: Either<Example, Structure<Example>>]

    /// A map containing the representations for the parameter.
    /// The key is the media type and the value describes it. The map MUST only contain one entry.
    public let content: [String: MediaType]
}

struct ParameterBuilder: Codable {
    
    let name: String
    let location: ParameterLocation
    let definitionBuilder: ParameterDefinitionBuilder

    enum CodingKeys: String, CodingKey {
        case name
        case location = "in"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.location = try values.decode(ParameterLocation.self, forKey: .location)
        self.definitionBuilder = try ParameterDefinitionBuilder(from: decoder)
    }
}

extension ParameterBuilder: Builder {
    typealias Building = Parameter
    
    func build(_ swagger: SwaggerBuilder) throws -> Parameter {
        let definition = try self.definitionBuilder.build(swagger)
        return Parameter(name: self.name,
                         location: self.location,
                         description: definition.description,
                         required: definition.required,
                         deprecated: definition.deprecated,
                         allowEmptyValue: definition.allowEmptyValue,
                         style: definition.style,
                         explode: definition.explode,
                         allowReserved: definition.allowReserved,
                         schema: definition.schema,
                         example: definition.example,
                         examples: definition.examples,
                         content: definition.content)
    }
}


extension ParameterBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<ParameterBuilder>) throws
        -> Either<Parameter, Structure<Parameter>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}
