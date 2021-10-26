//
//  MacExtrasConfigurator.swift
//  mob-timer-macos
//
//  Created by Jochen Christ on 24.10.21.
//

import Foundation
import AppKit

class MobTimerMenuBarItem: NSObject {
    
    private var statusItem: NSStatusItem
    private var mobTimer: MobTimer
    
    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        mobTimer = MobTimer()
        super.init()
        buildMenu()
        mobTimer.subscribe() { (result) -> () in
            self.updateTitle(text: result)
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
            
            
            let connectionStatusItem = NSMenuItem()
            connectionStatusItem.title = "Status"
            mainMenu.addItem(connectionStatusItem)

            let preferencesItem = NSMenuItem()
            preferencesItem.title = "Preferences"
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
    
    @objc func updateTitle(text: String) {
        self.statusItem.button?.title = text
    }
    
    @objc private func startTimer() {
        mobTimer.startTimer()
        
    }
    
    @objc private func showPreferences() {
        let controller = DetailWindowController(rootView: PreferencesView())
        controller.window?.title = "Mob Timer";
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitAction() {
        NSApp.terminate(self)
    }
    
}
