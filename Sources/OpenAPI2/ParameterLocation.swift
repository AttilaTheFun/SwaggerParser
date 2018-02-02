public enum ParameterLocation: String, Codable {
    case path
    case query
    case header
    case formData
    case body
}
