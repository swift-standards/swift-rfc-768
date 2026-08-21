internal import Byte_Primitives
public import RFC_768

extension RFC_768.Datagram {

    @_disfavoredOverload
    public init(header: RFC_768.Header, data: [UInt8]) {
        self.init(header: header, data: [Byte](data))
    }

    @_disfavoredOverload
    public init(
        source: RFC_768.Port,
        destination: RFC_768.Port,
        data: [UInt8],
        checksum: RFC_768.Checksum = .zero
    ) throws(RFC_768.Datagram.Error) {
        try self.init(
            source: source,
            destination: destination,
            data: [Byte](data),
            checksum: checksum
        )
    }
}
