
import Foundation

private let camelCaseifyAllowedChars = CharacterSet(characters: "a"..."z", "A"..."Z", "0"..."9").union(camelCaseifySeparators)
private let camelCaseifySeparators = CharacterSet(characters: " ", "-")
private let camelCaseifyDisallowedChars = camelCaseifyAllowedChars.inverted

public extension String {
    
    var methodCamelCase: String { camelCaseify.lowercaseFirstLetterString }
    var classCamelCase: String { camelCaseify.uppercaseFirstLetterString }
    
    var camelCaseify: String {
        replacingCharacters(fromSet: camelCaseifyDisallowedChars)
            .components(separatedBy: camelCaseifySeparators)
            .map { $0.lowercased().uppercaseFirstLetterString }
            .joined(separator: "")
    }

    var uppercaseFirstLetterString: String {
        guard let firstCharacter = self.first else { return self }
        return String(firstCharacter).uppercased() + String(self.dropFirst())
    }
    
    var lowercaseFirstLetterString: String {
        guard let firstCharacter = self.first else { return self }
        return String(firstCharacter).lowercased() + String(self.dropFirst())
    }
    
    var humanReadableString: String {
        guard self.count > 1, let firstCharacter = self.first else { return self }
        return String(firstCharacter) + self.dropFirst().reduce("") { (word, character) in
            let letter = String(character)
            return letter == letter.uppercased() ? "\(word) \(letter)" : "\(word)\(letter)"
        }
    }
        
}


extension String {
    
    func componentsWithPrefix(_ prefix: String) -> (String, String?) {
        guard self.hasPrefix(prefix) else { return (self, nil) }
        
        let index = (prefix as NSString).length
        let suffix = (self as NSString).substring(from: index).trimmingCharacters(in: .whitespaces)
        return (prefix, suffix)
    }
    
    func lineComponents(_ prefixes: [String]) -> (String, String)? {
        if prefixes.count == 0 { return nil }
        let string = prefixes.first!
        let (prefix, suffix) = self.componentsWithPrefix(string)
        guard let s = suffix else { return lineComponents(Array(prefixes.dropFirst(1))) }
        return (prefix, s)
    }
    
}

private extension String {
        
    func replacingCharacters(fromSet characterSet: CharacterSet, with replacementString: String = "") -> String {
        return components(separatedBy: characterSet).joined(separator: replacementString)
    }
}

private extension CharacterSet {
    init(characters: CharacterSetMember...) {
        self.init()
        characters.forEach {
            if let closedRange = $0 as? ClosedRange<Unicode.Scalar> {
                insert(charactersIn: closedRange)
            } else if let character = $0 as? Unicode.Scalar {
                insert(character)
            } else if let string = $0 as? String {
                insert(charactersIn: string)
            }
        }
    }
}

private protocol CharacterSetMember { }
extension ClosedRange: CharacterSetMember where Bound == Unicode.Scalar { }
extension Unicode.Scalar: CharacterSetMember { }
extension String: CharacterSetMember { }
