import Foundation

extension Decodable {
    public init(JSONString string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw DecodingError("Unable to encode string data using utf8 encoding")
        }

        let jsonDecoder = JSONDecoder()
        self = try jsonDecoder.decode(Self.self, from: data)
    }
}
