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
    /// UDP datagram length per RFC 768
    ///
    /// The length in octets of this user datagram including the header and data.
    /// Minimum value is 8 (header only).
    ///
    /// ## Binary Format
    ///
    /// Per RFC 768, the length field is 16 bits in network byte order.
    ///
    /// ## Constraints
    ///
    /// - Minimum: 8 (header size)
    /// - Maximum: 65535 (16-bit limit)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let length = try RFC_768.Length(20)  // 8 byte header + 12 bytes data
    /// print(length.data)  // 12
    /// ```
    public struct Length: Hashable, Sendable, Codable {
        public let rawValue: UInt16

        /// Creates a Length WITHOUT validation
        private init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a Length from a raw value
        ///
        /// - Parameter rawValue: The total datagram length (minimum 8)
        /// - Throws: `Error.tooShort` if less than minimum header size
        public init(rawValue: UInt16) throws(Error) {
            guard rawValue >= RFC_768.minimumLength else {
                throw .tooShort(rawValue)
            }
            self.init(__unchecked: (), rawValue: rawValue)
        }

        /// Creates a Length from a value
        ///
        /// - Parameter value: The total datagram length (minimum 8)
        /// - Throws: `Error.tooShort` if less than minimum header size
        public init(_ value: UInt16) throws(Error) {
            try self.init(rawValue: value)
        }
    }
}

// MARK: - Computed Properties

extension RFC_768.Length {
    /// Data length (total length minus header)
    ///
    /// Returns the number of data bytes in the datagram.
    public var data: UInt16 {
        rawValue - RFC_768.minimumLength
    }
}

// MARK: - Byte Parsing

extension RFC_768.Length {
    /// Creates a Length from bytes (big-endian)
    ///
    /// - Parameter bytes: Binary data containing the length (2 bytes)
    /// - Throws: `Error` if insufficient bytes or value too small
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        var iterator = bytes.makeIterator()

        guard let high = iterator.next() else {
            throw .empty
        }
        guard let low = iterator.next() else {
            throw .insufficientBytes
        }

        let value = UInt16(high) << 8 | UInt16(low)
        try self.init(rawValue: value)
    }
}

// MARK: - Binary.Serializable

extension RFC_768.Length: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ length: RFC_768.Length,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(UInt8(length.rawValue >> 8))
        buffer.append(UInt8(length.rawValue & 0xFF))
    }
}

// MARK: - CustomStringConvertible

extension RFC_768.Length: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
