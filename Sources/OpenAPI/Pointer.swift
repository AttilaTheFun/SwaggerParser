
public struct Pointer<T: Codable>: Codable {
    let path: String

    enum CodingKeys: String, CodingKey {
        case path = "$ref"
    }
}
