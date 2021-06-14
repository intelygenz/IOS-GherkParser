import Foundation

struct InnerStep {
    var tag: String
    var step: String
}

extension InnerStep: CustomStringConvertible {
    var description: String { "\(tag) \(step)" }
}
