
import Foundation

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
