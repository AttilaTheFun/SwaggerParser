
public struct NumberItem {
    public let metadata: NumericMetadata<Double>?
    public let format: NumberFormat?
}

public struct NumberItemBuilder: Codable {
    let metadataBuilder: NumericMetadataBuilder<Double>?
    let format: NumberFormat?

    enum CodingKeys: String, CodingKey {
        case format
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.metadataBuilder = try? NumericMetadataBuilder(from: decoder)
        self.format = try values.decodeIfPresent(NumberFormat.self, forKey: .format)
    }
}

extension NumberItemBuilder: Builder {
    public typealias Building = NumberItem

    public func build(_ swagger: SwaggerBuilder) throws -> NumberItem {
        return NumberItem(
            metadata: try self.metadataBuilder?.build(swagger),
            format: self.format)
    }
}
