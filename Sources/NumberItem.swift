import ObjectMapper

public struct NumberItem {
    public let format: NumberFormat?

    public let maximum: Double?
    public let exclusiveMaximum: Double?
    public let minimum: Double?
    public let exclusiveMinimum: Double?
    public let multipleOf: Double?
}

struct NumberItemBuilder: Builder {

    typealias Building = NumberItem
    let format: NumberFormat?

    let maximum: Double?
    let exclusiveMaximum: Double?
    let minimum: Double?
    let exclusiveMinimum: Double?
    let multipleOf: Double?

    init(map: Map) throws {
        format = try? map.value("format")

        maximum = try? map.value("maximum")
        exclusiveMaximum = try? map.value("exclusiveMaximum")
        minimum = try? map.value("minimum")
        exclusiveMinimum = try? map.value("exclusiveMinimum")
        multipleOf = try? map.value("multipleOf")
    }

    func build(_ swagger: SwaggerBuilder) throws -> NumberItem {
        return NumberItem(format: self.format,maximum: self.maximum, exclusiveMaximum: self.exclusiveMaximum,
                          minimum: self.minimum, exclusiveMinimum: self.exclusiveMinimum, multipleOf: self.multipleOf)
    }
}
