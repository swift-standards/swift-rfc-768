extension RFC_768.Length {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty

        case insufficientBytes

        case tooShort(_ value: UInt16)
    }
}

extension RFC_768.Length.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Length bytes cannot be empty"

        case .insufficientBytes:
            return "Length requires 2 bytes"

        case .tooShort(let value):
            return "Length \(value) is less than minimum \(RFC_768.minimumLength)"
        }
    }
}
