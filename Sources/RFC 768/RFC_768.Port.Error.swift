extension RFC_768.Port {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty

        case insufficientBytes
    }
}

extension RFC_768.Port.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Port bytes cannot be empty"

        case .insufficientBytes:
            return "Port requires 2 bytes"
        }
    }
}
