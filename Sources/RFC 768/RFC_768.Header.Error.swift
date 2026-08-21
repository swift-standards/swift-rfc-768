extension RFC_768.Header {

    public enum Error: Swift.Error, Sendable, Equatable {

        case insufficientBytes(_ count: Int)

        case source(_ underlying: RFC_768.Port.Error)

        case destination(_ underlying: RFC_768.Port.Error)

        case length(_ underlying: RFC_768.Length.Error)

        case checksum(_ underlying: RFC_768.Checksum.Error)
    }
}

extension RFC_768.Header.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes(let count):
            return "Header requires 8 bytes, got \(count)"

        case .source(let error):
            return "Invalid source port: \(error)"

        case .destination(let error):
            return "Invalid destination port: \(error)"

        case .length(let error):
            return "Invalid length: \(error)"

        case .checksum(let error):
            return "Invalid checksum: \(error)"
        }
    }
}
