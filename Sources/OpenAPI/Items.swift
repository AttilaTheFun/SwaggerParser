
/// A limited subset of JSON-Schema's items object.
/// It is used by parameter definitions that are not located in "body".
public struct Items {

    /// Metadata is used to provide common meta (name, nullability, etc) information about the type.
    public let metadata: Metadata

    /// The type defined by this schema along with any specific type information (e.g. array items).
    public let type: ItemsType
}

public struct ItemsBuilder: Codable {
    let metadataBuilder: MetadataBuilder
    let typeBuilder: ItemsTypeBuilder

    public init(from decoder: Decoder) throws {
        self.metadataBuilder = try MetadataBuilder(from: decoder)
        self.typeBuilder = try ItemsTypeBuilder(from: decoder)
    }
}

extension ItemsBuilder: Builder {
    public typealias Building = Items

    public func build(_ swagger: SwaggerBuilder) throws -> Items {
        return Items(
            metadata: try metadataBuilder.build(swagger),
            type: try typeBuilder.build(swagger))
    }
}
