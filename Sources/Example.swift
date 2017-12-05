
public struct Example {
    
    /// Short description for the example.
    public let summary: String?
    
    /// Long description for the example. CommonMark syntax MAY be used for rich text representation.
    public let description: String?
    
    /// Embedded literal example.
    ///
    /// To represent examples of media types that cannot naturally represented in JSON or YAML, use a string value to contain the example, escaping where necessary.
    /// The value field and externalValue field are mutually exclusive.
    public let value: Any?
    
    /// A URL that points to the literal example.
    ///
    /// This provides the capability to reference examples that cannot easily be included in JSON or YAML documents.
    /// The value field and externalValue field are mutually exclusive.
    public let externalValue: String?
}

struct ExampleBuilder: Codable {
    let summary: String?
    let description: String?
    let value: String?
    let externalValue: String?
    
    enum CodingKeys: String, CodingKey {
        case summary
        case description
        case value
        case externalValue
    }
}

extension ExampleBuilder: Builder {
    typealias Building = Example
    
    func build(_ swagger: SwaggerBuilder) throws -> Example {
        return Example(summary: self.summary,
                       description: self.description,
                       value: self.value,
                       externalValue: self.externalValue)
    }
}

extension ExampleBuilder {
    static func resolve(_ swagger: SwaggerBuilder, reference: Reference<ExampleBuilder>) throws
        -> Either<Example, Structure<Example>>
    {
        switch reference {
        case .pointer(let pointer):
            return .b(try self.resolver.resolve(swagger, pointer: pointer))
        case .value(let builder):
            return .a(try builder.build(swagger))
        }
    }
}
