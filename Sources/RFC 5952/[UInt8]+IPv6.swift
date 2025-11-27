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

// [UInt8]+IPv6.swift
// swift-rfc-5952
//
// Canonical byte serialization for IPv6 addresses per RFC 5952

public import INCITS_4_1986
import RFC_4291
import RFC_4648

// MARK: - Canonical Serialization (Universal Property)

extension [UInt8] {
    /// Creates canonical ASCII byte representation of an IPv6 address (RFC 5952)
    ///
    /// This is the canonical serialization of IPv6 addresses to bytes.
    /// The format implements RFC 5952 rules:
    /// - **Section 4.1**: Leading zeros MUST be suppressed
    /// - **Section 4.2**: `::` MUST be used to compress longest run of zeros
    /// - **Section 4.2.3**: First occurrence wins when multiple equal runs exist
    /// - **Section 4.3**: Lowercase hexadecimal MUST be used
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: IPv6.Address (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// IPv6.Address → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Performance
    ///
    /// Direct ASCII generation without intermediate String allocations:
    /// - Pre-allocated capacity (39 bytes max for uncompressed)
    /// - Hex digit lookup table (RFC 4648 Base16)
    /// - Single-pass compression algorithm
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let loopback = RFC_4291.IPv6.Address.loopback
    /// String(decoding: [UInt8](ascii: loopback), as: UTF8.self)  // "::1"
    ///
    /// let full = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
    /// String(decoding: [UInt8](ascii: full), as: UTF8.self)  // "2001:db8::1"
    /// ```
    ///
    /// - Parameter address: The IPv6 address to serialize
    public init(ascii address: RFC_4291.IPv6.Address) {
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
        self = []
        self.reserveCapacity(39)

        var skipNext = false

        for index in 0..<8 {
            // Handle compression
            if shouldCompress && index >= longestZeroRun.start && index < longestZeroRun.start + longestZeroRun.length {
                if index == longestZeroRun.start {
                    // Section 4.2.2: "::" replaces the run
                    self.append(UInt8(ascii: ":"))
                    self.append(UInt8(ascii: ":"))
                    skipNext = true
                }
                continue
            }

            // Add colon separator (but not before first segment or after ::)
            if index > 0 && !skipNext {
                self.append(UInt8(ascii: ":"))
            }
            skipNext = false

            // Section 4.3: Lowercase hexadecimal
            // Section 4.1: Leading zeros suppressed
            appendHexSegment(segments[index])
        }
    }

    /// Appends a hexadecimal representation of a UInt16 segment with leading zeros suppressed
    ///
    /// RFC 5952 Section 4.1: Leading zeros MUST be suppressed
    /// RFC 5952 Section 4.3: Lowercase hexadecimal MUST be used
    ///
    /// - Parameter segment: The 16-bit segment value (0-65535)
    private mutating func appendHexSegment(_ segment: UInt16) {
        // Fast path for zero
        if segment == 0 {
            self.append(UInt8(ascii: "0"))
            return
        }

        // Use RFC 4648 Base16 encoding table (lowercase)
        let hexTable = RFC_4648.Base16.encodingTable.encode

        // Extract nibbles (4 bits each) - high to low
        let n3 = Int((segment >> 12) & 0x0F)  // Most significant
        let n2 = Int((segment >> 8) & 0x0F)
        let n1 = Int((segment >> 4) & 0x0F)
        let n0 = Int(segment & 0x0F)          // Least significant

        // Suppress leading zeros (Section 4.1)
        if n3 != 0 {
            self.append(hexTable[n3])
            self.append(hexTable[n2])
            self.append(hexTable[n1])
            self.append(hexTable[n0])
        } else if n2 != 0 {
            self.append(hexTable[n2])
            self.append(hexTable[n1])
            self.append(hexTable[n0])
        } else if n1 != 0 {
            self.append(hexTable[n1])
            self.append(hexTable[n0])
        } else {
            self.append(hexTable[n0])
        }
    }
}
