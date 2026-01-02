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

@Suite("RFC 768 Tests")
struct RFC_768_Tests {

    // MARK: - Port Tests

    @Suite("Port")
    struct PortTests {

        @Test("Port initialization")
        func portInit() {
            let port = RFC_768.Port(8080)
            #expect(port.rawValue == 8080)
        }

        @Test("Well-known port constants")
        func wellKnownPorts() {
            #expect(RFC_768.Port.dns.rawValue == 53)
            #expect(RFC_768.Port.dhcp.rawValue == 67)
            #expect(RFC_768.Port.tftp.rawValue == 69)
            #expect(RFC_768.Port.ntp.rawValue == 123)
            #expect(RFC_768.Port.snmp.rawValue == 161)
            #expect(RFC_768.Port.syslog.rawValue == 514)
        }

        @Test("Port classification")
        func portClassification() {
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

        @Test("Port byte parsing")
        func portByteParsing() throws {
            let bytes: [UInt8] = [0x1F, 0x90]  // 8080 in big-endian
            let port = try RFC_768.Port(bytes: bytes)
            #expect(port.rawValue == 8080)
        }

        @Test("Port serialization")
        func portSerialization() {
            let port = RFC_768.Port(8080)
            var buffer: [UInt8] = []
            RFC_768.Port.serialize(port, into: &buffer)
            #expect(buffer == [0x1F, 0x90])
        }
    }

    // MARK: - Length Tests

    @Suite("Length")
    struct LengthTests {

        @Test("Valid length creation")
        func validLength() throws {
            let length = try RFC_768.Length(20)
            #expect(length.rawValue == 20)
            #expect(length.data == 12)  // 20 - 8 = 12 bytes of data
        }

        @Test("Minimum length")
        func minimumLength() throws {
            let length = try RFC_768.Length(8)
            #expect(length.rawValue == 8)
            #expect(length.data == 0)
        }

        @Test("Length too short throws")
        func lengthTooShort() {
            #expect(throws: RFC_768.Length.Error.self) {
                try RFC_768.Length(7)
            }
        }

        @Test("Length byte parsing")
        func lengthByteParsing() throws {
            let bytes: [UInt8] = [0x00, 0x14]  // 20 in big-endian
            let length = try RFC_768.Length(bytes: bytes)
            #expect(length.rawValue == 20)
        }
    }

    // MARK: - Checksum Tests

    @Suite("Checksum")
    struct ChecksumTests {

        @Test("Zero checksum indicates absent")
        func zeroChecksum() {
            #expect(RFC_768.Checksum.zero.rawValue == 0)
            #expect(RFC_768.Checksum.zero.isAbsent)
        }

        @Test("Non-zero checksum is not absent")
        func nonZeroChecksum() {
            let checksum = RFC_768.Checksum(rawValue: 0xABCD)
            #expect(!checksum.isAbsent)
        }
    }

    // MARK: - Header Tests

    @Suite("Header")
    struct HeaderTests {

        @Test("Header creation")
        func headerCreation() throws {
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

        @Test("Header byte parsing")
        func headerByteParsing() throws {
            // Source: 12345 (0x3039), Dest: 53 (0x0035), Length: 20 (0x0014), Checksum: 0
            let bytes: [UInt8] = [
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

        @Test("Header serialization roundtrip")
        func headerRoundtrip() throws {
            let original = RFC_768.Header(
                source: .init(8080),
                destination: .ntp,
                length: try .init(16),
                checksum: RFC_768.Checksum(rawValue: 0xABCD)
            )
            var buffer: [UInt8] = []
            RFC_768.Header.serialize(original, into: &buffer)

            let parsed = try RFC_768.Header(bytes: buffer)
            #expect(parsed.source == original.source)
            #expect(parsed.destination == original.destination)
            #expect(parsed.length.rawValue == original.length.rawValue)
            #expect(parsed.checksum == original.checksum)
        }
    }

    // MARK: - Datagram Tests

    @Suite("Datagram")
    struct DatagramTests {

        @Test("Datagram creation with auto length")
        func datagramCreation() throws {
            let data: [UInt8] = [0x01, 0x02, 0x03, 0x04]
            let datagram = try RFC_768.Datagram(
                source: .init(12345),
                destination: .dns,
                data: data
            )
            #expect(datagram.header.length.rawValue == 12)  // 8 + 4
            #expect(datagram.data == data)
        }

        @Test("Datagram serialization roundtrip")
        func datagramRoundtrip() throws {
            let original = try RFC_768.Datagram(
                source: .init(8080),
                destination: .syslog,
                data: [0xDE, 0xAD, 0xBE, 0xEF]
            )
            var buffer: [UInt8] = []
            RFC_768.Datagram.serialize(original, into: &buffer)

            let parsed = try RFC_768.Datagram(bytes: buffer)
            #expect(parsed.header.source == original.header.source)
            #expect(parsed.header.destination == original.header.destination)
            #expect(parsed.data == original.data)
        }
    }

    // MARK: - Constants Tests

    @Suite("Constants")
    struct ConstantsTests {

        @Test("Protocol number")
        func protocolNumber() {
            #expect(RFC_768.protocolNumber == 17)
        }

        @Test("Minimum length")
        func minimumLength() {
            #expect(RFC_768.minimumLength == 8)
        }

        @Test("Header size")
        func headerSize() {
            #expect(RFC_768.headerSize == 8)
        }
    }
}
