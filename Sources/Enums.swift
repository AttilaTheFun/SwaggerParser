import Foundation

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

public enum SimpleDataType: String {
    case string = "string"
    case number = "number"
    case integer = "integer"
    case boolean = "boolean"
    case array = "array"
    case file = "file"
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
