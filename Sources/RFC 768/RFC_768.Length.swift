import Standard_Library_Extensions

extension RFC_768 {

    public struct Length: Hashable, Sendable, Codable {
        public let rawValue: UInt16

        private init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt16) throws(Error) {
            guard rawValue >= RFC_768.minimumLength else {
                throw .tooShort(rawValue)
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }

        public init(_ value: UInt16) throws(Error) {
            try self.init(rawValue: value)
        }
    }
}

extension RFC_768.Length {

    public var data: UInt16 {
        rawValue - RFC_768.minimumLength
    }
}

extension RFC_768.Length {

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
        try self.init(rawValue: value)
    }
}

extension RFC_768.Length: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ length: RFC_768.Length,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        buffer.append(contentsOf: length.rawValue.bytes(endianness: .big))
    }
}

extension RFC_768.Length: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
