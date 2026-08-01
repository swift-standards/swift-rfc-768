import RFC_768
import RFC_768_Standard_Library_Integration
import Testing

extension RFC_768.Datagram {
    @Suite struct Test {

        @Suite struct Unit {}

        @Suite struct `Edge Case` {}

        @Suite struct Integration {

            @Test
            func `init(header:data:) forwarder accepts [UInt8] payload`() throws {
                let header = RFC_768.Header(
                    source: .init(12345),
                    destination: .dns,
                    length: try .init(12),
                    checksum: .zero
                )
                let uint8Data: [UInt8] = [0x00, 0x01, 0x00, 0x00]
                let datagram = RFC_768.Datagram(header: header, data: uint8Data)
                #expect(datagram.data.count == 4)
                #expect(datagram.header.length.rawValue == 12)
            }

            @Test
            func `auto-length forwarder accepts [UInt8] payload`() throws {
                let uint8Data: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
                let datagram = try RFC_768.Datagram(
                    source: .init(8080),
                    destination: .syslog,
                    data: uint8Data
                )
                #expect(datagram.header.length.rawValue == 12)  // 8 header + 4 data
                #expect(datagram.data.count == 4)
            }
        }
    }
}
