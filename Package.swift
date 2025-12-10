// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc5952 = "RFC 5952"
    var tests: Self { "\(self) Tests" }
}

extension Target.Dependency {
    static let rfc5952 = Self.target(name: .rfc5952)
    static let rfc4291 = Self.product(name: "RFC 4291", package: "swift-rfc-4291")
    static let standards = Self.product(name: "Standards", package: "swift-standards")
    static let incits41986 = Self.product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
    static let rfc4648 = Self.product(name: "RFC 4648", package: "swift-rfc-4648")
}

let package = Package(
    name: "swift-rfc-5952",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: .rfc5952, targets: [.rfc5952]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-4291", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.8.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.6.0"),
        .package(url: "https://github.com/swift-standards/swift-rfc-4648", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: .rfc5952,
            dependencies: [.rfc4291, .standards, .incits41986, .rfc4648]
        ),
        .testTarget(
            name: .rfc5952.tests,
            dependencies: [.rfc5952]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
