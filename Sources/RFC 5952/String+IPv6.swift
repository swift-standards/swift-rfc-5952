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

// String+IPv6.swift
// swift-rfc-5952
//
// Canonical text representation of IPv6 addresses per RFC 5952

import RFC_4291

extension String {
    /// Creates the canonical text representation of an IPv6 address per RFC 5952
    ///
    /// Implements RFC 5952's canonical format:
    /// 1. Lowercase hexadecimal (Section 4.3)
    /// 2. Leading zeros suppressed (Section 4.1)
    /// 3. `::` compresses longest zero run (Section 4.2)
    /// 4. First occurrence compressed when multiple equal-length runs exist (Section 4.2.3)
    ///
    /// ## Category Theory
    ///
    /// Derived composition through canonical byte representation:
    /// ```
    /// IPv6.Address → [UInt8] (ASCII) → String (UTF-8)
    /// ```
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Loopback
    /// let loopback = RFC_4291.IPv6.Address(0, 0, 0, 0, 0, 0, 0, 1)
    /// String(loopback)  // "::1"
    ///
    /// // Documentation prefix
    /// let docs = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
    /// String(docs)  // "2001:db8::1"
    ///
    /// // No compression (no zero runs > 1)
    /// let noComp = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 1, 0, 2, 0, 3)
    /// String(noComp)  // "2001:db8:0:1:0:2:0:3"
    /// ```
    ///
    /// - Parameter address: The IPv6 address to represent
    public init(_ address: RFC_4291.IPv6.Address) {
        // Compose through canonical byte representation
        // ASCII ⊂ UTF-8, so this is always valid
        self.init(decoding: [UInt8](address), as: UTF8.self)
    }
}
