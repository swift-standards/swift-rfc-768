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
    /// UDP port number per RFC 768
    ///
    /// A 16-bit unsigned integer identifying the sending or receiving process.
    /// Port numbers 0-1023 are well-known ports, 1024-49151 are registered,
    /// and 49152-65535 are dynamic/private.
    ///
    /// ## Binary Format
    ///
    /// Per RFC 768, source and destination ports are 16-bit fields
    /// in network byte order (big-endian).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let port = RFC_768.Port(8080)
    /// let dns = RFC_768.Port.dns  // 53
    /// ```
    public struct Port: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: UInt16

        /// Creates a Port WITHOUT validation
        private init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a Port from a raw value
        ///
        /// All 16-bit values are valid port numbers.
        public init(rawValue: UInt16) {
            self.init(__unchecked: (), rawValue: rawValue)
        }

        /// Creates a Port from a raw value
        public init(_ value: UInt16) {
            self.init(__unchecked: (), rawValue: value)
        }
    }
}

// MARK: - Well-Known Ports

extension RFC_768.Port {
    /// DNS default port (53)
    public static let dns = Self(__unchecked: (), rawValue: 53)

    /// DHCP server port (67)
    public static let dhcp = Self(__unchecked: (), rawValue: 67)

    /// TFTP port (69)
    public static let tftp = Self(__unchecked: (), rawValue: 69)

    /// NTP port (123)
    public static let ntp = Self(__unchecked: (), rawValue: 123)

    /// SNMP port (161)
    public static let snmp = Self(__unchecked: (), rawValue: 161)

    /// Syslog port (514)
    public static let syslog = Self(__unchecked: (), rawValue: 514)
}

// MARK: - Classification

extension RFC_768.Port {
    /// Returns true if this is a well-known port (0-1023)
    public var isWellKnown: Bool { rawValue < 1024 }

    /// Returns true if this is a registered port (1024-49151)
    public var isRegistered: Bool { rawValue >= 1024 && rawValue < 49152 }

    /// Returns true if this is a dynamic/private port (49152-65535)
    public var isDynamic: Bool { rawValue >= 49152 }
}

// MARK: - Byte Parsing

extension RFC_768.Port {
    /// Creates a Port from bytes (big-endian)
    ///
    /// - Parameter bytes: Binary data containing the port (2 bytes)
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

extension RFC_768.Port: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ port: RFC_768.Port,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        // UInt16 → [Byte] via Byte-primary BinaryInteger.bytes(endianness:).
        buffer.append(contentsOf: port.rawValue.bytes(endianness: .big))
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension RFC_768.Port: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt16) {
        self.init(value)
    }
}

// MARK: - CustomStringConvertible

extension RFC_768.Port: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
