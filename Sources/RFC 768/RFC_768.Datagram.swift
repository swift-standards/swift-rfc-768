import Standard_Library_Extensions

extension RFC_768 {

    public struct Datagram: Hashable, Sendable {
        public let header: Header
        public let data: [Byte]

        public init(header: Header, data: [Byte]) {
            self.header = header
            self.data = data
        }

    }
}

extension RFC_768.Datagram {

    public init(
        source: RFC_768.Port,
        destination: RFC_768.Port,
        data: [Byte],
        checksum: RFC_768.Checksum = .zero
    ) throws(Error) {
        let totalLength = RFC_768.headerSize + data.count

        guard totalLength <= Int(UInt16.max) else {
            throw .dataTooLarge(data.count)
        }

        let length: RFC_768.Length
        do throws(RFC_768.Length.Error) {
            length = try RFC_768.Length(UInt16(totalLength))
        } catch {
            throw .length(error)
        }

        self.header = RFC_768.Header(
            source: source,
            destination: destination,
            length: length,
            checksum: checksum
        )
        self.data = data
    }

}

extension RFC_768.Datagram {

    public func withChecksum(
        pseudo pseudoHeader: RFC_768.PseudoHeader
    ) -> RFC_768.Datagram {

        var headerBytes: [Byte] = []
        let tempHeader = RFC_768.Header(
            source: header.source,
            destination: header.destination,
            length: header.length,
            checksum: .zero
        )
        RFC_768.Header.serialize(tempHeader, into: &headerBytes)

        var pseudoBytes: [Byte] = []
        RFC_768.PseudoHeader.serialize(pseudoHeader, into: &pseudoBytes)

        let checksum = RFC_768.Checksum.compute(
            pseudo: pseudoBytes,
            header: headerBytes,
            data: data
        )

        let newHeader = RFC_768.Header(
            source: header.source,
            destination: header.destination,
            length: header.length,
            checksum: checksum
        )

        return RFC_768.Datagram(header: newHeader, data: data)
    }
}

extension RFC_768.Datagram {

    public init<Bytes: Swift.Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        let header: RFC_768.Header
        do throws(RFC_768.Header.Error) {
            header = try RFC_768.Header(bytes: bytes)
        } catch {
            throw .header(error)
        }

        let dataStart = bytes.index(bytes.startIndex, offsetBy: RFC_768.headerSize)
        let expectedDataLength = Int(header.length.data)
        let availableData = bytes.distance(from: dataStart, to: bytes.endIndex)

        guard availableData >= expectedDataLength else {
            throw .insufficientData(expected: expectedDataLength, got: availableData)
        }

        let dataEnd = bytes.index(dataStart, offsetBy: expectedDataLength)
        let data = Array(bytes[dataStart..<dataEnd])

        self.header = header
        self.data = data
    }
}

extension RFC_768.Datagram: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ datagram: RFC_768.Datagram,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_768.Header.serialize(datagram.header, into: &buffer)
        buffer.append(contentsOf: datagram.data)
    }
}
