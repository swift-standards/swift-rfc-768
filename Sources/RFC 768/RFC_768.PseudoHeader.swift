public import RFC_791
import Standard_Library_Extensions

extension RFC_768 {

    public struct PseudoHeader: Hashable, Sendable {

        public let source: RFC_791.IPv4.Address

        public let destination: RFC_791.IPv4.Address

        public let length: UInt16

        public init(
            source: RFC_791.IPv4.Address,
            destination: RFC_791.IPv4.Address,
            length: UInt16
        ) {
            self.source = source
            self.destination = destination
            self.length = length
        }
    }
}

extension RFC_768.PseudoHeader: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ pseudoHeader: RFC_768.PseudoHeader,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        RFC_791.IPv4.Address.serialize(pseudoHeader.source, into: &buffer)

        RFC_791.IPv4.Address.serialize(pseudoHeader.destination, into: &buffer)

        buffer.append(0)
        buffer.append(Byte(RFC_768.protocolNumber))

        buffer.append(contentsOf: pseudoHeader.length.bytes(endianness: .big))
    }
}
