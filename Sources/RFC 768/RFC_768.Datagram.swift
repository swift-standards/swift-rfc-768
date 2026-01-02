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

public import Standards

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
        public let data: [UInt8]

        /// Creates a datagram from a header and data
        ///
        /// - Parameters:
        ///   - header: The UDP header
        ///   - data: The payload data
        public init(header: Header, data: [UInt8]) {
            self.header = header
            self.data = data
        }
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
        data: [UInt8],
        checksum: RFC_768.Checksum = .zero
    ) throws(Error) {
        let totalLength = RFC_768.headerSize + data.count

        guard totalLength <= Int(UInt16.max) else {
            throw .dataTooLarge(data.count)
        }

        let length: RFC_768.Length
        do {
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
        var headerBytes: [UInt8] = []
        let tempHeader = RFC_768.Header(
            source: header.source,
            destination: header.destination,
            length: header.length,
            checksum: .zero
        )
        RFC_768.Header.serialize(tempHeader, into: &headerBytes)

        var pseudoBytes: [UInt8] = []
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
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        let header: RFC_768.Header
        do {
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
    ) where Buffer.Element == UInt8 {
        RFC_768.Header.serialize(datagram.header, into: &buffer)
        buffer.append(contentsOf: datagram.data)
    }
}
