extension RFC_768.Checksum {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty

        case insufficientBytes
    }
}

extension RFC_768.Checksum.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Checksum bytes cannot be empty"

        case .insufficientBytes:
            return "Checksum requires 2 bytes"
        }
    }
}
