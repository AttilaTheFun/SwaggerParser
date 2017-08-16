
public struct ArrayItem {

    /// Metadata about the array type including the number of items and their uniqueness.
    public let metadata: ArrayMetadata

    /// Describes the type of items in the array.
    public let items: Items

    /// Determines the format of the array if type array is used. Possible values are:
    /// csv - comma separated values foo,bar.
    /// ssv - space separated values foo bar.
    /// tsv - tab separated values foo\tbar.
    /// pipes - pipe separated values foo|bar.
    /// Default value is csv.
    public let collectionFormat: CollectionFormat
}

struct ArrayItemBuilder: Codable {
    let metadataBuilder: ArrayMetadataBuilder
    let itemsBuilder: ItemsBuilder
    let collectionFormat: CollectionFormat

    enum CodingKeys: String, CodingKey {
        case itemsBuilder = "items"
        case collectionFormat
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.metadataBuilder = try ArrayMetadataBuilder(from: decoder)
        self.itemsBuilder = try values.decode(ItemsBuilder.self, forKey: .itemsBuilder)
        self.collectionFormat = try values.decodeIfPresent(CollectionFormat.self,
                                                           forKey: .collectionFormat) ?? .csv
    }
}

extension ArrayItemBuilder: Builder {
    typealias Building = ArrayItem

    func build(_ swagger: SwaggerBuilder) throws -> ArrayItem {
        return ArrayItem(
            metadata: try self.metadataBuilder.build(swagger),
            items: try self.itemsBuilder.build(swagger),
            collectionFormat: self.collectionFormat)
    }
}
