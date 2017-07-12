import ObjectMapper

public enum OAuth2FlowType: String {
    case implicit = "implicit"
    case password = "password"
    case application = "application"
    case accessCode = "accessCode"
}

public enum APIKeyLocation: String {
    case query = "query"
    case header = "header"
}

/// The HTTP verb corresponding to the operation's type.
public enum OperationType: String {
    case get
    case put
    case post
    case delete
    case options
    case head
    case patch
}

public enum IntegerFormat: String {

    /// Signed 32 bits
    case int32

    // Signed 64 bits
    case int64
}

/// Floating point number format.
public enum NumberFormat: String {

    /// Single precision
    case float
    case double
}

public enum CollectionFormat: String {

    /// Comma separated values. Default. E.g. "thingOne,thingTwo"
    case csv = "csv"

    /// Space separated values. E.g. "thingOne thingTwo"
    case ssv = "ssv"

    /// Tab separated values. E.g. "thingOne\tthingTwo"
    case tsv = "tsv"

    /// Pipe separated values. E.g. "thingOne|thingTwo"
    case pipes = "pipes"

    /// multi - corresponds to multiple parameter instances instead of multiple values for a single instance foo=bar&foo=baz.
    /// This is valid only for parameters in "query" or "formData".
}

public enum TransferScheme: String {
    case http = "http"
    case https = "https"
    case ws = "ws"
    case wss = "wss"
}

/// Enumerates possible data types for Items or Schema specifications.
public enum DataType: String {
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
}

extension DataType: ImmutableMappable {

    public init(map: Map) {
        if let typeString: String = try? map.value("type"), let mappedType = DataType(rawValue: typeString) {
            self = mappedType
        } else if map.JSON["$ref"] != nil {
            self = .pointer
        } else if map.JSON["items"] != nil {
            // Implicit array
            self = .array
        } else if map.JSON["properties"] != nil {
            // Implicit object
            self = .object
        } else if map.JSON["enum"] != nil {
            self = .enumeration
        } else if map.JSON["allOf"] != nil {
            self = .allOf
        } else {
            self = .any
        }
    }
}
