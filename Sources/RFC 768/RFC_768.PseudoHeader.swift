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

public import RFC_791
public import Standard_Library_Extensions

extension RFC_768 {
    /// IPv4 Pseudo-header for UDP checksum calculation per RFC 768
    ///
    /// The pseudo header conceptually prefixed to the UDP header contains:
    /// - Source address (32 bits)
    /// - Destination address (32 bits)
    /// - Zero (8 bits)
    /// - Protocol (8 bits) = 17
    /// - UDP length (16 bits)
    ///
    /// ```
    /// 0      7 8     15 16    23 24    31
    /// +--------+--------+--------+--------+
    /// |          source address           |
    /// +--------+--------+--------+--------+
    /// |        destination address        |
    /// +--------+--------+--------+--------+
    /// |  zero  |protocol|   UDP length    |
    /// +--------+--------+--------+--------+
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let pseudo = RFC_768.PseudoHeader(
    ///     source: RFC_791.IPv4.Address(192, 168, 1, 1),
    ///     destination: RFC_791.IPv4.Address(192, 168, 1, 2),
    ///     length: 20
    /// )
    /// ```
    public struct PseudoHeader: Hashable, Sendable {
        /// Source IPv4 address
        public let source: RFC_791.IPv4.Address

        /// Destination IPv4 address
        public let destination: RFC_791.IPv4.Address

        /// UDP datagram length (header + data)
        public let length: UInt16

        /// Creates a pseudo-header for checksum computation
        ///
        /// - Parameters:
        ///   - source: Source IPv4 address
        ///   - destination: Destination IPv4 address
        ///   - length: UDP datagram length
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

// MARK: - Binary.Serializable

extension RFC_768.PseudoHeader: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ pseudoHeader: RFC_768.PseudoHeader,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        // Source address (4 bytes)
        RFC_791.IPv4.Address.serialize(pseudoHeader.source, into: &buffer)

        // Destination address (4 bytes)
        RFC_791.IPv4.Address.serialize(pseudoHeader.destination, into: &buffer)

        // Zero + Protocol (2 bytes)
        buffer.append(0)
        buffer.append(RFC_768.protocolNumber)

        // UDP length (2 bytes, big-endian)
        buffer.append(contentsOf: pseudoHeader.length.bytes(endianness: .big))
    }
}
