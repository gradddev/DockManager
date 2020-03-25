import SwiftUI

struct RenameSnapshotView: View {
    @EnvironmentObject var snapshotStore: SnapshotStore
    
    var snapshotName: String
    @State var newSnapshotName = ""
    @State var validationError = ""


    var body: some View {
        VStack {
            Text("Please enter a new name of the \"\(snapshotName.replacingOccurrences(of: " ", with: "\u{00a0}"))\" snapshot:")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField(
                "Snapshot name",
                text: $newSnapshotName,
                onCommit: save
            )
            if !validationError.isEmpty {
                Text(validationError)
                    .foregroundColor(Color.red)
            }
            Spacer()
            HStack {
                Button(action: cancel) {
                    Text("Cancel")
                }
                Button(action: save) {
                    Text("Save")
                }
            }
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding()
            .onAppear(perform: {
                self.newSnapshotName = self.snapshotName
            })
    }
    
    func cancel() {
        NSApp.stopModal()
    }
    
    func save() {
        let appDelegate = NSApp.delegate as! AppDelegate
        
        newSnapshotName = newSnapshotName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!snapshotStore.isSnapshotNameValid(newSnapshotName)) {
            validationError = "The snapshot name is invalid"
            return
        }
        
        if (snapshotStore.snapshotNames.contains(newSnapshotName)) {
            let replaceSnapshotView = ReplaceSnapshotView(snapshotName: newSnapshotName)
                .environmentObject(snapshotStore)
            appDelegate.replaceSnapshotWindow.contentView = NSHostingView(rootView: replaceSnapshotView)
            let modalResponse = NSApp.runModal(for: appDelegate.replaceSnapshotWindow)
            appDelegate.replaceSnapshotWindow.close()
            
            if (modalResponse != .alertFirstButtonReturn) {
                return
            }
        }
        
        validationError = ""

        snapshotStore.renameSnapshot(snapshotName, newSnapshotName)

        NSApp.stopModal()

        appDelegate.renderMenu()
        appDelegate.showNotification("The snapshot was successfully renamed to \"\(newSnapshotName)\"")

        newSnapshotName = ""
    }
}

struct RenameSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        RenameSnapshotView(snapshotName: "Test")
    }
}
