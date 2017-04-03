import ObjectMapper

/// Describes a single operation parameter. Parameters can be passed in:
/// Path, Query, Header, Body, Form
public enum Parameter {
    case body(fixedFields: FixedParameterFields, schema: Schema)
    // TODO: Handle files & allow empty value.
    case other(fixedFields: FixedParameterFields, items: Items)
}

enum ParameterBuilder: Builder {

    typealias Building = Parameter

    // TODO: Handle files & allow empty value.
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
        -> Parameter
    {
        switch reference {
        case .pointer(let pointer):
            let components = pointer.path.components(separatedBy: "/")
            if components.count == 3 && components[0] == "#" && components[1] == "parameters",
                let builder = swagger.parameters[components[2]]
            {
                return try builder.build(swagger)
            } else {
                throw DecodingError()
            }
        case .value(let builder):
            return try builder.build(swagger)
        }
    }
}
