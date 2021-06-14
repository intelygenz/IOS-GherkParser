import Foundation

class FeatureParser {
    static func from(_ url: URL) throws -> InnerFeature? {
        let lines = try String(contentsOf: url, encoding: .utf8)
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.first != "#" && $0.count > 0 }
        
        guard !lines.isEmpty else { return nil }
        let fileState = FileMachineState()
        try lines.enumerated().forEach { index, line in
            if let (linePrefix, lineSuffix) = line.lineComponents(FileTags.stringValues) {
                switch FileTags.value(of: linePrefix) {
                case .Background : try fileState.hitScenario(true, lineSuffix)
                case .Scenario : try fileState.hitScenario(false, lineSuffix)
                case .Given, .When, .Then, .And: fileState.hitStep(linePrefix, lineSuffix)
                case .Outline: try fileState.hitScenario(false, lineSuffix)
                case .Examples: fileState.hitExamples()
                case .ExampleLine: fileState.hitExampleLine(lineSuffix)
                case .Feature: try fileState.hitFeature(lineSuffix)
                case .Annotation: fileState.hitAnnotation(lineSuffix)
                default: break
                }
            }
        }
        return try fileState.build()
    }
}

private enum FileTags: String {
    case Feature = "Feature:"
    case Background = "Background:"
    case Scenario = "Scenario:"
    case Outline = "Scenario Outline:"
    case Examples = "Examples:"
    case ExampleLine = "|"
    case Given = "Given"
    case When = "When"
    case Then = "Then"
    case And = "And"
    case Annotation = "@"
    
    static var values: [FileTags] { [.Feature, .Background, .Scenario, .Outline, .Examples, .ExampleLine, .Given, .When, .Then, .And, .Annotation] }
    static var stringValues: [String] { values.map { $0.rawValue } }
    static func value(of: String) -> FileTags? { values.first { $0.rawValue == of } }
}

private class FileMachineState {
    
    private var feature: FeatureMachineState?
    private var annotations = [String]()
    
    func hitAnnotation(_ annotation: String) {
        guard let feature = self.feature else { annotations.append(annotation); return }
        feature.hitAnnotation(annotation)
    }
    
    func hitFeature(_ description: String) throws {
        if let _ = self.feature { throw ParserError.duplicatedFeatureInFile(description) }
        self.feature = FeatureMachineState(description)
    }
    
    func hitScenario(_ isBackground: Bool = false, _ description: String) throws { try feature?.hitScenario(isBackground, description) }
    func hitStep(_ tag: String, _ description: String) { feature?.hitStep(tag, description) }
    func hitExamples() { feature?.hitExamples() }
    func hitExampleLine(_ example: String) { feature?.hitExampleLine(example) }
    
    
    
    
    func build() throws -> InnerFeature {
        guard let feature = self.feature else { throw ParserError.nonFeaturesFound }
        let innerFeature = feature.build(annotations)
        annotations = [String]()
        self.feature = nil
        return innerFeature
    }
}


private class FeatureMachineState {
    private let description: String
    private var index: Int = 0
    private var scenarios = [InnerScenario]()
    private var background: InnerScenario?
    
    
    private var annotations = [String]()
    private var nextScenarioAnnotations = [String]()
    private var isBackground: Bool = false
    private var scenarioDescription: String? = nil
    private var steps: [InnerStep]? = nil
    
    private var exampleState: ExampleMachineState?
    
    
    init(_ description: String) { self.description = description }
    
    func hitAnnotation(_ annotation: String) {
        nextScenarioAnnotations.append(annotation)
    }
    
    func hitScenario(_ isBackground: Bool = false, _ description: String) throws {
        hitEndPreviousBlock()
        if isBackground && self.background != nil { throw ParserError.duplicatedBackground(self.description) }
        self.isBackground = isBackground
        self.scenarioDescription = description
        self.steps = [InnerStep]()
    }
    
    func hitStep(_ tag: String, _ description: String) {
        self.steps?.append(InnerStep(tag: tag, step: description))
    }
    
    func hitExamples() {
        self.exampleState = ExampleMachineState()
    }
    
    func hitExampleLine(_ example: String) {
        self.exampleState?.hitExampleLine(example)
    }

    private func hitEndPreviousBlock() {
        let scenarioAnnotations = self.annotations
        self.annotations = self.nextScenarioAnnotations
        self.nextScenarioAnnotations = []
        
        guard let description = self.scenarioDescription, let steps = self.steps else { return }
        
        let newScenario = InnerScenario(annotations: scenarioAnnotations, scenarioDescription: description, stepDescriptions: steps, index: index)
        if isBackground {
            background = newScenario
        } else {
            let newScenarios = exampleState?.build(newScenario, self.index) ?? [newScenario]
            self.scenarios.append(contentsOf: newScenarios)
            self.index = self.index + newScenarios.count
        }
        
        self.scenarioDescription = nil
        self.steps = nil
    }
    
    func build(_ annotations: [String]) -> InnerFeature {
        hitEndPreviousBlock()
        return InnerFeature(annotations: annotations, featureDescription: description, scenarios: scenarios, background: background)
    }
}


private class ExampleMachineState {
    private var examples = [String]()
    func hitExampleLine(_ line: String) { examples.append(line) }
    func build(_ scenario: InnerScenario,_ index: Int) -> [InnerScenario] {
        guard examples.count >= 2 else { return [scenario] }
        var exampleLines = examples
        let headers: [String] = exampleLines.removeFirst().components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        let examples: [[String: String]] = exampleLines.map{
            let values: [String] = $0.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
            var dictionary = [String: String]()
            headers.enumerated().forEach{ index, header in dictionary[header] = values[index] }
            return dictionary
        }
        return examples.enumerated().map{ exampleIndex, example in
            InnerScenario(annotations: scenario.annotations,
                          scenarioDescription: "\(scenario.scenarioDescription)Example\(exampleIndex+1)",
                          stepDescriptions: scenario.stepDescriptions.map { step in
                            let stepValue = example.keys.reduce(step.step) { result, key in result.replacingOccurrences(of: "<\(key)>", with: example[key] ?? "") }
                            return InnerStep(tag: step.tag, step: stepValue)
                          },
                          index: index + exampleIndex)
        }
        
    }
}
