import Foundation

import EventSource

class MobTimer {
    
    var eventSource: EventSource?
    var currentTimer: Timer?
    
    var user = "jochen"
    
    init() {
        let serverURL = URL(string: "https://timer.mob.sh/best/sse2")!

        eventSource = EventSource(url: serverURL)
        eventSource?.connect()

        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            print("DISCONNECTED", statusCode ?? "no statusCode")
            
            let retryTime = self?.eventSource?.retryTime ?? 3000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
                print("Retrying now...")
                self?.eventSource?.connect()
            }
        }
    }
    
    func startTimer() {
        let url = URL(string: "https://timer.mob.sh/best")!
        
        struct PutTimerRequestBody: Codable {
            let timer: Int8
            let user: String
        }
        
        let timerRequest = PutTimerRequestBody(timer: 10, user: self.user)
        
        guard let jsonData = try? JSONEncoder().encode(timerRequest) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling PUT")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
        }.resume()
        
    }
    
    func subscribe(completion: @escaping (String)->()) {

        eventSource?.addEventListener("TIMER_REQUEST") { _, _, data in
            // {"timer":10,"requested":"2021-10-25T14:12:05.997943Z","user":null,"type":"TIMER"}
            
            if let data = data {
                print(data)
            }
            
            struct TimerRequest: Codable {
                let timer: Int8
                let requested: String
                let user: String
                let type: String
            }
            
            let jsonData = data!.data(using: .utf8)!
            guard let timerRequest = try? JSONDecoder().decode(TimerRequest.self, from: jsonData) else {
                print("Error: Trying to convert model to JSON data")
                return
            }
            
            let timestampTimerEnd = Date.getDateFromString(dateString: timerRequest.requested)! + 60.0 * Double(timerRequest.timer)
            
            self.updateTimer(timeout: timestampTimerEnd, typist: timerRequest.user, nextTypist: "jochen", completion: completion)
        }

        
    }
    
    func updateTimer(timeout: Date, typist: String, nextTypist: String?, completion: @escaping (String)->()) {
                
        self.currentTimer?.invalidate()

        self.currentTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            
            let now = Date()
            
            if now >= timeout {
                print("mob next")
                timer.invalidate()
                if let nextTypist = nextTypist {
                    completion(nextTypist + " is next")
                } else {
                    completion("mob next")
                }
            } else {
                let remainingSeconds = Double(Calendar.current.dateComponents([.second], from: now, to: timeout).second!)
                completion(self.format(seconds: remainingSeconds, typist: typist))
            }
        }

    }

    private func format(seconds: TimeInterval, typist: String) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        return formatter.string(from: seconds)! + " " + typist
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
