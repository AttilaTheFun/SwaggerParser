
public struct NumericMetadata<T> {

    /// Specifies a maximum numeric value.
    public let minimum: T?

    /// When true, it indicates that the range excludes the maximum value, i.e., x < max
    /// When false (or not included), it indicates that the range includes the maximum value, i.e., x <= max
    public let exclusiveMinimum: T?

    /// Specifies a minimum numeric value.
    public let maximum: T?

    /// When true, indicates that the range excludes the minimum value, i.e., x > min
    /// When false (or not included), indicates that the range includes the minimum value, i.e., x >= min
    public let exclusiveMaximum: T?

    /// Restricts numbers to a multiple of a given number. It may be set to any positive number.
    public let multipleOf: T?
}

public struct NumericMetadataBuilder<T: Codable>: Codable {
    let minimum: T?
    let exclusiveMinimum: T?
    let maximum: T?
    let exclusiveMaximum: T?
    let multipleOf: T?
}

extension NumericMetadataBuilder: Builder {
    public typealias Building = NumericMetadata<T>

    public func build(_ swagger: SwaggerBuilder) throws -> NumericMetadata<T> {
        return NumericMetadata(
            minimum: self.minimum,
            exclusiveMinimum: self.exclusiveMinimum,
            maximum: self.maximum,
            exclusiveMaximum: self.exclusiveMaximum,
            multipleOf: self.multipleOf)
    }
}
