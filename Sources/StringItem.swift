import ObjectMapper

public struct StringItem {
    public let format: StringFormat?
    public let maxLength: Int?
    public let minLength: Int?
}

struct StringItemBuilder: Builder {

    typealias Building = StringItem
    let format: StringFormat?
    let maxLength: Int?
    let minLength: Int?

    init(map: Map) throws {
        format = try? map.value("format")
        maxLength = try? map.value("maxLength")
        minLength = (try? map.value("minLength")) ?? 0
    }

    func build(_ swagger: SwaggerBuilder) throws -> StringItem {
        return StringItem(format: self.format, maxLength: self.maxLength, minLength: self.minLength)
    }
}
