import ObjectMapper

public struct IntegerItem {
    public let metadata: Metadata
    public let format: IntegerFormat?

    public let maximum: Int?
    public let exclusiveMaximum: Int?
    public let minimum: Int?
    public let exclusiveMinimum: Int?
    public let multipleOf: Int?
}

struct IntegerItemBuilder: Builder {

    typealias Building = IntegerItem
    let metadata: MetadataBuilder
    let format: IntegerFormat?

    let maximum: Int?
    let exclusiveMaximum: Int?
    let minimum: Int?
    let exclusiveMinimum: Int?
    let multipleOf: Int?

    init(map: Map) throws {
        metadata = try MetadataBuilder(map: map)
        format = try? map.value("format")

        maximum = try? map.value("maximum")
        exclusiveMaximum = try? map.value("exclusiveMaximum")
        minimum = try? map.value("minimum")
        exclusiveMinimum = try? map.value("exclusiveMinimum")
        multipleOf = try? map.value("multipleOf")
    }

    func build(_ swagger: SwaggerBuilder) throws -> IntegerItem {
        return IntegerItem(metadata: try self.metadata.build(swagger), format: self.format,
                           maximum: self.maximum, exclusiveMaximum: self.exclusiveMaximum,
                           minimum: self.minimum, exclusiveMinimum: self.exclusiveMinimum,
                           multipleOf: self.multipleOf)
    }
}
