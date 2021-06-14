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
        if isDirectory {
            return FileManager.default.enumerator(atPath: path)?.map{ self.appending($0 as! String) }
                .flatMap{ (url: URL) -> [URL] in
                if recursive && url.isDirectory { return url.files(recursive: recursive, filter)
                } else { return [url] }
            }.filter(filter) ?? [URL]()
        } else if filter(self) {
            return [self]
        } else {
            return [URL]()
        }
    }
    
    func delete() {
        try? FileManager.default.removeItem(at: self)
    }
    
    func dump(_ contents: String) {
        FileManager.default.createFile(atPath: path, contents: contents.data(using: .utf8), attributes: [:])
    }
}
