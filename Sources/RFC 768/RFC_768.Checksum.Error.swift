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

extension RFC_768.Checksum {
    /// Errors that can occur when parsing a Checksum
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Input bytes are empty
        case empty

        /// Insufficient bytes (need 2)
        case insufficientBytes
    }
}

extension RFC_768.Checksum.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Checksum bytes cannot be empty"
        case .insufficientBytes:
            return "Checksum requires 2 bytes"
        }
    }
}
