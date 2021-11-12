import SwiftUI
import Combine

struct PreferencesView: View {
    
    @ObservedObject var settings: UserSettings

    var body: some View {
        VStack {
            HStack {
                Text("Server:").frame(width: 130, alignment: .topTrailing)
                TextField("Server", text: $settings.server)
                    .frame(width: 220)
                    .disableAutocorrection(true)
            }
            HStack {
                Text("Room:").frame(width: 130, alignment: .topTrailing)
                TextField("Room", text: $settings.room)
                    .frame(width: 220)
                    .disableAutocorrection(true)
            }
            HStack {
                Text("Username:").frame(width: 130, alignment: .topTrailing)
                TextField("Username", text: $settings.username)
                    .frame(width: 220)
                    .disableAutocorrection(true)
            }
            HStack {
                Text("Interval (Minutes):").frame(width: 130, alignment: .topTrailing)
                TextField("Interval", text: $settings.interval)
                    .frame(width: 220)
                    .disableAutocorrection(true)
                    .onReceive(Just(settings.interval)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.settings.interval = filtered
                        }
                    }
            }
            HStack {
                Text("Sound:").frame(width: 130, alignment: .topTrailing)
                Toggle("Play sound when timer elapsed ", isOn: $settings.playSound)
                    .frame(width: 220, alignment: .leading)
                
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferencesView(settings: UserSettings())
        }
    }
}
