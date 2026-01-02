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

extension RFC_768 {
    /// UDP protocol number for use in IP headers
    ///
    /// Per RFC 768, UDP uses protocol number 17 in the IP header's
    /// protocol field.
    public static let protocolNumber: UInt8 = 17

    /// Minimum datagram length (header only, no data)
    ///
    /// The UDP header is exactly 8 octets, so the minimum valid
    /// length field value is 8.
    public static let minimumLength: UInt16 = 8

    /// Header size in bytes
    ///
    /// The UDP header consists of 4 fields, each 16 bits (2 bytes),
    /// for a total of 8 bytes.
    public static let headerSize: Int = 8
}
