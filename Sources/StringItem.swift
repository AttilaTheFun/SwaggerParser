import ObjectMapper

public struct StringItem {
    public let metadata: Metadata
    public let format: StringFormat?
    public let maxLength: Int?
    public let minLength: Int?
}

struct StringItemBuilder: Builder {

    typealias Building = StringItem
    let metadata: MetadataBuilder
    let format: StringFormat?
    let maxLength: Int?
    let minLength: Int?

    init(map: Map) throws {
        metadata = try MetadataBuilder(map: map)
        format = try? map.value("format")
        maxLength = try? map.value("maxLength")
        minLength = (try? map.value("minLength")) ?? 0
    }

    func build(_ swagger: SwaggerBuilder) throws -> StringItem {
        return StringItem(metadata: try self.metadata.build(swagger),
                          format: self.format, maxLength: self.maxLength, minLength: self.minLength)
    }
}
