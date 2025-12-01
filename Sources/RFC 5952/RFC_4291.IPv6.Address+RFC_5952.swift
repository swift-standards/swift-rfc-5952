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

// RFC_4291.IPv6.Address+RFC_5952.swift
// swift-rfc-5952
//
// RFC 5952 canonical serialization conformance for IPv6 addresses

import RFC_4291
import RFC_4648

// MARK: - Canonical Serialization (RFC 5952)

extension RFC_4291.IPv6.Address {
    /// Canonical serializer per RFC 5952
    ///
    /// This overrides the RFC 4291 serializer with the canonical RFC 5952 format,
    /// which enforces:
    /// - Lowercase hexadecimal (Section 4.3)
    /// - Leading zero suppression (Section 4.1)
    /// - `::` compression for longest zero run (Section 4.2)
    ///
    /// ## Category Theory
    ///
    /// Natural transformation: RFC_4291.IPv6.Address → [UInt8]
    ///
    /// This is the authoritative serialization that all other representations
    /// (String, etc.) derive from.
    ///
    /// ## Implementation Note
    ///
    /// This static property is redeclared to use RFC 5952's canonical [UInt8].init(_:)
    /// instead of RFC 4291's implementation. When RFC 5952 is imported, this takes
    /// precedence as the canonical serialization.
    static public func serialize<Buffer>(
        _ address: RFC_4291.IPv6.Address,
        into buffer: inout Buffer
    ) where Buffer : RangeReplaceableCollection, Buffer.Element == UInt8 {
        let segments = [
            address.segments.0, address.segments.1, address.segments.2, address.segments.3,
            address.segments.4, address.segments.5, address.segments.6, address.segments.7
        ]

        // RFC 5952 Section 4.2: Find longest run of consecutive zeros
        var longestZeroRun: (start: Int, length: Int) = (0, 0)
        var currentZeroRun: (start: Int, length: Int) = (0, 0)
        var inZeroRun = false

        for (index, segment) in segments.enumerated() {
            if segment == 0 {
                if !inZeroRun {
                    currentZeroRun = (index, 1)
                    inZeroRun = true
                } else {
                    currentZeroRun.length += 1
                }

                // Section 4.2.3: When equal, choose first occurrence
                if currentZeroRun.length > longestZeroRun.length {
                    longestZeroRun = currentZeroRun
                }
            } else {
                inZeroRun = false
            }
        }

        // Only compress if run has more than 1 zero segment
        let shouldCompress = longestZeroRun.length > 1

        // Maximum uncompressed: "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff" = 39 bytes
        buffer.reserveCapacity(39)

        var skipNext = false

        for index in 0..<8 {
            // Handle compression
            if shouldCompress && index >= longestZeroRun.start && index < longestZeroRun.start + longestZeroRun.length {
                if index == longestZeroRun.start {
                    // Section 4.2.2: "::" replaces the run
                    buffer.append(.ascii.colon)
                    buffer.append(.ascii.colon)
                    skipNext = true
                }
                continue
            }

            // Add colon separator (but not before first segment or after ::)
            if index > 0 && !skipNext {
                buffer.append(.ascii.colon)
            }
            skipNext = false

            // Section 4.3: Lowercase hexadecimal
            // Section 4.1: Leading zeros suppressed
            RFC_4648.Base16.encode(segments[index], into: &buffer, suppressLeadingZeros: true)
        }
    }
}
