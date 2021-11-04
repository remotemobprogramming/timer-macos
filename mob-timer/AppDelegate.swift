import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  
  private var mobTimerMenuBarItem: MobTimerMenuBarItem?
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    mobTimerMenuBarItem = MobTimerMenuBarItem()
  }
}
