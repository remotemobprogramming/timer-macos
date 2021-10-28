import SwiftUI

struct PreferencesView: View {
    
    @ObservedObject var settings: UserSettings

    var body: some View {
        VStack {
            HStack {
                Text("Server:").frame(width: 100, alignment: .topTrailing)
                TextField("Server", text: $settings.server)
                    .frame(width: 200)
                    .disableAutocorrection(true)
            }
            HStack {
                Text("Room:").frame(width: 100, alignment: .topTrailing)
                TextField("Room", text: $settings.room)
                    .frame(width: 200)
                    .disableAutocorrection(true)
            }
            HStack {
                Text("Username:").frame(width: 100, alignment: .topTrailing)
                TextField("Username", text: $settings.username)
                    .frame(width: 200)
                    .disableAutocorrection(true)
            }
            HStack {
                Text("Interval:").frame(width: 100, alignment: .topTrailing)
                TextField("Interval", text: $settings.interval)
                    .frame(width: 200)
                    .disableAutocorrection(true)
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
