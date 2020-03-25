import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    
    var appName: String {
        get {
            return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        }
    }
    
    var snapshotStore: SnapshotStore!
    
    var addSnapshotWindow: NSWindow!
    var removeSnapshotWindow: NSWindow!
    var renameSnapshotWindow: NSWindow!
    var replaceSnapshotWindow: NSWindow!
    
    func renderMenu() {
        let menu = NSMenu()
        
        snapshotStore.snapshotNames.enumerated().forEach { (index, snapshotName) in
            let menuItem = NSMenuItem(
                title: snapshotName,
                action: #selector(activateSnapshot(sender:)),
                keyEquivalent: String(index + 1)
            )
            menuItem.representedObject = snapshotName
            
            let activateMenuItem = NSMenuItem(
                title: "Activate",
                action: #selector(activateSnapshot(sender:)),
                keyEquivalent: ""
            )
            activateMenuItem.representedObject = snapshotName
            
            let renameMenuItem = NSMenuItem(
                title: "Rename",
                action: #selector(renameSnapshot(sender:)),
                keyEquivalent: ""
            )
            renameMenuItem.representedObject = snapshotName
            
            let removeMenuItem = NSMenuItem(
                title: "Remove",
                action: #selector(removeSnapshot(sender:)),
                keyEquivalent: ""
            )
            removeMenuItem.representedObject = snapshotName
            
            menuItem.submenu = NSMenu()
            menuItem.submenu!.addItem(activateMenuItem)
            menuItem.submenu!.addItem(renameMenuItem)
            menuItem.submenu!.addItem(removeMenuItem)
            menu.addItem(menuItem)
        }
        if (snapshotStore.snapshotNames.isEmpty) {
            menu.addItem(withTitle: "No snapshots added...", action: nil, keyEquivalent: "")
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let addMenuItem = NSMenuItem(
            title: "Add a current snapshot...",
            action: #selector(addSnapshot(sender:)),
            keyEquivalent: ""
        )
        menu.addItem(addMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(
            withTitle: "About \(appName)",
            action: #selector(showAboutWindow(sender:)),
            keyEquivalent: "a"
        )
        
        menu.addItem(
            withTitle: "Quit \(appName)",
            action: #selector(closeApplication(sender:)),
            keyEquivalent: "q"
        )
        
        statusItem.menu = menu
    }
    
    @objc func addSnapshot(sender: NSMenuItem) {
        let addSnapshotView = AddSnapshotView()
            .environmentObject(snapshotStore)
        addSnapshotWindow.contentView = NSHostingView(rootView: addSnapshotView)
        NSApp.runModal(for: addSnapshotWindow)
        addSnapshotWindow.close()
    }
    
    @objc func removeSnapshot(sender: NSMenuItem) {
        let snapshotName = sender.representedObject as! String
        
        let removeSnapshotView = RemoveSnapshotView(snapshotName: snapshotName)
            .environmentObject(snapshotStore)
        removeSnapshotWindow.contentView = NSHostingView(rootView: removeSnapshotView)
        NSApp.runModal(for: removeSnapshotWindow)
        removeSnapshotWindow.close()
    }
    
    @objc func renameSnapshot(sender: NSMenuItem) {
        let snapshotName = sender.representedObject as! String
        
        let renameSnapshotView = RenameSnapshotView(snapshotName: snapshotName)
            .environmentObject(snapshotStore)
        renameSnapshotWindow.contentView = NSHostingView(rootView: renameSnapshotView)
        NSApp.runModal(for: renameSnapshotWindow)
        renameSnapshotWindow.close()
    }
    
    @objc func activateSnapshot(sender: NSMenuItem) {
        let snapshotName = sender.representedObject as! String
        snapshotStore.activateSnapshot(snapshotName)
    }
    
    @objc func showAboutWindow(sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    @objc func closeApplication(sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.terminate(self)
    }
    
    func showNotification(_ text: String) {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        
        let notification = NSUserNotification()
        notification.title = appName
        notification.informativeText = text
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    /**
     # NSApplicationDelegate
     */
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        NSUserNotificationCenter.default.delegate = self
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(named: "Dock")
    
        snapshotStore = SnapshotStore()

        addSnapshotWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 120),
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        addSnapshotWindow.isReleasedWhenClosed = false
        addSnapshotWindow.title = appName
        addSnapshotWindow.center()
        addSnapshotWindow.delegate = self
        
        removeSnapshotWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 120),
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        removeSnapshotWindow.isReleasedWhenClosed = false
        removeSnapshotWindow.title = appName
        removeSnapshotWindow.center()
        removeSnapshotWindow.delegate = self
        
        renameSnapshotWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 120),
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        renameSnapshotWindow.isReleasedWhenClosed = false
        renameSnapshotWindow.title = appName
        renameSnapshotWindow.center()
        renameSnapshotWindow.delegate = self
        
        replaceSnapshotWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 120),
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        replaceSnapshotWindow.isReleasedWhenClosed = false
        replaceSnapshotWindow.title = appName
        replaceSnapshotWindow.center()
        replaceSnapshotWindow.delegate = self

        renderMenu()
    }
    
    /**
     # NSWindowDelegate
     */
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }

    /**
     # NSUserNotificationCenterDelegate
     */
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
       return true
    }
}
