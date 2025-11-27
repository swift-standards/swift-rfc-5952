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

import Testing
@testable import RFC_5952
@testable import RFC_4291

@Suite("RFC 5952: IPv6 Text Representation Tests")
struct RFC5952Tests {

    // MARK: - RFC 5952 Section 4.1: Leading Zeros

    @Test("RFC 5952 Section 4.1: Leading zeros MUST be suppressed")
    func leadingZeroSuppression() throws {
        // 2001:0db8:0000:0000:0000:0000:0000:0001 → 2001:db8::1
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001)
        let text = String(address)

        #expect(text == "2001:db8::1")
        #expect(!text.contains("0db8"))  // No leading zero
        #expect(!text.contains("0001"))  // No leading zeros
    }

    // MARK: - RFC 5952 Section 4.2: :: Usage

    @Test("RFC 5952 Section 4.2.1: :: MUST be used for longest zero run")
    func compressionLongestRun() throws {
        // Multiple zero runs, longest should be compressed
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0x0000, 0x0000, 0x0000, 0x0001, 0x0000, 0x0001)
        let text = String(address)

        // The run of 3 zeros (indices 2-4) should be compressed
        #expect(text == "2001:db8::1:0:1")
    }

    @Test("RFC 5952 Section 4.2.2: Single zero MUST NOT use ::")
    func singleZeroNoCompression() throws {
        // Single zeros should be represented as "0", not "::"
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0x0000, 0x0001, 0x0000, 0x0002, 0x0000, 0x0003)
        let text = String(address)

        #expect(text == "2001:db8:0:1:0:2:0:3")
        #expect(!text.contains("::"))  // No compression for single zeros
    }

    @Test("RFC 5952 Section 4.2.3: Choose first occurrence when multiple equal runs")
    func compressionFirstOccurrence() throws {
        // Two runs of 2 zeros each - first should be compressed
        let address = RFC_4291.IPv6.Address(0x2001, 0x0000, 0x0000, 0x0001, 0x0000, 0x0000, 0x0001, 0x0001)
        let text = String(address)

        // The first run (indices 1-2) should be compressed
        #expect(text == "2001::1:0:0:1:1")
    }

    // MARK: - RFC 5952 Section 4.3: Lowercase

    @Test("RFC 5952 Section 4.3: Hexadecimal digits MUST be lowercase")
    func lowercaseHexadecimal() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0x0abc, 0x0def, 0x0000, 0x0000, 0x0000, 0x0001)
        let text = String(address)

        #expect(text == "2001:db8:abc:def::1")
        #expect(text.lowercased() == text)  // Must be all lowercase
        #expect(!text.contains("A"))
        #expect(!text.contains("B"))
        #expect(!text.contains("C"))
        #expect(!text.contains("D"))
        #expect(!text.contains("E"))
        #expect(!text.contains("F"))
    }

    // MARK: - Well-Known Addresses

    @Test("Unspecified address (::)")
    func unspecifiedAddress() throws {
        let address = RFC_4291.IPv6.Address.unspecified
        let text = String(address)

        #expect(text == "::")
    }

    @Test("Loopback address (::1)")
    func loopbackAddress() throws {
        let address = RFC_4291.IPv6.Address.loopback
        let text = String(address)

        #expect(text == "::1")
    }

    @Test("IPv4-mapped IPv6 address")
    func ipv4MappedAddress() throws {
        // ::ffff:192.0.2.1 (in pure IPv6 notation)
        let address = RFC_4291.IPv6.Address(0, 0, 0, 0, 0, 0xffff, 0xc000, 0x0201)
        let text = String(address)

        #expect(text == "::ffff:c000:201")
    }

    @Test("Documentation prefix (2001:db8::/32)")
    func documentationPrefix() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let text = String(address)

        #expect(text == "2001:db8::1")
    }

    @Test("Link-local address (fe80::)")
    func linkLocalAddress() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let text = String(address)

        #expect(text == "fe80::1")
    }

    @Test("Multicast address (ff02::1)")
    func multicastAddress() throws {
        let address = RFC_4291.IPv6.Address(0xff02, 0, 0, 0, 0, 0, 0, 1)
        let text = String(address)

        #expect(text == "ff02::1")
    }

    // MARK: - Edge Cases

    @Test("No compression needed - no zero runs")
    func noCompressionNeeded() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006)
        let text = String(address)

        #expect(text == "2001:db8:1:2:3:4:5:6")
        #expect(!text.contains("::"))
    }

    @Test("Compression at beginning")
    func compressionAtBeginning() throws {
        let address = RFC_4291.IPv6.Address(0, 0, 0, 1, 2, 3, 4, 5)
        let text = String(address)

        #expect(text == "::1:2:3:4:5")
    }

    @Test("Compression at end")
    func compressionAtEnd() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 1, 2, 0, 0, 0, 0)
        let text = String(address)

        #expect(text == "2001:db8:1:2::")
    }

    @Test("Compression in middle")
    func compressionInMiddle() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 1, 2)
        let text = String(address)

        #expect(text == "2001:db8::1:2")
    }

    @Test("Maximum value segments")
    func maximumValueSegments() throws {
        let address = RFC_4291.IPv6.Address(0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff)
        let text = String(address)

        #expect(text == "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")
    }

    // MARK: - Canonicalization Examples from RFC 5952

    @Test("RFC 5952 Example: 2001:db8:0:0:1:0:0:1")
    func rfc5952Example1() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 1, 0, 0, 1)
        let text = String(address)

        // Longest run is 2 zeros at position 2-3
        #expect(text == "2001:db8::1:0:0:1")
    }

    @Test("RFC 5952 Example: 2001:0db8:0:0:0:0:0:1")
    func rfc5952Example2() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let text = String(address)

        #expect(text == "2001:db8::1")
    }
}
