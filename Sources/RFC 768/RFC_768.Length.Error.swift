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

extension RFC_768.Length {
    /// Errors that can occur when parsing a Length
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Input bytes are empty
        case empty

        /// Insufficient bytes (need 2)
        case insufficientBytes

        /// Length value is less than minimum (8)
        case tooShort(_ value: UInt16)
    }
}

extension RFC_768.Length.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Length bytes cannot be empty"
        case .insufficientBytes:
            return "Length requires 2 bytes"
        case .tooShort(let value):
            return "Length \(value) is less than minimum \(RFC_768.minimumLength)"
        }
    }
}
