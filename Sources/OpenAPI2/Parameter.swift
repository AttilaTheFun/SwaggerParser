// TODO: Handle files & allow empty value.
import OpenAPI

/// Describes a single operation parameter. 
/// Parameters can be passed either the body of the request or 'other':
/// Path, Query, Header, or Form
public enum Parameter {
    case body(fixedFields: FixedParameterFields, schema: Schema)
    case other(fixedFields: FixedParameterFields, items: Items)
}

enum ParameterBuilder: Codable {
    case body(fixedFieldsBuilder: FixedParameterFieldsBuilder, schemaBuilder: SchemaBuilder)
    case other(fixedFieldsBuilder: FixedParameterFieldsBuilder, itemsBuilder: ItemsBuilder)

    enum CodingKeys: String, CodingKey {
        case schema
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let fixedFields = try FixedParameterFieldsBuilder(from: decoder)
        switch fixedFields.location {
        case .body:
            let schema = try values.decode(SchemaBuilder.self, forKey: .schema)
            self = .body(fixedFieldsBuilder: fixedFields, schemaBuilder: schema)
        case .query, .header, .path, .formData:
            self = .other(fixedFieldsBuilder: fixedFields, itemsBuilder: try ItemsBuilder(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .body(let fixedFieldsBuilder, let schemaBuilder):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try fixedFieldsBuilder.encode(to: encoder)
            try container.encode(schemaBuilder, forKey: .schema)
        case .other(let fixedFieldsBuilder, let itemsBuilder):
            try fixedFieldsBuilder.encode(to: encoder)
            try itemsBuilder.encode(to: encoder)
        }
    }
}

extension ParameterBuilder: Builder {
    typealias Building = Parameter

    func build(_ swagger: SwaggerBuilder) throws -> Parameter {
        switch self {
        case .body(let fixedFieldsBuilder, let schemaBuilder):
            return .body(fixedFields: try fixedFieldsBuilder.build(swagger),
                         schema: try schemaBuilder.build(swagger))
        case .other(let fixedFieldsBuilder, let itemsBuilder):
            return .other(fixedFields: try fixedFieldsBuilder.build(swagger),
                          items: try itemsBuilder.build(swagger))
        }
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
