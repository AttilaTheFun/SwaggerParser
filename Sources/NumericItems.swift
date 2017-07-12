import ObjectMapper

public struct NumericMetadata<T> {

    /// Specifies a minimum numeric value.
    public let maximum: T?

    /// When true, indicates that the range excludes the minimum value, i.e., x > min
    /// When false (or not included), indicates that the range includes the minimum value, i.e., x >= min
    public let exclusiveMaximum: T?

    /// Specifies a maximum numeric value.
    public let minimum: T?

    /// When true, it indicates that the range excludes the maximum value, i.e., x < max
    /// When false (or not included), it indicates that the range includes the maximum value, i.e., x <= max
    public let exclusiveMinimum: T?

    /// Restricts numbers to a multiple of a given number. It may be set to any positive number.
    public let multipleOf: T?
}

public struct IntegerItem {
    public let format: IntegerFormat?
    public let numericMetadata: NumericMetadata<Int>?
}

public struct NumberItem {
    public let format: NumberFormat?
    public let numericMetadata: NumericMetadata<Double>?
}

struct NumericMetadataBuilder<T>: Builder {

    typealias Building = NumericMetadata<T>

    let maximum: T?
    let exclusiveMaximum: T?
    let minimum: T?
    let exclusiveMinimum: T?
    let multipleOf: T?

    init(map: Map) throws {
        maximum = try? map.value("maximum")
        exclusiveMaximum = try? map.value("exclusiveMaximum")
        minimum = try? map.value("minimum")
        exclusiveMinimum = try? map.value("exclusiveMinimum")
        multipleOf = try? map.value("multipleOf")
    }

    func build(_ swagger: SwaggerBuilder) throws -> NumericMetadata<T> {
        return NumericMetadata(maximum: self.maximum, exclusiveMaximum: self.exclusiveMaximum,
                               minimum: self.minimum, exclusiveMinimum: self.exclusiveMinimum,
                               multipleOf: self.multipleOf)
    }
}

struct IntegerItemBuilder: Builder {

    typealias Building = IntegerItem

    let format: IntegerFormat?
    let numericMetadataBuilder: NumericMetadataBuilder<Int>?

    init(map: Map) throws {
        format = try? map.value("format")
        numericMetadataBuilder = try NumericMetadataBuilder(map: map)
    }

    func build(_ swagger: SwaggerBuilder) throws -> IntegerItem {
        return IntegerItem(format: self.format,
                           numericMetadata: try self.numericMetadataBuilder?.build(swagger))
    }
}

struct NumberItemBuilder: Builder {

    typealias Building = NumberItem

    let format: NumberFormat?
    let numericMetadataBuilder: NumericMetadataBuilder<Double>?

    init(map: Map) throws {
        format = try? map.value("format")
        numericMetadataBuilder = try NumericMetadataBuilder(map: map)
    }

    func build(_ swagger: SwaggerBuilder) throws -> NumberItem {
        return NumberItem(format: self.format,
                          numericMetadata: try self.numericMetadataBuilder?.build(swagger))
    }
}
