import Flutter
import UIKit
import XCTest

class RunnerTests: XCTestCase {

  func testExample() {
    // If you add code to the Runner application, consider adding tests here.
    // See https://developer.apple.com/documentation/xctest for more information about using XCTest.
  }

  /// Proves the App Group ("group.com.studlokapp.studlok") is actually wired up for
  /// Runner: writes a distinctive StudlokSharedState, reloads it through a fresh
  /// UserDefaults(suiteName:) lookup, and checks every field round-trips. If the App
  /// Group entitlement were missing or misconfigured, `defaults` would be nil and
  /// SharedStore.load() would silently fall back to `.empty` instead of matching.
  func testSharedStoreRoundTripsThroughAppGroup() {
    let marker = StudlokSharedState(
      scrollBankMinutes: 45,
      activeSessionType: .deepWork,
      activeSessionEndDate: Date(timeIntervalSince1970: 1_800_000_000),
      activeSessionLabel: "app-group-wiring-check",
      currentStreak: 7,
      dailyGoalMinutes: 60,
      dailyProgressMinutes: 20,
      onboardingComplete: true
    )

    SharedStore.save(marker)
    let reloaded = SharedStore.load()

    XCTAssertEqual(reloaded, marker)
  }

}
