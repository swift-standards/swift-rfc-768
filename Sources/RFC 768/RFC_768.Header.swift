import Standard_Library_Extensions

extension RFC_768 {

    public struct Header: Hashable, Sendable {
        public let source: Port
        public let destination: Port
        public let length: Length
        public let checksum: Checksum

        public init(
            source: Port,
            destination: Port,
            length: Length,
            checksum: Checksum
        ) {
            self.source = source
            self.destination = destination
            self.length = length
            self.checksum = checksum
        }
    }
}

extension RFC_768.Header {

    public init<Bytes: Swift.Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard bytes.count >= RFC_768.headerSize else {
            throw .insufficientBytes(bytes.count)
        }

        var index = bytes.startIndex

        func advance(_ count: Int) -> Bytes.SubSequence {
            let start = index
            index = bytes.index(index, offsetBy: count)
            return bytes[start..<index]
        }

        do throws(RFC_768.Port.Error) {
            self.source = try RFC_768.Port(bytes: advance(2))
        } catch {
            throw .source(error)
        }

        do throws(RFC_768.Port.Error) {
            self.destination = try RFC_768.Port(bytes: advance(2))
        } catch {
            throw .destination(error)
        }

        do throws(RFC_768.Length.Error) {
            self.length = try RFC_768.Length(bytes: advance(2))
        } catch {
            throw .length(error)
        }

        do throws(RFC_768.Checksum.Error) {
            self.checksum = try RFC_768.Checksum(bytes: advance(2))
        } catch {
            throw .checksum(error)
        }
    }
}

extension RFC_768.Header: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ header: RFC_768.Header,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_768.Port.serialize(header.source, into: &buffer)
        RFC_768.Port.serialize(header.destination, into: &buffer)
        RFC_768.Length.serialize(header.length, into: &buffer)
        RFC_768.Checksum.serialize(header.checksum, into: &buffer)
    }
}
