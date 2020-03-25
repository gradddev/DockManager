import SwiftUI

struct RemoveSnapshotView: View {
    @EnvironmentObject var snapshotStore: SnapshotStore
    
    var snapshotName: String
    
    var body: some View {
        VStack {
            Text("Are you sure you want to remove the \"\(snapshotName.replacingOccurrences(of: " ", with: "\u{00a0}"))\" snapshot?")
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            HStack {
                Button(action: cancel) {
                    Text("Cancel")
                }
                Button(action: remove) {
                    Text("Yes")
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
    
    func remove() {
        snapshotStore.removeSnapshot(snapshotName)
        
        NSApp.stopModal()

        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.renderMenu()
        appDelegate.showNotification("The \"\(snapshotName)\" snapshot was succussfully removed")
    }
}

struct RemoveSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveSnapshotView(snapshotName: "Test")
    }
}
