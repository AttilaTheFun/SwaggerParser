
public enum Version: Codable {
    indirect case subversion(UInt, Version)
    case version(UInt)

    private var value: UInt {
        switch self {
        case .subversion(let version, _):
            return version
        case .version(let version):
            return version
        }
    }

    private var subversion: Version? {
        switch self {
        case .subversion(_, let subversion):
            return subversion
        case .version:
            return nil
        }
    }

    public var major: UInt { return self.value }
    public var minor: UInt? { return self.subversion?.value }
    public var patch: UInt? { return self.subversion?.subversion?.value }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        var convertible: LosslessStringConvertible? = try? value.decode(String.self)
        convertible = convertible ?? (try? value.decode(Double.self))
        convertible = convertible ?? (try? value.decode(Float.self))
        guard let string = convertible?.description else {
            throw DecodingError("Unable to decode version")
        }

        try self.init(string)
    }

    public init(_ string: String) throws {
        let components = string.components(separatedBy: ".")
        let integerComponents = try components.map { component -> UInt in
            if let int = UInt(component) {
                return int
            }

            throw DecodingError("Unable to parse version component \(component) into integer")
        }

        guard let lastComponent = integerComponents.last else {
            throw DecodingError("Version components were empty")
        }

        self = integerComponents
            .dropLast()
            .reversed()
            .reduce(Version.version(lastComponent)) { subversion, component in
                return Version.subversion(component, subversion)
        }
    }

    public func encode(to encoder: Encoder) throws {
        let value = self.map { $0.value.description }.joined(separator: ".")
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension Version: Sequence {

    public struct Iterator: IteratorProtocol {
        private var version: Version?

        init(version: Version?) {
            self.version = version
        }

        public mutating func next() -> Version? {
            guard let version = self.version else {
                return nil
            }

            if case .subversion(_, let subversion) = version {
                self.version = subversion
            } else {
                self.version = nil
            }

            return version
        }
    }

    public func makeIterator() -> Iterator {
        return Iterator(version: self)
    }

    public var components: [UInt] {
        return self.map { $0.value }
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return self.map { String($0.value) }.joined(separator: ".")
    }
}

extension Version: Equatable {
    public static func ==(left: Version, right: Version) -> Bool {
        let leftArray = left.map { $0.value }
        let rightArray = right.map { $0.value }
        return leftArray == rightArray
    }
}

extension Version: Comparable {
    public static func <(left: Version, right: Version) -> Bool {
        let leftArray = left.components
        let rightArray = right.components
        for (index, value) in rightArray[0..<leftArray.count].enumerated() {
            let leftValue = leftArray[index]
            switch leftValue {
            case ..<value:
                return true
            case value...:
                return false
            default:
                continue
            }
        }

        if rightArray.count <= leftArray.count {
            return false
        }

        return rightArray[leftArray.count...].contains { $0 > 0 }
    }
}

