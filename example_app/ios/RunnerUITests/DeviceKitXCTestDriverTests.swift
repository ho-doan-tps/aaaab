import device_kit_lib_xctest
import XCTest

final class DeviceKitXCTestDriverTests: XCTestCase {
  private let bundleIdentifier = "com.example.exampleApp"
  private var driver: DeviceKitXCTestDriver!

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    driver = DeviceKitXCTestDriver()
    driver.initialize(bundleIdentifier: bundleIdentifier)
  }

  override func tearDown() {
    driver.terminate()
    driver = nil
    super.tearDown()
  }

  func testCounterSemanticActionAndScreenshot() {
    driver.launch()

    let counter = waitForNode { snapshot in
      snapshot.elements.first {
        $0.automationId == "counter_value" && $0.value == "0"
      }
    }
    XCTAssertNotNil(counter.node.parentNodeId)
    if let parentNodeId = counter.node.parentNodeId {
      let parent = counter.snapshot.elements.first { $0.nodeId == parentNodeId }
      XCTAssertTrue(parent?.childNodeIds.contains(counter.node.nodeId) == true)
    }
    let button = waitForNode { snapshot in
      snapshot.elements.first { $0.automationId == "increment_button" }
    }

    XCTAssertTrue(
      driver.performElementAction(
        nodeId: button.node.nodeId,
        snapshotGeneration: button.snapshot.generation,
        action: .press
      )
    )

    _ = waitForNode { snapshot in
      snapshot.elements.first {
        $0.automationId == "counter_value" && $0.value == "1"
      }
    }

    guard let screenshot = driver.screenshot() else {
      XCTFail("XCUITest screenshot was empty.")
      return
    }
    let attachment = XCTAttachment(
      data: screenshot,
      uniformTypeIdentifier: "public.png"
    )
    attachment.name = "ios-counter-after-increment"
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private func waitForNode(
    _ predicate: @escaping (DeviceKitXCTestDriver.UiSnapshot) -> DeviceKitXCTestDriver.UiElement?
  ) -> (snapshot: DeviceKitXCTestDriver.UiSnapshot, node: DeviceKitXCTestDriver.UiElement) {
    var match: DeviceKitXCTestDriver.UiElement?
    var matchedSnapshot: DeviceKitXCTestDriver.UiSnapshot?

    let deadline = Date().addingTimeInterval(15)
    while Date() < deadline, match == nil {
      let snapshot = driver.dumpUi()
      match = predicate(snapshot)
      if match != nil {
        matchedSnapshot = snapshot
      }
      if match == nil {
        RunLoop.current.run(until: Date().addingTimeInterval(0.15))
      }
    }
    guard let matchedSnapshot, let match else {
      XCTFail("UI node did not appear before the 15-second timeout.")
      fatalError("UI node did not appear.")
    }
    return (matchedSnapshot, match)
  }
}
