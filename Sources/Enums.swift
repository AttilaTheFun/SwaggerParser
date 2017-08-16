
public enum ParameterLocation: String, Codable {
    case query = "query"
    case header = "header"
    case path = "path"
    case formData = "formData"
    case body = "body"
}

public enum OAuth2Flow: String, Codable {
    case implicit = "implicit"
    case password = "password"
    case application = "application"
    case accessCode = "accessCode"
}

public enum APIKeyLocation: String, Codable {
    case query = "query"
    case header = "header"
}

/// The HTTP verb corresponding to the operation's type.
public enum OperationType: String, Codable {
    case get
    case put
    case post
    case delete
    case options
    case head
    case patch
}

public enum IntegerFormat: String, Codable {

    /// Signed 32 bits
    case int32

    // Signed 64 bits
    case int64
}

/// Floating point number format.
public enum NumberFormat: String, Codable {

    /// Single precision
    case float
    case double
}

public enum CollectionFormat: String, Codable {

    /// Comma separated values. Default. E.g. "thingOne,thingTwo"
    case csv = "csv"

    /// Space separated values. E.g. "thingOne thingTwo"
    case ssv = "ssv"

    /// Tab separated values. E.g. "thingOne\tthingTwo"
    case tsv = "tsv"

    /// Pipe separated values. E.g. "thingOne|thingTwo"
    case pipes = "pipes"

    /// Corresponds to multiple parameter instances instead of multiple values for a single instance
    /// foo=bar&foo=baz. This is valid only for parameters in "query" or "formData".
    case multi = "multi"
}

public enum TransferScheme: String, Codable {
    case http = "http"
    case https = "https"
    case ws = "ws"
    case wss = "wss"
}

/// Enumerates possible data types for Items or Schema specifications.
public enum DataType: String, Codable {
    case array = "array"
    case object = "object"
    case string = "string"
    case number = "number"
    case integer = "integer"
    case enumeration = "enumeration"
    case boolean = "boolean"
    case file = "file"
    case allOf = "allOf"
    case pointer = "pointer"
    case any = "any"

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case reference = "$ref"
        case items = "items"
        case properties = "properties"
        case enumeration = "enum"
        case allOf = "allOf"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if values.contains(.type) {
            guard let typeString = try? values.decode(String.self, forKey: .type),
                let type = DataType(rawValue: typeString) else
            {
                throw DecodingError("Unknown data type")
            }

            self = type
        } else if values.contains(.reference) {
            self = .pointer
        } else if values.contains(.items) {
            self = .array
        } else if values.contains(.properties) {
            self = .object
        } else if values.contains(.enumeration) {
            self = .enumeration
        } else if values.contains(.allOf) {
            self = .allOf
        } else {
            self = .any
        }
    }
}
