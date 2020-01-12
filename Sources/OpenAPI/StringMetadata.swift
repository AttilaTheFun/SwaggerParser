
public struct StringMetadata {
    /// The pattern keyword is used to restrict a string to a particular regular expression.
    /// The regular expression syntax is the one defined in JavaScript (ECMA 262 specifically).
    public let pattern: String?

    /// The minimum number of characters in the string. (Character defined by RFC 4627)
    /// If present, this value *must* be greater than or equal to zero.
    public let minLength: Int?

    /// The maximum number of characters in the string. (Character defined by RFC 4627)
    /// If present, this value *must* be greater than or equal to zero.
    public let maxLength: Int?
}

public struct StringMetadataBuilder: Codable {
    let pattern: String?
    let minLength: Int?
    let maxLength: Int?
}

extension StringMetadataBuilder: Builder {
    public typealias Building = StringMetadata

    public func build(_ swagger: SwaggerBuilder) throws -> StringMetadata {
        return StringMetadata(pattern: self.pattern, minLength: self.minLength, maxLength: self.maxLength)
    }
}
