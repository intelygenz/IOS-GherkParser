import Foundation

public extension URL {
    var fileExists: Bool { FileManager.default.fileExists(atPath: path) }
    var isDirectory: Bool {
        var bool = ObjCBool(false)
        FileManager.default.fileExists(atPath: path, isDirectory: &bool)
        return bool.boolValue
    }
    
    func appending(_ path: String) -> URL {
        var url = self
        url.appendPathComponent(path)
        return url
    }
    
    func files(recursive: Bool, _ filter: (URL) -> Bool) -> [URL] {
        var list = [URL]()
        var queue = [URL]()
        queue.append(self)
        while !queue.isEmpty {
            let first = queue.removeFirst()
            if(first.isDirectory) {
                let newURLs = FileManager.default.enumerator(atPath: first.path)?.map{ first.appending($0 as! String) } ?? [URL]()
                queue.append(contentsOf: newURLs)
            } else if filter(first) {
                list.append(first)
            }
        }
        return Set(list).map{ $0 }
    }
    
    func delete() {
        try? FileManager.default.removeItem(at: self)
    }
    
    func dump(_ contents: String) {
        FileManager.default.createFile(atPath: path, contents: contents.data(using: .utf8), attributes: [:])
    }
}
