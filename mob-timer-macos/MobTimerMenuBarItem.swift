import Foundation
import AppKit

class MobTimerMenuBarItem: NSObject {
    
    var settings: UserSettings
    var mobTimer: MobTimer
    var statusItem: NSStatusItem
        
    override init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.settings = UserSettings()
        self.mobTimer = MobTimer(settings: self.settings)
        super.init()
        buildMenu()
        updateTitle() 
        mobTimer.statusDidChangeAction = {[weak self] in
            self?.updateTitle()
        }
    }
        
    private func buildMenu() {
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(
                systemSymbolName: "person.3.fill",
                accessibilityDescription: "Mob Timer"
            )
            statusBarButton.imagePosition = NSControl.ImagePosition.imageLeft
            statusBarButton.font = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: NSFont.Weight.regular)
            
            let mainMenu = NSMenu()
            
            let startTimerItem = NSMenuItem()
            startTimerItem.title = "Start timer"
            startTimerItem.keyEquivalent = "t"
            startTimerItem.target = self
            startTimerItem.action = #selector(Self.startTimer)
            mainMenu.addItem(startTimerItem)

            let preferencesItem = NSMenuItem()
            preferencesItem.title = "Preferences..."
            preferencesItem.action = #selector(Self.showPreferences)
            preferencesItem.target = self
            mainMenu.addItem(preferencesItem)
            
            let quitItem = NSMenuItem()
            quitItem.title = "Quit"
            quitItem.action = #selector(Self.quitAction)
            quitItem.keyEquivalent = "q"
            quitItem.target = self
            mainMenu.addItem(quitItem)
            
            statusItem.menu = mainMenu
        }
    }

    @objc func updateTitle() {
        self.statusItem.button?.title = mobTimer.status
    }

    @objc private func startTimer() {
        mobTimer.startTimer()
        
    }
    
    @objc private func showPreferences() {
        let controller = DetailWindowController(rootView: PreferencesView(settings: settings))
        controller.window?.title = "Mob Timer";
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitAction() {
        NSApp.terminate(self)
    }
    
}
