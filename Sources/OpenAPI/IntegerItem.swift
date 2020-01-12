
public struct IntegerItem {
    public let metadata: NumericMetadata<Int>?
    public let format: IntegerFormat?
}

public struct IntegerItemBuilder: Codable {
    let metadataBuilder: NumericMetadataBuilder<Int>?
    let format: IntegerFormat?

    enum CodingKeys: String, CodingKey {
        case format
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.metadataBuilder = try? NumericMetadataBuilder(from: decoder)
        self.format = try values.decodeIfPresent(IntegerFormat.self, forKey: .format)
    }
}

extension IntegerItemBuilder: Builder {
    public typealias Building = IntegerItem

    public func build(_ swagger: SwaggerBuilder) throws -> IntegerItem {
        return IntegerItem(
            metadata: try self.metadataBuilder?.build(swagger),
            format: self.format)
    }
}
