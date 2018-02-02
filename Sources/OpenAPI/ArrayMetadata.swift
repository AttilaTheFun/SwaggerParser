
public struct ArrayMetadata {

    /// The minimum number of items in the array. Must be greater than or equal to zero.
    public let minItems: Int?

    /// The maximum number of items in the array. Must be greater than or equal to zero.
    public let maxItems: Int?

    /// Items must have unique values.
    public let uniqueItems: Bool
}

public struct ArrayMetadataBuilder: Codable {
    let minItems: Int?
    let maxItems: Int?
    let uniqueItems: Bool

    enum CodingKeys: String, CodingKey {
        case minItems
        case maxItems
        case uniqueItems
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.minItems = try values.decodeIfPresent(Int.self, forKey: .minItems)
        self.maxItems = try values.decodeIfPresent(Int.self, forKey: .maxItems)
        self.uniqueItems = try values.decodeIfPresent(Bool.self, forKey: .uniqueItems) ?? false
    }
}

extension ArrayMetadataBuilder: Builder {
    public typealias Building = ArrayMetadata

    public func build(_ swagger: SwaggerBuilder) throws -> ArrayMetadata {
        return ArrayMetadata(
            minItems: self.minItems,
            maxItems: self.maxItems,
            uniqueItems: self.uniqueItems)
    }
}
