import Combine
import Foundation

class UserSettings: ObservableObject {
    
    @Published var server: String{
        didSet {
            UserDefaults.standard.set(server, forKey: "server")
        }
    }
    
    @Published var room: String{
        didSet {
            UserDefaults.standard.set(room, forKey: "room")
        }
    }
    
    @Published var username: String{
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    @Published var interval: String{
        didSet {
            UserDefaults.standard.set(interval, forKey: "interval")
        }
    }
    
    @Published var playSound: Bool{
        didSet {
            UserDefaults.standard.set(playSound, forKey: "playSound")
        }
    }
    
    init() {
        self.server = UserDefaults.standard.object(forKey: "server") as? String ?? "https://timer.mob.sh"
        self.room = UserDefaults.standard.object(forKey: "room") as? String ?? ""
        self.username = UserDefaults.standard.object(forKey: "username") as? String ?? NSFullUserName()
        self.interval = UserDefaults.standard.object(forKey: "interval") as? String ?? "10"
        self.playSound = UserDefaults.standard.bool(forKey: "playSound")
    }
}
