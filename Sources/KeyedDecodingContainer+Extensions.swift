
extension KeyedDecodingContainer {

    private func anyDecoders(forKey key: Key) -> [() throws -> Any] {
        return [
            { try self.decode(String.self, forKey: key) },
            { try self.decode(Bool.self, forKey: key) },
            { try self.decode(Int.self, forKey: key) },
            { try self.decode(Double.self, forKey: key) }
        ]
    }

    private func arrayOfAnyDecoders(forKey key: Key) -> [() throws -> [Any]] {
        return [
            { try self.decode([String].self, forKey: key) },
            { try self.decode([Bool].self, forKey: key) },
            { try self.decode([Int].self, forKey: key) },
            { try self.decode([Double].self, forKey: key) }
        ]
    }

    private func arrayOfOptionalAnyDecoders(forKey key: Key) -> [() throws -> [Any?]] {
        return [
            { try self.decode([String?].self, forKey: key) },
            { try self.decode([Bool?].self, forKey: key) },
            { try self.decode([Int?].self, forKey: key) },
            { try self.decode([Double?].self, forKey: key) }
        ]
    }

    // MARK: Any

    func decodeAny(forKey key: Key) throws -> Any {
        if !self.contains(key) {
            throw DecodingError("Key not found \(key.stringValue)")
        }

        for decoder in self.anyDecoders(forKey: key) {
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

        return try self.decodeAny(forKey: key)
    }

    // MARK: Array<Any>

    func decodeAnyArray(forKey key: Key) throws -> [Any] {
        if !self.contains(key) {
            throw DecodingError("Key not found \(key.stringValue)")
        }

        for decoder in self.arrayOfAnyDecoders(forKey: key) {
            if let value = try? decoder() {
                return value
            }
        }

        throw DecodingError("Unable to decode as Any")
    }

    func decodeAnyArrayIfPresent(forKey key: Key) throws -> [Any]? {
        if !self.contains(key) {
            return nil
        }

        return try self.decodeAnyArray(forKey: key)
    }

    // MARK: Array<Optional<Any>>

    func decodeArrayOfOptionalAny(forKey key: Key) throws -> [Any?] {
        if !self.contains(key) {
            throw DecodingError("Key not found \(key.stringValue)")
        }

        for decoder in self.arrayOfOptionalAnyDecoders(forKey: key) {
            if let value = try? decoder() {
                return value
            }
        }

        throw DecodingError("Unable to decode as Any")
    }

    func decodeArrayOfOptionalAnyIfPresent(forKey key: Key) throws -> [Any?]? {
        if !self.contains(key) {
            return nil
        }

        return try self.decodeArrayOfOptionalAny(forKey: key)
    }
}
