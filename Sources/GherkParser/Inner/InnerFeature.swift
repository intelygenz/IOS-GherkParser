import Foundation

struct InnerFeature {
    let annotations: [String]
    let featureDescription: String
    let scenarios: [InnerScenario]
    let background: InnerScenario?
}
