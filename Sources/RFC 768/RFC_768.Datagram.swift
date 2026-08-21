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

import Standard_Library_Extensions

extension RFC_768 {
    /// Complete UDP datagram per RFC 768
    ///
    /// Combines the UDP header with the payload data.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let datagram = try RFC_768.Datagram(
    ///     source: 12345,
    ///     destination: .dns,
    ///     data: [0x00, 0x01, 0x00, 0x00]  // DNS query start
    /// )
    /// ```
    public struct Datagram: Hashable, Sendable {
        public let header: Header
        public let data: [Byte]

        /// Creates a datagram from a header and data
        ///
        /// - Parameters:
        ///   - header: The UDP header
        ///   - data: The payload data
        public init(header: Header, data: [Byte]) {
            self.header = header
            self.data = data
        }

        // Stdlib-interop UInt8 forwarder lives in `RFC 768 Standard Library
        // Integration` per [API-BYTE-007].
    }
}

// MARK: - Convenience Initializer

extension RFC_768.Datagram {
    /// Creates a datagram with automatic length calculation
    ///
    /// - Parameters:
    ///   - source: Source port
    ///   - destination: Destination port
    ///   - data: Payload data
    ///   - checksum: Checksum (default: zero/none)
    /// - Throws: `Error` if data is too large
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

    // Stdlib-interop UInt8 forwarder lives in `RFC 768 Standard Library
    // Integration` per [API-BYTE-007].
}

// MARK: - Checksum Operations

extension RFC_768.Datagram {
    /// Creates a new datagram with computed checksum
    ///
    /// - Parameter pseudoHeader: IP pseudo-header for checksum
    /// - Returns: Datagram with computed checksum
    public func withChecksum(
        pseudo pseudoHeader: RFC_768.PseudoHeader
    ) -> RFC_768.Datagram {
        // Serialize header with zero checksum
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

// MARK: - Byte Parsing

extension RFC_768.Datagram {
    /// Creates a Datagram from bytes
    ///
    /// - Parameter bytes: Binary data containing the datagram
    /// - Throws: `Error` if parsing fails
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

// MARK: - Binary.Serializable

extension RFC_768.Datagram: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ datagram: RFC_768.Datagram,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_768.Header.serialize(datagram.header, into: &buffer)
        buffer.append(contentsOf: datagram.data)
    }
}
