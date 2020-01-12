import Foundation
import OpenAPI

public struct MediaType {
    
    /// The schema defining the type used for the request body.
    public let schema: Either<Schema, Structure<Schema>>?
    
    /// Example of the media type.
    ///
    /// The example object SHOULD be in the correct format as specified by the media type. The example object is mutually exclusive of the examples object. Furthermore, if referencing a schema which contains an example, the example value SHALL override the example provided by the schema.
    public let example: Any?
    
    /// Examples of the media type.
    ///
    /// Each example object SHOULD match the media type and specified schema if present. The examples object is mutually exclusive of the example object. Furthermore, if referencing a schema which contains an example, the examples value SHALL override the example provided by the schema.
    public let examples: [String: Either<Example, Structure<Example>>]
    
    /// A map between a property name and its encoding information.
    ///
    /// The key, being the property name, MUST exist in the schema as a property. The encoding object SHALL only apply to requestBody objects when the media type is multipart or application/x-www-form-urlencoded.
    public let encoding: [String: Encoding]
}

struct MediaTypeBuilder: Codable {
    let schema: Reference<SchemaBuilder>?
    let example: String?
    let examples: [String: Reference<ExampleBuilder>]
    let encoding: [String: EncodingBuilder]
    
    enum CodingKeys: String, CodingKey {
        case schema
        case example
        case examples
        case encoding
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.schema = try values.decodeIfPresent(Reference<SchemaBuilder>.self, forKey: .schema)
        self.example = try values.decodeIfPresent(String.self, forKey: .example)
        self.examples = try values.decodeIfPresent([String: Reference<ExampleBuilder>].self, forKey: .examples) ?? [:]
        self.encoding = try values.decodeIfPresent([String: EncodingBuilder].self, forKey: .encoding) ?? [:]
    }
}

extension MediaTypeBuilder: Builder {
    typealias Building = MediaType
    
    func build(_ swagger: SwaggerBuilder) throws -> MediaType {
        var schema: Either<Schema, Structure<Schema>>?
        if let schemaBuilder = self.schema {
            schema = try SchemaBuilder.resolve(swagger, reference: schemaBuilder)
        }
        let examples = try self.examples.mapValues {
            try ExampleBuilder.resolve(swagger, reference: $0)
        }
        let encoding = try self.encoding.mapValues { try $0.build(swagger) }
        return MediaType(schema: schema,
                         example: self.example as Any?,
                         examples: examples,
                         encoding: encoding)
    }
}
