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

extension RFC_768.Datagram {
    /// Errors that can occur when parsing or creating a Datagram
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Data payload is too large for 16-bit length field
        case dataTooLarge(_ size: Int)

        /// Length field construction failed
        case length(_ underlying: RFC_768.Length.Error)

        /// Header parsing failed
        case header(_ underlying: RFC_768.Header.Error)

        /// Insufficient data bytes after header
        case insufficientData(expected: Int, got: Int)
    }
}

extension RFC_768.Datagram.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dataTooLarge(let size):
            return "Data too large: \(size) bytes exceeds maximum"
        case .length(let error):
            return "Invalid length: \(error)"
        case .header(let error):
            return "Invalid header: \(error)"
        case .insufficientData(let expected, let got):
            return "Insufficient data: expected \(expected) bytes, got \(got)"
        }
    }
}
