
extension KeyedEncodingContainer {

    // MARK: Any

    mutating func encodeAny(_ any: Any, forKey key: Key) throws {
        if let string = any as? String {
            try self.encode(string, forKey: key)
        } else if let bool = any as? Bool {
            try self.encode(bool, forKey: key)
        } else if let int = any as? Int {
            try self.encode(int, forKey: key)
        } else if let double = any as? Double {
            try self.encode(double, forKey: key)
        } else {
            throw EncodingError("Unable to cast value of type Any, \(any) to an encodable type")
        }
    }

    mutating func encodeAnyIfPresent(_ any: Any?, forKey key: Key) throws {
        guard let any = any else {
            return
        }

        try self.encodeAny(any, forKey: key)
    }

    // MARK: Array<Any>

    mutating func encodeArrayOfAny(_ anyArray: [Any], forKey key: Key) throws {
        if let string = anyArray as? [String] {
            try self.encode(string, forKey: key)
        } else if let bool = anyArray as? [Bool] {
            try self.encode(bool, forKey: key)
        } else if let int = anyArray as? [Int] {
            try self.encode(int, forKey: key)
        } else if let double = anyArray as? [Double] {
            try self.encode(double, forKey: key)
        } else {
            throw EncodingError("Unable to cast value of type Any, \(anyArray) to an encodable type")
        }
    }

    mutating func encodeArrayOfAnyIfPresent(_ anyArray: [Any]?, forKey key: Key) throws {
        guard let anyArray = anyArray else {
            return
        }

        try self.encodeArrayOfAny(anyArray, forKey: key)
    }

    // MARK: Array<Optional<Any>>

    mutating func encodeArrayOfOptionalAny(_ anyArray: [Any?], forKey key: Key) throws {
        if let string = anyArray as? [String?] {
            try self.encode(string, forKey: key)
        } else if let bool = anyArray as? [Bool?] {
            try self.encode(bool, forKey: key)
        } else if let int = anyArray as? [Int?] {
            try self.encode(int, forKey: key)
        } else if let double = anyArray as? [Double?] {
            try self.encode(double, forKey: key)
        } else {
            throw EncodingError("Unable to cast value of type Any, \(anyArray) to an encodable type")
        }
    }

    mutating func encodeArrayOfOptionalAnyIfPresent(_ anyArray: [Any?]?, forKey key: Key) throws {
        guard let anyArray = anyArray else {
            return
        }

        try self.encodeArrayOfOptionalAny(anyArray, forKey: key)
    }
}
