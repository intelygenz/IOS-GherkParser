import Foundation

struct InnerFeature {
    let annotations: [String]
    let featureDescription: String
    let scenarios: [InnerScenario]
    let background: InnerScenario?
}

extension InnerFeature: CustomStringConvertible {
    var description: String { "<\(type(of: self)) \(self.featureDescription) Background: \(background?.description ?? "No background"). \(self.scenarios.count) scenario(s)>" }
}
