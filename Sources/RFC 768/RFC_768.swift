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

/// RFC 768: User Datagram Protocol
///
/// This namespace implements the User Datagram Protocol (UDP) specification
/// as defined in RFC 768 (August 1980), authored by J. Postel. UDP provides
/// a connectionless, unreliable datagram service over IP networks.
///
/// ## Key Types
///
/// - ``Port``: 16-bit port number identifying endpoints
/// - ``Length``: Datagram length including header (minimum 8)
/// - ``Checksum``: One's complement checksum with pseudo-header
/// - ``Header``: 8-byte UDP header structure
/// - ``Datagram``: Complete datagram (header + data)
///
/// ## Protocol Overview
///
/// Per RFC 768, UDP provides a minimal transport layer mechanism:
/// - No connection setup required
/// - No delivery guarantee
/// - No duplicate protection
/// - Optional checksum
///
/// ## Constants
///
/// - Protocol number: 17 (decimal) in IP header
/// - Minimum length: 8 octets (header only)
///
/// ## Example
///
/// ```swift
/// let header = RFC_768.Header(
///     source: .init(12345),
///     destination: .dns,
///     length: try .init(20),
///     checksum: .zero
/// )
/// ```
///
/// ## See Also
///
/// - [RFC 768](https://www.rfc-editor.org/rfc/rfc768)
public enum RFC_768 {}
