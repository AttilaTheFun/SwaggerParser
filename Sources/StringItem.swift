
public struct StringItem {
    /// Metadata about the string type. E.g. its length and regex pattern.
    public let metadata: StringMetadata?

    /// The format keyword allows for basic semantic validation on certain kinds of string values that are
    /// commonly used.
    public let format: StringFormat?
}

struct StringItemBuilder: Codable {
    let format: StringFormat?
    let metadataBuilder: StringMetadataBuilder?

    enum CodingKeys: String, CodingKey {
        case format
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.metadataBuilder = try? StringMetadataBuilder(from: decoder)
        self.format = try values.decodeIfPresent(StringFormat.self, forKey: .format)
    }
}

extension StringItemBuilder: Builder {
    typealias Building = StringItem

    func build(_ swagger: SwaggerBuilder) throws -> StringItem {
        return StringItem(metadata: try self.metadataBuilder?.build(swagger), format: self.format)
    }
}
