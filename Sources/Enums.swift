
public enum ParameterLocation: String, Codable {
    case path
    case query
    case header
    case cookie
}

public enum OAuth2Flow: String, Codable {
    case implicit
    case password
    case application
    case accessCode
}

public enum APIKeyLocation: String, Codable {
    case query
    case header
}

/// The HTTP verb corresponding to the operation's type.
public enum OperationType: String, Codable, CodingKey {
    case get
    case put
    case post
    case delete
    case options
    case head
    case patch
    case trace
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
    case csv

    /// Space separated values. E.g. "thingOne thingTwo"
    case ssv

    /// Tab separated values. E.g. "thingOne\tthingTwo"
    case tsv

    /// Pipe separated values. E.g. "thingOne|thingTwo"
    case pipes

    /// Corresponds to multiple parameter instances instead of multiple values for a single instance
    /// foo=bar&foo=baz. This is valid only for parameters in "query" or "formData".
    case multi
}

public enum TransferScheme: String, Codable {
    case http
    case https
    case ws
    case wss
}

/// Enumerates possible data types for Items or Schema specifications.
public enum DataType: String, Codable {
    case array
    case object
    case string
    case number
    case integer
    case boolean
    case file
    case null

    case enumeration
    case allOf
    case pointer
    case any

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
        if let typeString = try? values.decode(String.self, forKey: .type) {
            guard let dataType = DataType(rawValue: typeString) else {
                throw DecodingError("Unknown data type \(typeString)")
            }

            self = dataType
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .array, .object, .string, .number, .integer, .boolean, .file, .null:
            try container.encode(self.rawValue, forKey: .type)
        default:
            // Other types are inferred and will be encoded by their respective objects.
            break
        }
    }
}

public enum SerializationStyle: String, Codable {
    
    case matrix
    case label
    case form
    case simple
    case spaceDelimited
    case pipeDelimited
    case deepObject
    
}
