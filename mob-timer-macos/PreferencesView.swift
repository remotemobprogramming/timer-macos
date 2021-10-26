//
//  ContentView.swift
//  mob-timer-macos
//
//  Created by Jochen Christ on 24.10.21.
//

import SwiftUI

struct PreferencesView: View {
    
    @State private var server: String = "https://timer.mob.sh"
    @State private var room: String = "best"
    @State private var interval: String = "10"
    
    var body: some View {
        VStack {
            Text("Preferences").font(.title)
                .padding()
            HStack {
                Text("Server").frame(width: 100, alignment: .leading)
                TextField(
                            "Server",
                             text: $server)
                            .disableAutocorrection(true)
            }
            HStack {
                Text("Room").frame(width: 100, alignment: .leading)
                TextField(
                            "Room",
                             text: $room)
                            .disableAutocorrection(true)
            }
            HStack {
                Text("Interval").frame(width: 100, alignment: .leading)
                TextField(
                            "Interval",
                             text: $interval)
                            .disableAutocorrection(true)
            }
            HStack {
                Button(action: {
                    NSApplication.shared.keyWindow?.close()
                }
                ) {
                    Text("Cancel")
                    
                }
                Button(action: {
                    print("TODO Save")
                    NSApplication.shared.keyWindow?.close()
                }) {
                    Text("Save")
                }
            }
            .padding()
        }.padding()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferencesView()
        }
    }
}
