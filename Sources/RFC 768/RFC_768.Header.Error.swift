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

extension RFC_768.Header {
    /// Errors that can occur when parsing a Header
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Insufficient bytes for header (need 8)
        case insufficientBytes(_ count: Int)

        /// Source port parsing failed
        case source(_ underlying: RFC_768.Port.Error)

        /// Destination port parsing failed
        case destination(_ underlying: RFC_768.Port.Error)

        /// Length parsing failed
        case length(_ underlying: RFC_768.Length.Error)

        /// Checksum parsing failed
        case checksum(_ underlying: RFC_768.Checksum.Error)
    }
}

extension RFC_768.Header.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes(let count):
            return "Header requires 8 bytes, got \(count)"
        case .source(let error):
            return "Invalid source port: \(error)"
        case .destination(let error):
            return "Invalid destination port: \(error)"
        case .length(let error):
            return "Invalid length: \(error)"
        case .checksum(let error):
            return "Invalid checksum: \(error)"
        }
    }
}
