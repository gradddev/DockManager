import SwiftUI

struct AddSnapshotView: View {
    @EnvironmentObject var snapshotStore: SnapshotStore
    
    @State var snapshotName = ""
    @State var validationError = ""
    
    var body: some View {
        VStack {
            Text("Please enter a name of the new snapshot:")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField(
                "Snapshot name",
                text: $snapshotName,
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
    }
    
    func cancel() {
        NSApp.stopModal()
    }
    
    func save() {
        let appDelegate = NSApp.delegate as! AppDelegate

        snapshotName = snapshotName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!snapshotStore.isSnapshotNameValid(snapshotName)) {
            validationError = "The snapshot name is invalid"
            return
        }
        
        if (snapshotStore.snapshotNames.contains(snapshotName)) {
            let replaceSnapshotView = ReplaceSnapshotView(snapshotName: snapshotName)
                .environmentObject(snapshotStore)
            appDelegate.replaceSnapshotWindow.contentView = NSHostingView(rootView: replaceSnapshotView)
            let modalResponse = NSApp.runModal(for: appDelegate.replaceSnapshotWindow)
            appDelegate.replaceSnapshotWindow.close()
            
            if (modalResponse != .alertFirstButtonReturn) {
                return
            }
        }
        
        validationError = ""

        snapshotStore.addSnapshot(snapshotName)
        
        NSApp.stopModal()
        
        appDelegate.renderMenu()
        appDelegate.showNotification("The \"\(snapshotName)\" snapshot was succussfully added")
        
        snapshotName = ""
    }
}

struct AddSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        AddSnapshotView()
    }
}
