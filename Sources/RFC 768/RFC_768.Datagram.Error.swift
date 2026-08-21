extension RFC_768.Datagram {

    public enum Error: Swift.Error, Sendable, Equatable {

        case dataTooLarge(_ size: Int)

        case length(_ underlying: RFC_768.Length.Error)

        case header(_ underlying: RFC_768.Header.Error)

        case insufficientData(expected: Int, got: Int)
    }
}

extension RFC_768.Datagram.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dataTooLarge(let size):
            return "Data too large: \(size) bytes exceeds maximum"

        case .length(let error):
            return "Invalid length: \(error)"

        case .header(let error):
            return "Invalid header: \(error)"

        case .insufficientData(let expected, let got):
            return "Insufficient data: expected \(expected) bytes, got \(got)"
        }
    }
}
