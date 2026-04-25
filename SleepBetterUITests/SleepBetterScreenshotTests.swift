import XCTest

final class SleepBetterScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "/tmp/SleepBetter_\(name).png"))
    }

    func test01_Dashboard() throws {
        ss("01_dashboard")
    }

    func test02_Transactions() throws {
        if app.tabBars.buttons["History"].exists {
            app.tabBars.buttons["History"].tap()
        }
        ss("02_history")
    }

    func test03_Budget() throws {
        if app.tabBars.buttons["Sounds"].exists {
            app.tabBars.buttons["Sounds"].tap()
        }
        ss("03_sounds")
    }

    func test04_Goals() throws {
        if app.tabBars.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
        }
        ss("04_settings")
    }

    func test05_Settings() throws {
        ss("05_settings_detail")
    }
}