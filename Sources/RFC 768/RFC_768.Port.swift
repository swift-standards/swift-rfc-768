import Standard_Library_Extensions

extension RFC_768 {

    public struct Port: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: UInt16

        private init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt16) {
            self.init(__unchecked: (), rawValue: rawValue)
        }

        public init(_ value: UInt16) {
            self.init(__unchecked: (), rawValue: value)
        }
    }
}

extension RFC_768.Port {

    public static let dns = Self(__unchecked: (), rawValue: 53)

    public static let dhcp = Self(__unchecked: (), rawValue: 67)

    public static let tftp = Self(__unchecked: (), rawValue: 69)

    public static let ntp = Self(__unchecked: (), rawValue: 123)

    public static let snmp = Self(__unchecked: (), rawValue: 161)

    public static let syslog = Self(__unchecked: (), rawValue: 514)
}

extension RFC_768.Port {

    public var isWellKnown: Bool { rawValue < 1024 }

    public var isRegistered: Bool { rawValue >= 1024 && rawValue < 49152 }

    public var isDynamic: Bool { rawValue >= 49152 }
}

extension RFC_768.Port {

    public init<Bytes: Swift.Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        var iterator = bytes.makeIterator()

        guard let high = iterator.next() else {
            throw .empty
        }
        guard let low = iterator.next() else {
            throw .insufficientBytes
        }

        let value = UInt16(high.underlying) << 8 | UInt16(low.underlying)
        self.init(__unchecked: (), rawValue: value)
    }
}

extension RFC_768.Port: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ port: RFC_768.Port,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        buffer.append(contentsOf: port.rawValue.bytes(endianness: .big))
    }
}

extension RFC_768.Port: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt16) {
        self.init(value)
    }
}

extension RFC_768.Port: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
