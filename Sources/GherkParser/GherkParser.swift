import Foundation

public class GherkParser {
    public init() {}
    public func parse(_ url: URL) throws -> [Feature] {
        guard url.fileExists else { throw ParserError.notValidPath }
        return try url.files(recursive: true) { url in url.path.hasSuffix(".feature") }
            .compactMap{ try FeatureParser.from($0) }
            .map { $0.toFeature() }
    }
}

private extension InnerFeature {
    func toFeature() -> Feature {
        Feature(annotations: annotations,
                featureDescription: featureDescription,
                scenarios: scenarios.map{ $0.toScenario(false) },
                background: background?.toScenario(true),
                description: description)
    }
}

private extension InnerScenario {
    func toScenario(_ isBackground: Bool) -> Scenario {
        Scenario(annotations: annotations,
                 scenarioDescription: scenarioDescription,
                 stepDescriptions: stepDescriptions.map { $0.toStep() },
                 index: index,
                 selectorString: selectorString,
                 selectorCString: selectorCString,
                 description: description,
                 isBackground: isBackground)
    }
}

private extension InnerStep {
    func toStep() -> Step {
        Step(tag: tag, name: step)
    }
}


public enum ParserError: Error {
    case notValidPath
    case nonFeaturesFound
    case duplicatedBackground(_ feature: String)
    case duplicatedFeatureInFile(_ feature: String)
}

public struct Feature: Equatable {
    public let annotations: [String]
    public let featureDescription: String
    public let scenarios: [Scenario]
    public let background: Scenario?
    public let description: String
}

public struct Scenario: Equatable {
    public let annotations: [String]
    public let scenarioDescription: String
    public let stepDescriptions: [Step]
    public let index: Int
    public let selectorString: String
    public let selectorCString: UnsafeMutablePointer<Int8>
    public let description: String
    public let isBackground: Bool
}

public struct Step: Equatable {
    public let tag: String
    public let name: String
}
