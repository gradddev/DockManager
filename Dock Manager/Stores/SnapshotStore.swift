import SwiftUI

class SnapshotStore: ObservableObject {
    @Published var snapshotNames: [String] = []
    
    init() {
        snapshotNames = getSnapshotNames()
    }
    
    private var fileManager: FileManager {
        get {
            return FileManager.default
        }
    }
    
    private var applicationSupportURL: URL {
        get {
            let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
            
            let applicationSupportURL = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )
                .first!
                .appendingPathComponent(appName)
            
            if (!fileManager.fileExists(atPath: applicationSupportURL.path)) {
                try! fileManager.createDirectory(at: applicationSupportURL, withIntermediateDirectories: false)
            }
            
            return applicationSupportURL
        }
    }
    
    private var dockPreferencesURL: URL {
        get {
            let libraryURL = fileManager.urls(
                for: .libraryDirectory,
                in: .userDomainMask
            )
                .first!
            
            let dockPreferencesURL = libraryURL
                .appendingPathComponent("Preferences", isDirectory: true)
                .appendingPathComponent("com.apple.dock.plist", isDirectory: false)
            
            return dockPreferencesURL
        }
    }

    private func getSnapshotNames() -> [String] {
        let fileNames = try! fileManager.contentsOfDirectory(atPath: applicationSupportURL.path)
        
        var snapshotNames = fileNames.map { fileName in
            return fileName.replacingOccurrences(
                of: "\\.plist$",
                with: "",
                options: [.regularExpression]
            )
        }
        snapshotNames.sort()

        return snapshotNames
    }
    
    func addSnapshot(_ snapshotName: String) {
        let snapshotURL = applicationSupportURL
            .appendingPathComponent("\(snapshotName).plist")
        
        try? fileManager.removeItem(at: snapshotURL)
        
        try! fileManager.copyItem(
            at: dockPreferencesURL,
            to: snapshotURL
        )
        
        snapshotNames = getSnapshotNames()
    }
    
    func removeSnapshot(_ snapshotName: String) {
        let snapshotURL = applicationSupportURL
            .appendingPathComponent("\(snapshotName).plist")
        
        try! fileManager.removeItem(at: snapshotURL)
        
        snapshotNames = getSnapshotNames()
    }
    
    func renameSnapshot(_ oldSnapshotName: String, _ newSnapshotName: String) {
        let oldSnapshotURL = applicationSupportURL
            .appendingPathComponent("\(oldSnapshotName).plist")
        let newSnapshotURL = applicationSupportURL
            .appendingPathComponent("\(newSnapshotName).plist")
        
        try? fileManager.removeItem(at: newSnapshotURL)
        try! fileManager.copyItem(at: oldSnapshotURL, to: newSnapshotURL)
        try! fileManager.removeItem(at: oldSnapshotURL)

        snapshotNames = getSnapshotNames()
    }
    
    func activateSnapshot(_ snapshotName: String) {
        let snapshotURL = applicationSupportURL
            .appendingPathComponent("\(snapshotName).plist")
         
         try? fileManager.removeItem(at: dockPreferencesURL)
         try! fileManager.copyItem(at: snapshotURL, to: dockPreferencesURL)
        
         let task = Process()
         task.launchPath = "/usr/bin/killall"
         task.arguments = ["Dock"]
         task.launch()
         task.waitUntilExit()
    }
    
    func isSnapshotNameValid(_ snapshotName: String) -> Bool {
        return snapshotName
            .range(
                of: "^[a-zA-Z0-9 .,]+$",
                options: .regularExpression,
                range: nil,
                locale: nil
            ) != nil
    }
}
