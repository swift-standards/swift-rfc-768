import Standard_Library_Extensions

extension RFC_768 {

    public struct Checksum: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: UInt16

        private init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt16) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

extension RFC_768.Checksum {

    public static let zero = RFC_768.Checksum(__unchecked: (), rawValue: 0)
}

extension RFC_768.Checksum {

    public var isAbsent: Bool { rawValue == 0 }
}

extension RFC_768.Checksum {

    public static func compute<P, H, D>(
        pseudo pseudoHeader: P,
        header udpHeader: H,
        data: D
    ) -> RFC_768.Checksum
    where
        P: Swift.Collection,
        P.Element == Byte,
        H: Swift.Collection,
        H.Element == Byte,
        D: Swift.Collection,
        D.Element == Byte
    {

        var sum: UInt32 = 0

        sum = sumWords(sum, bytes: pseudoHeader)
        sum = sumWords(sum, bytes: udpHeader)
        sum = sumWords(sum, bytes: data)

        while sum > 0xFFFF {
            sum = (sum & 0xFFFF) + (sum >> 16)
        }

        var checksum = UInt16(~sum & 0xFFFF)

        if checksum == 0 {
            checksum = 0xFFFF
        }

        return RFC_768.Checksum(__unchecked: (), rawValue: checksum)
    }

    private static func sumWords<Bytes: Swift.Collection>(
        _ initial: UInt32,
        bytes: Bytes
    ) -> UInt32 where Bytes.Element == Byte {
        var sum = initial
        var iterator = bytes.makeIterator()

        while let high = iterator.next() {
            let low = iterator.next()?.underlying ?? 0
            sum += UInt32(high.underlying) << 8 | UInt32(low)
        }

        return sum
    }

    public static func verify<P, H, D>(
        pseudo pseudoHeader: P,
        header udpHeader: H,
        data: D
    ) -> Bool
    where
        P: Swift.Collection,
        P.Element == Byte,
        H: Swift.Collection,
        H.Element == Byte,
        D: Swift.Collection,
        D.Element == Byte
    {

        var sum: UInt32 = 0
        sum = sumWords(sum, bytes: pseudoHeader)
        sum = sumWords(sum, bytes: udpHeader)
        sum = sumWords(sum, bytes: data)

        while sum > 0xFFFF {
            sum = (sum & 0xFFFF) + (sum >> 16)
        }

        return sum == 0xFFFF
    }
}

extension RFC_768.Checksum {

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

extension RFC_768.Checksum: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ checksum: RFC_768.Checksum,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        buffer.append(contentsOf: checksum.rawValue.bytes(endianness: .big))
    }
}

extension RFC_768.Checksum: CustomStringConvertible {
    public var description: String {
        "0x\(String(rawValue, radix: 16, uppercase: true))"
    }
}
