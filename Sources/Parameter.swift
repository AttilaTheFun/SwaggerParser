import ObjectMapper

// TODO: Handle files & allow empty value.

/// Describes a single operation parameter. 
/// Parameters can be passed either the body of the request or 'other':
/// Path, Query, Header, or Form
public enum Parameter {
    case body(fixedFields: FixedParameterFields, schema: Schema)
    case other(fixedFields: FixedParameterFields, items: Items)
}

enum ParameterBuilder: Builder {

    typealias Building = Parameter


    case body(fixedFieldsBuilder: FixedParameterFieldsBuilder, schemaBuilder: SchemaBuilder)
    case other(fixedFieldsBuilder: FixedParameterFieldsBuilder, itemsBuilder: ItemsBuilder)

    init(map: Map) throws {
        let fixedFields = try FixedParameterFieldsBuilder(map: map)
        switch fixedFields.location {
        case .body:
            self = .body(fixedFieldsBuilder: fixedFields, schemaBuilder: try map.value("schema"))
        case .query, .header, .path, .formData:
            self = .other(fixedFieldsBuilder: fixedFields, itemsBuilder: try ItemsBuilder(map: map))
        }
    }

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
