import ObjectMapper

/// Schemas are used to define the types used in body parameters. They are more expressive than Items.
public struct Schema {
    public let metadata: Metadata
    public let type: SchemaType
}

public enum SchemaType {
    indirect case structure(Structure<Schema>)
    indirect case object(ObjectSchema)
    indirect case array(ArraySchema)
    indirect case allOf(AllOfSchema)
    case string(StringFormat?)
    case number(NumberFormat?)
    case integer(IntegerFormat?)
    case enumeration
    case boolean
    case file
    case any
}

struct SchemaBuilder: Builder {

    typealias Building = Schema

    let metadataBuilder: MetadataBuilder
    let schemaTypeBuilder: SchemaTypeBuilder

    public init(map: Map) throws {
        metadataBuilder = try MetadataBuilder(map: map)
        schemaTypeBuilder = try SchemaTypeBuilder(map: map)
    }

    func build(_ swagger: SwaggerBuilder) throws -> Schema {
        let metadata = try metadataBuilder.build(swagger)
        let schemaType = try schemaTypeBuilder.build(swagger)
        return Schema(metadata: metadata, type: schemaType)
    }
}

enum SchemaTypeBuilder: Builder {

    typealias Building = SchemaType

    indirect case pointer(Pointer<SchemaBuilder>)
    indirect case object(ObjectSchemaBuilder)
    indirect case array(ArraySchemaBuilder)
    indirect case allOf(AllOfSchemaBuilder)
    case string(StringFormat?)
    case number(NumberFormat?)
    case integer(IntegerFormat?)
    case enumeration
    case boolean
    case file
    case any

    init(map: Map) throws {
        let dataType = DataType(map: map)
        switch dataType {
        case .pointer:
            self = .pointer(try Pointer<SchemaBuilder>(map: map))
        case .object:
            self = .object(try ObjectSchemaBuilder(map: map))
        case .array:
            self = .array(try ArraySchemaBuilder(map: map))
        case .allOf:
            self = .allOf(try AllOfSchemaBuilder(map: map))
        case .string:
            self = .string(try? map.value("format"))
        case .number:
            self = .number(try? map.value("format"))
        case .integer:
            self = .integer(try? map.value("format"))
        case .enumeration:
            self = .enumeration
        case .boolean:
            self = .boolean
        case .file:
            self = .file
        case .any:
            self = .any
        }
    }

    func build(_ swagger: SwaggerBuilder) throws -> SchemaType {
        switch self {
        case .pointer(let pointer):
            let structure = try SchemaBuilder.resolve(swagger, pointer: pointer)
            return .structure(structure)
        case .object(let builder):
            return .object(try builder.build(swagger))
        case .array(let builder):
            return .array(try builder.build(swagger))
        case .allOf(let builder):
            return .allOf(try builder.build(swagger))
        case .string(let format):
            return .string(format)
        case .number(let format):
            return .number(format)
        case .integer(let format):
            return .integer(format)
        case .enumeration:
            return .enumeration
        case .boolean:
            return .boolean
        case .file:
            return .file
        case .any:
            return .any
        }
    }
}

extension SchemaBuilder {
    static func resolve(_ swagger: SwaggerBuilder, pointer: Pointer<SchemaBuilder>) throws ->
        Structure<Schema>
    {
        let components = pointer.path.components(separatedBy: "/")
        guard components.count == 3 && components[0] == "#" && components[1] == "definitions",
            let builder = swagger.definitions[components[2]] else
        {
            throw DecodingError()
        }

        let name = components[2]
        let schema = try builder.build(swagger)
        return Structure(name: name, structure: schema)
    }
}
