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

public import Standard_Library_Extensions

extension RFC_768 {
    /// UDP checksum per RFC 768
    ///
    /// The 16-bit one's complement of the one's complement sum of a pseudo
    /// header of information from the IP header, the UDP header, and the data,
    /// padded with zero octets at the end (if necessary) to make a multiple
    /// of two octets.
    ///
    /// ## Special Values
    ///
    /// - If computed checksum is zero, transmit as all ones (0xFFFF)
    /// - Transmitted zero means no checksum was computed
    ///
    /// ## Example
    ///
    /// ```swift
    /// let checksum = RFC_768.Checksum(rawValue: 0xB861)
    /// let none = RFC_768.Checksum.zero  // No checksum computed
    /// ```
    public struct Checksum: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: UInt16

        /// Creates a Checksum WITHOUT validation
        private init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a Checksum from a raw value
        ///
        /// All 16-bit values are valid checksums.
        public init(rawValue: UInt16) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Static Constants

extension RFC_768.Checksum {
    /// Zero checksum indicates no checksum was computed
    ///
    /// Per RFC 768, a transmitted checksum of zero means the sender
    /// did not compute a checksum.
    public static let zero = RFC_768.Checksum(__unchecked: (), rawValue: 0)
}

// MARK: - Properties

extension RFC_768.Checksum {
    /// Returns true if no checksum was computed (transmitted as zero)
    public var isAbsent: Bool { rawValue == 0 }
}

// MARK: - Checksum Computation

extension RFC_768.Checksum {
    /// Computes UDP checksum over pseudo-header, UDP header, and data
    ///
    /// - Parameters:
    ///   - pseudoHeader: IP pseudo-header bytes
    ///   - udpHeader: UDP header bytes (with checksum field zero)
    ///   - data: UDP payload data
    /// - Returns: Computed checksum
    public static func compute<P, H, D>(
        pseudo pseudoHeader: P,
        header udpHeader: H,
        data: D
    ) -> RFC_768.Checksum
    where
        P: Swift.Collection,
        P.Element == Byte,
        H: Swift.Collection,
        H.Element == Byte,
        D: Swift.Collection,
        D.Element == Byte
    {

        var sum: UInt32 = 0

        sum = sumWords(sum, bytes: pseudoHeader)
        sum = sumWords(sum, bytes: udpHeader)
        sum = sumWords(sum, bytes: data)

        while sum > 0xFFFF {
            sum = (sum & 0xFFFF) + (sum >> 16)
        }

        var checksum = UInt16(~sum & 0xFFFF)

        if checksum == 0 {
            checksum = 0xFFFF
        }

        return RFC_768.Checksum(__unchecked: (), rawValue: checksum)
    }

    /// Sums 16-bit words from a byte collection
    private static func sumWords<Bytes: Swift.Collection>(
        _ initial: UInt32,
        bytes: Bytes
    ) -> UInt32 where Bytes.Element == Byte {
        var sum = initial
        var iterator = bytes.makeIterator()

        // UInt32 accumulator is arithmetic-domain; cross the byte-domain
        // boundary via .underlying.
        while let high = iterator.next() {
            let low = iterator.next()?.underlying ?? 0
            sum += UInt32(high.underlying) << 8 | UInt32(low)
        }

        return sum
    }

    /// Verifies checksum is valid
    ///
    /// - Parameters:
    ///   - pseudoHeader: IP pseudo-header bytes
    ///   - udpHeader: Complete UDP header including checksum
    ///   - data: UDP payload data
    /// - Returns: true if checksum is valid (or absent)
    public static func verify<P, H, D>(
        pseudo pseudoHeader: P,
        header udpHeader: H,
        data: D
    ) -> Bool
    where
        P: Swift.Collection,
        P.Element == Byte,
        H: Swift.Collection,
        H.Element == Byte,
        D: Swift.Collection,
        D.Element == Byte
    {

        var sum: UInt32 = 0
        sum = sumWords(sum, bytes: pseudoHeader)
        sum = sumWords(sum, bytes: udpHeader)
        sum = sumWords(sum, bytes: data)

        while sum > 0xFFFF {
            sum = (sum & 0xFFFF) + (sum >> 16)
        }

        return sum == 0xFFFF
    }
}

// MARK: - Byte Parsing

extension RFC_768.Checksum {
    /// Creates a Checksum from bytes (big-endian)
    ///
    /// - Parameter bytes: Binary data containing the checksum (2 bytes)
    /// - Throws: `Error` if there are insufficient bytes
    public init<Bytes: Swift.Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        var iterator = bytes.makeIterator()

        guard let high = iterator.next() else {
            throw .empty
        }
        guard let low = iterator.next() else {
            throw .insufficientBytes
        }

        // UInt16 storage is arithmetic-domain; cross the byte-domain boundary
        // via .underlying.
        let value = UInt16(high.underlying) << 8 | UInt16(low.underlying)
        self.init(__unchecked: (), rawValue: value)
    }
}

// MARK: - Binary.Serializable

extension RFC_768.Checksum: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ checksum: RFC_768.Checksum,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        // UInt16 → [Byte] via Byte-primary BinaryInteger.bytes(endianness:).
        buffer.append(contentsOf: checksum.rawValue.bytes(endianness: .big))
    }
}

// MARK: - CustomStringConvertible

extension RFC_768.Checksum: CustomStringConvertible {
    public var description: String {
        "0x\(String(rawValue, radix: 16, uppercase: true))"
    }
}
