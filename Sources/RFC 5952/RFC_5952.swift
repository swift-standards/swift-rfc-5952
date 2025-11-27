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

// RFC_5952.swift
// swift-rfc-5952
//
// RFC 5952: A Recommendation for IPv6 Address Text Representation (August 2010)
// https://www.rfc-editor.org/rfc/rfc5952.html
//
// This package implements the canonical text representation of IPv6 addresses
// as specified in RFC 5952, which updates RFC 4291.
//
// Key features:
// - Lowercase hexadecimal (Section 4.3)
// - Leading zero suppression (Section 4.1)
// - `::` compression for longest zero sequence (Section 4.2)
// - Canonical representation uniqueness
//
// RFC 5952 provides the authoritative text representation that should be
// used by all systems displaying or serializing IPv6 addresses.

@_exported import RFC_4291

/// RFC 5952: A Recommendation for IPv6 Address Text Representation
///
/// This namespace provides the canonical text representation of IPv6 addresses.
///
/// ## Academic Significance
///
/// RFC 5952 defines a **universal property** in category theory terms - the unique
/// canonical text representation of IPv6 addresses. This resolves the ambiguity
/// present in RFC 4291, which allowed multiple valid representations of the same
/// address.
///
/// ## Canonical Form Rules (RFC 5952)
///
/// 1. **Lowercase hexadecimal** (Section 4.3): Use a-f, not A-F
/// 2. **Leading zeros MUST be suppressed** (Section 4.1): `2001:db8::1` not `2001:0db8::0001`
/// 3. **`::` MUST be used** to shorten the longest run of zeros (Section 4.2.2)
/// 4. **When multiple zero runs exist**, compress the first (Section 4.2.3)
/// 5. **Single zero field** MUST be represented as `0`, not `::` (Section 4.2.2)
///
/// ## Example
///
/// ```swift
/// import RFC_5952
///
/// let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
/// let canonical = String(address)  // "2001:db8::1"
/// ```
public enum RFC_5952 {}
