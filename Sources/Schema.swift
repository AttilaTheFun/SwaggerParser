import ObjectMapper

/// Schemas are used to define the types used in body parameters. They are more expressive than Items.
public struct Schema {

    /// Metadata is used to provide common meta (name, nullability, etc) information about the type.
    public let metadata: Metadata

    /// The type defined by this schema along with any specific type information (e.g. object properties).
    public let type: SchemaType

    /// Additional external documentation for this schema.
    public let externalDocumentation: ExternalDocumentation?
}

/// The discrete type defined by the schema.
/// This can be a primitive type (string, float, integer, etc.) or a complex type like a dictionay or array.
public enum SchemaType {

    /// A structure represents a named or aliased type.
    indirect case structure(Structure<Schema>)

    /// Defines an anonymous object type with a set of named properties.
    indirect case object(ObjectSchema)

    /// Defines an array of heterogenous (but possibly polymorphic) objects.
    indirect case array(ArraySchema)

    /// Defines an object with the combined requirements of several subschema.
    indirect case allOf(AllOfSchema)

    /// A string type with optional format information (e.g. base64 encoding).
    case string(StringFormat?)

    /// A floating point number type with optional format information (e.g. single vs double precision).
    case number(NumberFormat?)

    /// An integer type with an optional format (32 vs 64 bit).
    case integer(IntegerFormat?)

    /// An enumeration type with explicit acceptable values defined in the metadata.
    case enumeration

    /// A boolean type.
    case boolean

    /// A file type.
    case file

    /// An 'any' type which matches any value.
    case any
}

struct SchemaBuilder: Builder {

    typealias Building = Schema

    let metadataBuilder: MetadataBuilder
    let schemaTypeBuilder: SchemaTypeBuilder
    let externalDocumentationBuilder: ExternalDocumentationBuilder?

    init(map: Map) throws {
        metadataBuilder = try MetadataBuilder(map: map)
        schemaTypeBuilder = try SchemaTypeBuilder(map: map)
        externalDocumentationBuilder = try? map.value("externalDocs")
    }

    func build(_ swagger: SwaggerBuilder) throws -> Schema {
        return Schema(metadata: try self.metadataBuilder.build(swagger),
                      type: try self.schemaTypeBuilder.build(swagger),
                      externalDocumentation: try self.externalDocumentationBuilder?.build(swagger))
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
            let structure = try SchemaBuilder.resolver.resolve(swagger, pointer: pointer)
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
