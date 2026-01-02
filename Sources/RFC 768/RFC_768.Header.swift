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
    /// UDP header per RFC 768
    ///
    /// The 8-octet UDP header consists of:
    /// - Source Port (16 bits)
    /// - Destination Port (16 bits)
    /// - Length (16 bits)
    /// - Checksum (16 bits)
    ///
    /// ```
    ///  0      7 8     15 16    23 24    31
    /// +--------+--------+--------+--------+
    /// |     Source      |   Destination   |
    /// |      Port       |      Port       |
    /// +--------+--------+--------+--------+
    /// |     Length      |    Checksum     |
    /// +--------+--------+--------+--------+
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let header = RFC_768.Header(
    ///     source: 12345,
    ///     destination: .dns,
    ///     length: try .init(20),
    ///     checksum: .zero
    /// )
    /// ```
    public struct Header: Hashable, Sendable {
        public let source: Port
        public let destination: Port
        public let length: Length
        public let checksum: Checksum

        /// Creates a UDP header
        ///
        /// - Parameters:
        ///   - source: Source port number
        ///   - destination: Destination port number
        ///   - length: Total datagram length
        ///   - checksum: UDP checksum
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

// MARK: - Byte Parsing

extension RFC_768.Header {
    /// Creates a Header from bytes
    ///
    /// - Parameter bytes: Binary data containing the header (8+ bytes)
    /// - Throws: `Error` if parsing fails
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard bytes.count >= RFC_768.headerSize else {
            throw .insufficientBytes(bytes.count)
        }

        var index = bytes.startIndex

        func advance(_ count: Int) -> Bytes.SubSequence {
            let start = index
            index = bytes.index(index, offsetBy: count)
            return bytes[start..<index]
        }

        do {
            self.source = try RFC_768.Port(bytes: advance(2))
        } catch {
            throw .source(error)
        }

        do {
            self.destination = try RFC_768.Port(bytes: advance(2))
        } catch {
            throw .destination(error)
        }

        do {
            self.length = try RFC_768.Length(bytes: advance(2))
        } catch {
            throw .length(error)
        }

        do {
            self.checksum = try RFC_768.Checksum(bytes: advance(2))
        } catch {
            throw .checksum(error)
        }
    }
}

// MARK: - Binary.Serializable

extension RFC_768.Header: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ header: RFC_768.Header,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        RFC_768.Port.serialize(header.source, into: &buffer)
        RFC_768.Port.serialize(header.destination, into: &buffer)
        RFC_768.Length.serialize(header.length, into: &buffer)
        RFC_768.Checksum.serialize(header.checksum, into: &buffer)
    }
}
