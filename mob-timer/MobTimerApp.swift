import SwiftUI

@main
struct MobTimerApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    var body: some Scene {
        Settings {
          EmptyView()
        }
    }
    
}
