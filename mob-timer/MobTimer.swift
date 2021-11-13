import Foundation
import AppKit
import os

import EventSource

class MobTimer {
    
    let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "mobtimer")
    
    var settings: UserSettings
    var eventSource: EventSource?
    var currentUrl: URL?
    var currentTimer: Timer?
    var isTimerRunning = false
    
    var status: String = "" {
        didSet {
            if status != oldValue {
                if let action = statusDidChangeAction{
                    action()
                }
            }
        }
    }
    var statusDidChangeAction: (() -> ())?

    init(settings: UserSettings) {
        self.settings = settings
        NotificationCenter.default.addObserver(self, selector: #selector(settingChanged(notification:)), name: UserDefaults.didChangeNotification, object: nil)
        self.connect()
    }
    
    func connect() {
        guard let url = buildEventsUrl() else {
            return
        }
        currentUrl = url
        log.info("Connecting to \(url)")
        eventSource = EventSource(url: url)
        eventSource?.connect()
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            self?.log.info("Disconnected")
            let retryTime = self?.eventSource?.retryTime ?? 3000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
                self?.log.info("Retrying now... \(String(describing: self?.eventSource?.url))")
                self?.eventSource?.connect()
            }
        }
        eventSource?.addEventListener("TIMER_REQUEST") { _, _, data in
            
            if let data = data {
                self.log.info("TIMER_REQUEST: \(data)")
            }
            
            struct TimerRequest: Codable {
                let timer: Int8
                let requested: String?
                let user: String?
                let nextUser: String?
                let type: String?
            }
            
            let jsonData = data!.data(using: .utf8)!
            let timerRequest = try! JSONDecoder().decode(TimerRequest.self, from: jsonData)
            
            if let requestedTimer = timerRequest.requested {
                let timestampTimerEnd = Date.getDateFromString(dateString: requestedTimer)! + 60.0 * Double(timerRequest.timer)
                self.updateTimer(timeout: timestampTimerEnd, user: timerRequest.user, nextUser: timerRequest.nextUser, type: timerRequest.type)
            }
        }
    }
    
    @objc func settingChanged(notification: NSNotification) {
        guard (notification.object as? UserDefaults) != nil else {
            return
        }
        
        if currentUrl != buildEventsUrl() {
            log.info("Endpoint has changed. Reconnecting...")
            currentTimer?.invalidate()
            self.status = ""
            eventSource?.disconnect()
            eventSource = nil
            self.connect()

        }
    }
    
    func startTimer() {
        guard let url = buildRoomUrl() else {
            return
        }
        
        struct PutTimerRequestBody: Codable {
            let timer: Int
            let user: String
        }
        
        let timerRequest = PutTimerRequestBody(timer: Int(self.settings.interval) ?? 10, user: self.settings.username)
        
        guard let jsonData = try? JSONEncoder().encode(timerRequest) else {
            log.error("Error: Trying to convert model to JSON data")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.log.error("Error: error calling PUT")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                self.log.error("Error: HTTP request failed")
                return
            }
        }.resume()
        
    }
    
    func updateTimer(timeout: Date, user: String?, nextUser: String? = nil, type: String? = "TIMER") {
                
        self.currentTimer?.invalidate()

        self.currentTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            
            let now = Date()
            
            if now >= timeout {
                self.log.info("next")
                if (self.isTimerRunning) {
                    self.timerFinished()
                }
                timer.invalidate()
                if let nextTypist = nextUser {
                    self.status = "next: " + nextTypist
                } else {
                    self.status = "next"
                }
            } else {
                let remainingSeconds = Double(Calendar.current.dateComponents([.second], from: now, to: timeout).second!)
                self.isTimerRunning = true;
                var userString = ""
                if type == "BREAKTIMER" {
                    userString = " BREAK"
                } else if type == "TIMER" {
                    if let user = user {
                        userString = " " + user
                    }
                }
                self.status = self.format(seconds: remainingSeconds) + userString
            }
        }

    }
    
    func timerFinished() {
        self.isTimerRunning = false
        if (self.settings.playSound) {
            log.info("play sound...")
            NSSound(named: NSSound.Name("Hero"))?.play()
        }
    }

    func format(seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        let formattedString = formatter.string(from: seconds)!
        return (formattedString.hasPrefix("0") && formattedString.count > 4)  ? String(formattedString.dropFirst()) : formattedString
    }
    
    func buildRoomUrl() -> URL? {
        guard !self.settings.server.isEmpty else {
            status = "Invalid Server"
            return nil
        }
        guard !self.settings.room.isEmpty else {
            status = "Setup room"
            return nil
        }
        var roomUrl = URL(string: self.settings.server)
        roomUrl = roomUrl?.appendingPathComponent(self.settings.room)
        return roomUrl
    }
    
    func buildEventsUrl() -> URL? {
        guard !self.settings.server.isEmpty else {
            status = "Invalid Server"
            return nil
        }
        guard !self.settings.room.isEmpty else {
            status = "Setup room"
            return nil
        }
        var roomUrl = URL(string: self.settings.server)
        roomUrl = roomUrl?.appendingPathComponent(self.settings.room)
        roomUrl = roomUrl?.appendingPathComponent("/events")
        return roomUrl
    }

}


extension Date {
  static func getDateFromString(dateString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime,
                               .withDashSeparatorInDate,
                               .withFullDate,
                               .withFractionalSeconds,
                               .withColonSeparatorInTimeZone]
    guard let date = formatter.date(from: dateString) else {
      return nil
    }
    return date
  }
}
