import Foundation
@_exported import OpenAPI
@_exported import OpenAPI2
@_exported import OpenAPI3

public enum Swagger {
    case v2(OpenAPI2)
    case v3(OpenAPI3)

    public init(from string: String, decoder: StringDecoder = JSONDecoder()) throws {
        // TODO: parse version in optional way, don't try to load all
        do {
            self = .v2(try OpenAPI2(from: string, decoder: decoder))
        } catch {
            self = .v3(try OpenAPI3(from: string, decoder: decoder))
        }
    }

    static public func openApi2(from string: String, decoder: StringDecoder = JSONDecoder()) throws -> OpenAPI2 {
        return try OpenAPI2(from: string, decoder: decoder)
    }

    static public func openApi3(from string: String, decoder: StringDecoder = JSONDecoder()) throws -> OpenAPI3 {
        return try OpenAPI3(from: string, decoder: decoder)
    }
}
