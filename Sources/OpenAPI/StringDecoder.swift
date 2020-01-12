import Foundation

public protocol StringDecoder: class {
    func decode<T>(_ type: T.Type, from string: String) throws -> T where T : Decodable
}

extension JSONDecoder: StringDecoder {
    public func decode<T>(_ type: T.Type, from string: String) throws -> T where T : Decodable {
        guard let data = string.data(using: .utf8) else {
            throw DecodingError("Unable to extract data from string in utf8 encoding")
        }
        return try self.decode(T.self, from: data)
    }
}
