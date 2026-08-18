// swift-tools-version: 6.3.3
import PackageDescription

extension String {
    static let rfc768 = "RFC 768"
}

extension Target.Dependency {
    static let rfc768 = Self.target(name: .rfc768)
    static let standards = Self.product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    static let incits41986 = Self.product(name: "ASCII Primitives", package: "swift-ascii-primitives")
    static let rfc791 = Self.product(name: "RFC 791", package: "swift-rfc-791")
}

let package = Package(
    name: "swift-rfc-768",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27")
    ],
    products: [
        .library(name: "RFC 768", targets: ["RFC 768"]),
        .library(name: "RFC 768 Standard Library Integration", targets: ["RFC 768 Standard Library Integration"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-791.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RFC 768",
            dependencies: [.standards, .incits41986, .rfc791]
        ),
        .target(
            name: "RFC 768 Standard Library Integration",
            dependencies: [
                "RFC 768",
                .product(name: "Byte Primitives Standard Library Integration", package: "swift-byte-primitives"),
            ]
        ),
        .testTarget(
            name: "RFC 768 Tests",
            dependencies: [
                "RFC 768",
            ]
        ),
        .testTarget(
            name: "RFC 768 Standard Library Integration Tests",
            dependencies: [
                "RFC 768",
                "RFC 768 Standard Library Integration",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
