// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc768 = "RFC 768"
}

extension Target.Dependency {
    static let rfc768 = Self.target(name: .rfc768)
    static let standards = Self.product(name: "Standards", package: "swift-standards")
    static let incits41986 = Self.product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
    static let rfc791 = Self.product(name: "RFC 791", package: "swift-rfc-791")
}

let package = Package(
    name: "swift-rfc-768",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: .rfc768, targets: [.rfc768])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.10.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.6.3"),
        .package(url: "https://github.com/swift-standards/swift-rfc-791", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: .rfc768,
            dependencies: [.standards, .incits41986, .rfc791]
        ),
        .testTarget(
            name: .rfc768.tests,
            dependencies: [.rfc768]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}
