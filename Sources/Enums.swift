import Foundation

public enum StringFormat: String {

    /// Base64 encoded characters
    case byte

    /// Any sequence of octets
    case binary

    /// As defined by full-date - RFC3339
    case date

    /// As defined by date-time - RFC3339
    case dateTime = "date-time"

    /// Used to hint UIs the input needs to be obscured.
    case password
}

public enum IntegerFormat: String {

    /// Signed 32 bits
    case int32

    // Signed 64 bits
    case int64
}

public enum NumberFormat: String {
    case float
    case double
}

public enum DataType: String {
    case array = "array"
    case object = "object"
    case string = "string"
    case number = "number"
    case integer = "integer"
    case enumeration = "enumeration"
    case boolean = "boolean"
    case allOf = "allOf"
}

public enum SimpleDataType: String {
    case string = "string"
    case number = "number"
    case integer = "integer"
    case boolean = "boolean"
    case array = "array"
    case file = "file"
}

public enum CollectionFormat: String {
    case csv = "csv"
    case ssv = "ssv"
    case tsv = "tsv"
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
