// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

import RFC_768
import Testing

extension RFC_768 {
    @Suite struct Test {

        @Suite struct Unit {

            @Suite struct Port {

                @Test
                func `Port initialization`() {
                    let port = RFC_768.Port(8080)
                    #expect(port.rawValue == 8080)
                }

                @Test
                func `Well-known port constants`() {
                    #expect(RFC_768.Port.dns.rawValue == 53)
                    #expect(RFC_768.Port.dhcp.rawValue == 67)
                    #expect(RFC_768.Port.tftp.rawValue == 69)
                    #expect(RFC_768.Port.ntp.rawValue == 123)
                    #expect(RFC_768.Port.snmp.rawValue == 161)
                    #expect(RFC_768.Port.syslog.rawValue == 514)
                }

                @Test
                func `Port classification`() {
                    let wellKnown = RFC_768.Port(80)
                    let registered = RFC_768.Port(8080)
                    let dynamic = RFC_768.Port(50000)

                    #expect(wellKnown.isWellKnown)
                    #expect(!wellKnown.isRegistered)
                    #expect(!wellKnown.isDynamic)

                    #expect(!registered.isWellKnown)
                    #expect(registered.isRegistered)
                    #expect(!registered.isDynamic)

                    #expect(!dynamic.isWellKnown)
                    #expect(!dynamic.isRegistered)
                    #expect(dynamic.isDynamic)
                }

                @Test
                func `Port byte parsing`() throws {
                    let bytes: [Byte] = [0x1F, 0x90]  // 8080 in big-endian
                    let port = try RFC_768.Port(bytes: bytes)
                    #expect(port.rawValue == 8080)
                }

                @Test
                func `Port serialization`() {
                    let port = RFC_768.Port(8080)
                    var buffer: [Byte] = []
                    RFC_768.Port.serialize(port, into: &buffer)
                    #expect(buffer == [0x1F, 0x90])
                }
            }

            @Suite struct Length {

                @Test
                func `Valid length creation`() throws {
                    let length = try RFC_768.Length(20)
                    #expect(length.rawValue == 20)
                    #expect(length.data == 12)  // 20 - 8 = 12 bytes of data
                }

                @Test
                func `Minimum length`() throws {
                    let length = try RFC_768.Length(8)
                    #expect(length.rawValue == 8)
                    #expect(length.data == 0)
                }

                @Test
                func `Length byte parsing`() throws {
                    let bytes: [Byte] = [0x00, 0x14]  // 20 in big-endian
                    let length = try RFC_768.Length(bytes: bytes)
                    #expect(length.rawValue == 20)
                }
            }

            @Suite struct Checksum {

                @Test
                func `Zero checksum indicates absent`() {
                    #expect(RFC_768.Checksum.zero.rawValue == 0)
                    #expect(RFC_768.Checksum.zero.isAbsent)
                }

                @Test
                func `Non-zero checksum is not absent`() {
                    let checksum = RFC_768.Checksum(rawValue: 0xABCD)
                    #expect(!checksum.isAbsent)
                }
            }

            @Suite struct Header {

                @Test
                func `Header creation`() throws {
                    let header = RFC_768.Header(
                        source: .init(12345),
                        destination: .dns,
                        length: try .init(20),
                        checksum: .zero
                    )
                    #expect(header.source.rawValue == 12345)
                    #expect(header.destination.rawValue == 53)
                    #expect(header.length.rawValue == 20)
                    #expect(header.checksum.isAbsent)
                }

                @Test
                func `Header byte parsing`() throws {
                    // Source: 12345 (0x3039), Dest: 53 (0x0035), Length: 20 (0x0014), Checksum: 0
                    let bytes: [Byte] = [
                        0x30, 0x39,  // Source port
                        0x00, 0x35,  // Destination port
                        0x00, 0x14,  // Length
                        0x00, 0x00,  // Checksum
                    ]
                    let header = try RFC_768.Header(bytes: bytes)
                    #expect(header.source.rawValue == 12345)
                    #expect(header.destination.rawValue == 53)
                    #expect(header.length.rawValue == 20)
                    #expect(header.checksum.rawValue == 0)
                }
            }

            @Suite struct Datagram {

                @Test
                func `Datagram creation with auto length`() throws {
                    let data: [Byte] = [0x01, 0x02, 0x03, 0x04]
                    let datagram = try RFC_768.Datagram(
                        source: .init(12345),
                        destination: .dns,
                        data: data
                    )
                    #expect(datagram.header.length.rawValue == 12)  // 8 + 4
                    #expect(datagram.data == data)
                }
            }

            @Suite struct Constants {

                @Test
                func `Protocol number`() {
                    #expect(RFC_768.protocolNumber == 17)
                }

                @Test
                func `Minimum length`() {
                    #expect(RFC_768.minimumLength == 8)
                }

                @Test
                func `Header size`() {
                    #expect(RFC_768.headerSize == 8)
                }
            }
        }

        @Suite struct `Edge Case` {

            @Test
            func `Length too short throws`() {
                #expect(throws: RFC_768.Length.Error.self) {
                    try RFC_768.Length(7)
                }
            }
        }

        @Suite struct Integration {

            @Test
            func `Header serialization roundtrip`() throws {
                let original = RFC_768.Header(
                    source: .init(8080),
                    destination: .ntp,
                    length: try .init(16),
                    checksum: RFC_768.Checksum(rawValue: 0xABCD)
                )
                var buffer: [Byte] = []
                RFC_768.Header.serialize(original, into: &buffer)

                let parsed = try RFC_768.Header(bytes: buffer)
                #expect(parsed.source == original.source)
                #expect(parsed.destination == original.destination)
                #expect(parsed.length.rawValue == original.length.rawValue)
                #expect(parsed.checksum == original.checksum)
            }

            @Test
            func `Datagram serialization roundtrip`() throws {
                let original = try RFC_768.Datagram(
                    source: .init(8080),
                    destination: .syslog,
                    data: [0xDE, 0xAD, 0xBE, 0xEF]
                )
                var buffer: [Byte] = []
                RFC_768.Datagram.serialize(original, into: &buffer)

                let parsed = try RFC_768.Datagram(bytes: buffer)
                #expect(parsed.header.source == original.header.source)
                #expect(parsed.header.destination == original.header.destination)
                #expect(parsed.data == original.data)
            }
        }
    }
}
