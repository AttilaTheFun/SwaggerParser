/// Common definition shared between Parameter and Header
public struct ParameterDefinition {
    
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

struct ParameterDefinitionBuilder: Codable {
    
    let description: String?
    let required: Bool?
    let deprecated: Bool?
    let allowEmptyValue: Bool?
    let style: SerializationStyle?
    let explode: Bool?
    let allowReserved: Bool?
    let schema: Reference<SchemaBuilder>?
    let example: String?
    let examples: [String: Reference<ExampleBuilder>]
    let content: [String: MediaTypeBuilder]
    
    enum CodingKeys: String, CodingKey {
        case description
        case required
        case deprecated
        case allowEmptyValue
        case schema
        case style
        case explode
        case allowReserved
        case example
        case examples
        case content
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
        self.required = try values.decodeIfPresent(Bool.self, forKey: .required)
        self.deprecated = try values.decodeIfPresent(Bool.self, forKey: .deprecated)
        self.allowEmptyValue = try values.decodeIfPresent(Bool.self, forKey: .allowEmptyValue)
        self.style = try values.decodeIfPresent(SerializationStyle.self, forKey: .style)
        self.explode = try values.decodeIfPresent(Bool.self, forKey: .explode)
        self.allowReserved = try values.decodeIfPresent(Bool.self, forKey: .allowReserved)
        self.schema = try values.decodeIfPresent(Reference<SchemaBuilder>.self, forKey: .schema)
        self.example = try values.decodeIfPresent(String.self, forKey: .example)
        self.examples = try values.decodeIfPresent([String: Reference<ExampleBuilder>].self, forKey: .examples) ?? [:]
        self.content = try values.decodeIfPresent([String: MediaTypeBuilder].self, forKey: .content) ?? [:]
    }
}

extension ParameterDefinitionBuilder: Builder {
    typealias Building = ParameterDefinition
    
    func build(_ swagger: SwaggerBuilder) throws -> ParameterDefinition {
        var schema: Either<Schema, Structure<Schema>>?
        if let schemaBuilder = self.schema {
            schema = try SchemaBuilder.resolve(swagger, reference: schemaBuilder)
        }
        let examples = try self.examples.mapValues {
            try ExampleBuilder.resolve(swagger, reference: $0)
        }
        let content = try self.content.mapValues { try $0.build(swagger) }
        return ParameterDefinition(description: self.description,
                                   required: self.required,
                                   deprecated: self.deprecated,
                                   allowEmptyValue: self.allowEmptyValue,
                                   style: self.style,
                                   explode: self.explode,
                                   allowReserved: self.allowReserved,
                                   schema: schema,
                                   example: self.example as Any?,
                                   examples: examples,
                                   content: content)
    }
}
