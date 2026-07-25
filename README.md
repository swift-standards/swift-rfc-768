# swift-rfc-768

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The UDP datagram header and semantics of RFC 768.

## Standard Reference

- **RFC**: 768
- **Title**: User Datagram Protocol

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-768.git", from: "0.1.0")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 768", package: "swift-rfc-768")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
