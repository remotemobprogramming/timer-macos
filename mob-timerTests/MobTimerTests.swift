import XCTest
@testable import Mob_Timer

class MobTimerTests: XCTestCase {

    func testFormat_2Minutes() throws {
        let mobTimer = MobTimer(settings: UserSettings())
        
        let formatted = mobTimer.format(seconds: 120.0)
        
        XCTAssertEqual(formatted, "2:00")
    }

    func testFormat_2Seconds() throws {
        let mobTimer = MobTimer(settings: UserSettings())
        
        let formatted = mobTimer.format(seconds: 2.0)
        
        XCTAssertEqual(formatted, "0:02")
    }


}
