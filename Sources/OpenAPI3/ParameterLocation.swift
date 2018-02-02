public enum ParameterLocation: String, Codable {
    case path
    case query
    case header
    case cookie
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
