import Foundation

struct InnerScenario {
    let annotations: [String]
    let scenarioDescription: String
    let stepDescriptions: [InnerStep]
    let index: Int
}

extension InnerScenario: CustomStringConvertible {
    var description: String { "<\(type(of: self)) \(self.selectorString) \(self.stepDescriptions.count) steps>" }
    var selectorString: String { "test\(NSString(format: "%03i", index))\(self.scenarioDescription.camelCaseify)" }
    var selectorCString: UnsafeMutablePointer<Int8> { strdup(self.selectorString) }
}
