import Foundation

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
    case file = "file"
    case allOf = "allOf"
    case pointer = "pointer"
    case any = "any"
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
