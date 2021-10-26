import SwiftUI

@main
struct mob_timer_macosApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    var body: some Scene {
        Settings {
          EmptyView()
        }
    }
    
}
