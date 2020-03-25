import SwiftUI

struct ReplaceSnapshotView: View {
    @EnvironmentObject var snapshotStore: SnapshotStore
    
    var snapshotName: String
    
    var body: some View {
        VStack {
            Text("The \"\(snapshotName.replacingOccurrences(of: " ", with: "\u{00a0}"))\" snapshot already exists. Do you want to replace it?")
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            HStack {
                Button(action: cancel) {
                    Text("Cancel")
                }
                Button(action: replace) {
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
        NSApp.stopModal(withCode: .alertSecondButtonReturn)
    }
    
    func replace() {
        NSApp.stopModal(withCode: .alertFirstButtonReturn)
    }
}

struct ReplaceSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        ReplaceSnapshotView(snapshotName: "Test")
    }
}
