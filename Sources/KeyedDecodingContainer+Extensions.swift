
private typealias RequiredDecoder = () throws -> Any
private typealias RequiredArrayDecoder = () throws -> [Any]
private typealias OptionalDecoder = () throws -> Any?
private typealias OptionalArrayDecoder = () throws -> [Any]?
private typealias DecoderSet = ([RequiredDecoder], RequiredArrayDecoder)

extension KeyedDecodingContainer {

    private func requiredDecoders(forKey key: Key) -> [RequiredDecoder] {
        return [
            { try self.decode(String.self, forKey: key) },
            { try self.decode(Bool.self, forKey: key) },
            { try self.decode(Int.self, forKey: key) },
            { try self.decode(Double.self, forKey: key) }
        ]
    }

    private func requiredArrayDecoders(forKey key: Key) -> [RequiredArrayDecoder] {
        return [
            { try self.decode([String].self, forKey: key) },
            { try self.decode([Bool].self, forKey: key) },
            { try self.decode([Int].self, forKey: key) },
            { try self.decode([Double].self, forKey: key) }
        ]
    }

    private func optionalDecoders(forKey key: Key) -> [OptionalDecoder] {
        return [
            { try self.decodeIfPresent(String.self, forKey: key) },
            { try self.decodeIfPresent(Bool.self, forKey: key) },
            { try self.decodeIfPresent(Int.self, forKey: key) },
            { try self.decodeIfPresent(Double.self, forKey: key) }
        ]
    }

    private func optionalArrayDecoders(forKey key: Key) -> [OptionalArrayDecoder] {
        return [
            { try self.decodeIfPresent([String].self, forKey: key) },
            { try self.decodeIfPresent([Bool].self, forKey: key) },
            { try self.decodeIfPresent([Int].self, forKey: key) },
            { try self.decodeIfPresent([Double].self, forKey: key) }
        ]
    }

    func decodeAny(forKey key: Key) throws -> Any {
        if !self.contains(key) {
            throw DecodingError("Key not found \(key.stringValue)")
        }

        for decoder in self.requiredDecoders(forKey: key) {
            if let value = try? decoder() {
                return value
            }
        }

        throw DecodingError("Unable to decode as Any")
    }

    func decodeAnyArray(forKey key: Key) throws -> [Any] {
        if !self.contains(key) {
            throw DecodingError("Key not found \(key.stringValue)")
        }

        for decoder in self.requiredArrayDecoders(forKey: key) {
            if let value = try? decoder() {
                return value
            }
        }

        throw DecodingError("Unable to decode as Any")
    }

    func decodeAnyIfPresent(forKey key: Key) throws -> Any? {
        if !self.contains(key) {
            return nil
        }

        if try self.decodeNil(forKey: key) {
            return nil
        }

        for decoder in self.optionalDecoders(forKey: key) {
            if let doubleOptional = try? decoder(), let value = doubleOptional {
                return value
            }
        }

        throw DecodingError("Unable to decode as Any")
    }

    func decodeAnyArrayIfPresent(forKey key: Key) throws -> [Any]? {
        if !self.contains(key) {
            return nil
        }

        if try self.decodeNil(forKey: key) {
            return nil
        }

        for decoder in self.optionalArrayDecoders(forKey: key) {
            if let doubleOptional = try? decoder(), let value = doubleOptional {
                return value
            }
        }

        throw DecodingError("Unable to decode as Any")
    }
}
