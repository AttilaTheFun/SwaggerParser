
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

enum SchemaTypeBuilder: Codable {
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

    enum CodingKeys: String, CodingKey {
        case format
    }

    init(from decoder: Decoder) throws {
        let dataType = try DataType(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        switch dataType {
        case .pointer:
            self = .pointer(try Pointer<SchemaBuilder>(from: decoder))
        case .object:
            self = .object(try ObjectSchemaBuilder(from: decoder))
        case .array:
            self = .array(try ArraySchemaBuilder(from: decoder))
        case .allOf:
            self = .allOf(try AllOfSchemaBuilder(from: decoder))
        case .string:
            self = .string(try values.decodeIfPresent(StringFormat.self, forKey: .format))
        case .number:
            self = .number(try values.decodeIfPresent(NumberFormat.self, forKey: .format))
        case .integer:
            self = .integer(try values.decodeIfPresent(IntegerFormat.self, forKey: .format))
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

    func encode(to encoder: Encoder) throws {
        switch self {
        case .pointer(let pointer):
            try pointer.encode(to: encoder)
        case .object(let object):
            try object.encode(to: encoder)
        case .array(let array):
            try array.encode(to: encoder)
        case .allOf(let allOf):
            try allOf.encode(to: encoder)
        case .string(let format):
            try DataType.string.encode(to: encoder)
            try format.encode(to: encoder)
        case .number(let format):
            try DataType.number.encode(to: encoder)
            try format.encode(to: encoder)
        case .integer(let format):
            try DataType.integer.encode(to: encoder)
            try format.encode(to: encoder)
        case .enumeration:
            try DataType.enumeration.encode(to: encoder)
        case .boolean:
            try DataType.boolean.encode(to: encoder)
        case .file:
            try DataType.file.encode(to: encoder)
        case .any:
            try DataType.any.encode(to: encoder)
        }
    }
}

extension SchemaTypeBuilder: Builder {
    typealias Building = SchemaType

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
