import ObjectMapper

/// Schemas are used to define the types used in body parameters. They are more expressive than Items.
public enum Schema {
    indirect case structure(StructureSchema)
    indirect case object(ObjectSchema)
    indirect case array(ArraySchema)
    indirect case allOf(AllOfSchema)
    case string(metadata: Metadata, format: StringFormat?)
    case number(metadata: Metadata, format: NumberFormat?)
    case integer(metadata: Metadata, format: IntegerFormat?)
    case enumeration(metadata: Metadata)
    case boolean(metadata: Metadata)
    case file(metadata: Metadata)
    case any(metadata: Metadata)
}

enum SchemaBuilder: Builder {

    typealias Building = Schema

    indirect case object(ObjectSchemaBuilder)
    indirect case array(ArraySchemaBuilder)
    indirect case pointer(MetadataBuilder, Pointer<SchemaBuilder>)
    indirect case allOf(AllOfSchemaBuilder)
    case string(metadata: MetadataBuilder, format: StringFormat?)
    case number(metadata: MetadataBuilder, format: NumberFormat?)
    case integer(metadata: MetadataBuilder, format: IntegerFormat?)
    case enumeration(metadata: MetadataBuilder)
    case boolean(metadata: MetadataBuilder)
    case file(metadata: MetadataBuilder)
    case any(metadata: MetadataBuilder)

    public init(map: Map) throws {
        let metadata = try MetadataBuilder(map: map)
        switch metadata.type {
        case .object:
            self = .object(try ObjectSchemaBuilder(map: map))
        case .array:
            self = .array(try ArraySchemaBuilder(map: map))
        case .allOf:
            self = .allOf(try AllOfSchemaBuilder(map: map))
        case .string:
            self = .string(metadata: metadata, format: try? map.value("format"))
        case .number:
            self = .number(metadata: metadata, format: try? map.value("format"))
        case .integer:
            self = .integer(metadata: metadata, format: try? map.value("format"))
        case .enumeration:
            self = .enumeration(metadata: metadata)
        case .boolean:
            self = .boolean(metadata: metadata)
        case .pointer:
            self = .pointer(metadata, try Pointer<SchemaBuilder>(map: map))
        case .file:
            self = .file(metadata: metadata)
        case .any:
            self = .any(metadata: metadata)
        }
    }

    func build(_ swagger: SwaggerBuilder) throws -> Schema {
        switch self {
        case .object(let builder):
            return .object(try builder.build(swagger))
        case .array(let builder):
            return .array(try builder.build(swagger))
        case .allOf(let builder):
            return .allOf(try builder.build(swagger))
        case .pointer(let metadata, let pointer):
            return .structure(try SchemaBuilder.resolve(swagger, pointer: pointer, metadata: metadata))
        case .string(let metadataBuilder, let format):
            return .string(metadata: try metadataBuilder.build(swagger), format: format)
        case .number(let metadataBuilder, let format):
            return .number(metadata: try metadataBuilder.build(swagger), format: format)
        case .integer(let metadataBuilder, let format):
            return .integer(metadata: try metadataBuilder.build(swagger), format: format)
        case .enumeration(let metadataBuilder):
            return .enumeration(metadata: try metadataBuilder.build(swagger))
        case .boolean(let metadataBuilder):
            return .boolean(metadata: try metadataBuilder.build(swagger))
        case .file(let metadataBuilder):
            return .file(metadata: try metadataBuilder.build(swagger))
        case .any(let metadataBuilder):
            return .any(metadata: try metadataBuilder.build(swagger))
        }
    }
}

extension SchemaBuilder {
    static func resolve(_ swagger: SwaggerBuilder, pointer: Pointer<SchemaBuilder>, metadata: MetadataBuilder) throws ->
        StructureSchema
    {
        let components = pointer.path.components(separatedBy: "/")
        guard components.count == 3 && components[0] == "#" && components[1] == "definitions",
            let builder = swagger.definitions[components[2]] else
        {
            throw DecodingError()
        }

        let name = components[2]
        let schema = try builder.build(swagger)
        let metadata = try metadata.build(swagger)
        return StructureSchema(name: name, schema: schema, metadata: metadata)
    }
}
