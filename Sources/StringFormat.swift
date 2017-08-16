
public enum StringFormat: RawRepresentable, Codable {
    
    public typealias RawValue = String
    
    /// Base64 encoded characters.
    case byte
    
    /// Any sequence of octets.
    case binary
    
    /// "full-date" representation, see RFC 3339, section 5.6.
    case date
    
    /// "date-time" representation, see RFC 3339, section 5.6.
    case dateTime
    
    /// Internet email address, see RFC 5322, section 3.4.1.
    case email
    
    /// Internet host name, see RFC 1034, section 3.1.
    case hostname
    
    /// IPv4 address, according to dotted-quad ABNF syntax as defined in RFC 2673, section 3.2.
    case ipv4
    
    /// IPv6 address, as defined in RFC 2373, section 2.2.
    case ipv6
    
    /// Used to hint UIs the input needs to be obscured.
    case password
    
    /// A custom format
    case other(String)
    
    /// A universal resource identifier (URI), according to RFC3986.
    case uri

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let rawFormat = try? value.decode(RawStringFormat.self) {
            self = rawFormat.stringFormat
            return
        }

        self = .other(try value.decode(String.self))
    }

    public init(rawValue: String) {
        self = RawStringFormat(rawValue: rawValue)?.stringFormat ?? .other(rawValue)
    }
    
    public var rawValue: String {
        switch self {
        case .byte: return RawStringFormat.byte.rawValue
        case .binary: return RawStringFormat.binary.rawValue
        case .date: return RawStringFormat.date.rawValue
        case .dateTime: return RawStringFormat.dateTime.rawValue
        case .email: return RawStringFormat.email.rawValue
        case .hostname: return RawStringFormat.hostname.rawValue
        case .ipv4: return RawStringFormat.ipv4.rawValue
        case .ipv6: return RawStringFormat.ipv6.rawValue
        case .password: return RawStringFormat.password.rawValue
        case .uri: return RawStringFormat.uri.rawValue
        case .other(let other): return other
        }
    }
    
    private enum RawStringFormat: String, Codable {
        case byte
        case binary
        case date
        case dateTime = "date-time"
        case email
        case hostname
        case ipv4
        case ipv6
        case password
        case uri
        
        var stringFormat: StringFormat {
            switch self {
            case .byte: return .byte
            case .binary: return .binary
            case .date: return.date
            case .dateTime: return .dateTime
            case .email: return .email
            case .hostname: return .hostname
            case .ipv4: return .ipv4
            case .ipv6: return .ipv6
            case .password: return .password
            case .uri: return .uri
            }
        }
    }
}
