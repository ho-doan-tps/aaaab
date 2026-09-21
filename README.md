# Cross-platform Automation Kit

This repository contains the `device_kit_lib` Flutter plugin plus the
platform-independent Automation Kit MVP:

```text
automation_core/  Pure Dart contracts, selectors, and service
automation_web/   Chrome DevTools Protocol WebAutomationBackend
automation_kit/   Local JSON-RPC CLI/server
example_app/      Flutter Web counter app with semantics identifiers
```

The Android implementation is a separate controller app and target app:

```text
example/           Device Kit controller app; depends on device_kit_lib
example_app/       Independent target counter app; does not depend on the kit
```

`example` accepts a target Android package name at runtime. The default value
`com.example.example_app` is only a demo target; the native `launchApp` API is
dynamic and does not contain a target package allow-list.

## Device-control flow

```text
                    External tools
                         │
                    JSON-RPC
                         │
              ┌──────────▼──────────┐
              │ Automation Agent    │
              │ Dart Core           │
              │                     │
              │ socket server       │
              │ session             │
              │ selector            │
              │ wait/retry          │
              └──────────┬──────────┘
                         │
                    PlatformDriver
                         │
       ┌────────┬────────┼────────┬────────┬────────┐
       │        │        │        │        │        │
    Android   iOS      macOS    Windows  Linux     Web
       │        │        │        │        │        │
Accessibility XCTest    AX       UIA    AT-SPI   BiDi
                   runner
```

```mermaid
flowchart TD
    codex["Codex / External Tool"] -->|JSON-RPC 2.0| kit["automation_kit<br/>Local JSON-RPC server"]
    kit --> service["AutomationService<br/>Dart"]
    service --> selectors["Selectors + wait/retry<br/>By.id / By.value / By.all"]
    selectors --> driver["AndroidDriver<br/>Dart"]
    driver -->|Pigeon generated API| host["DeviceKitHostApiImpl<br/>Kotlin"]
    host --> accessibility["AccessibilityService<br/>Android OS APIs"]
    accessibility --> app["Dynamic target app<br/>example_app or any package"]
    app --> tree["AccessibilityNodeInfo tree"]
    tree -->|normalized UiSnapshot| service

    service -->|ui.tap / element.tap| action["Semantic ACTION_CLICK"]
    action -->|unsupported or failed| fallback["Coordinate GestureDescription<br/>bounds.center"]
    fallback --> accessibility

    service -->|screen.screenshot| version{"Android version"}
    version -->|Android 11+| accessibilityShot["AccessibilityService screenshot"]
    version -->|Android <=10| mediaProjection["MediaProjection consent + capture"]
    accessibilityShot --> png["PNG bytes"]
    mediaProjection --> png
    png --> codex

    codex -->|session.start / app.launch| kit
    codex -->|ui.dump / ui.find / ui.tap / ui.setValue| kit
    codex -->|screen.screenshot / session.stop| kit
```

The Android plugin uses Pigeon from `pigeons/messages.dart`. Generated Dart,
Kotlin, Swift, and C++ bindings are kept in their platform output folders.
Selectors and retry/wait logic remain in Dart; Android only exposes
AccessibilityService and OS capabilities.

## iOS XCTest integration

iOS cross-app input is implemented by XCTest/XCUITest in a separate product
exported by the plugin:

```text
ios/device_kit_lib/Sources/device_kit_lib/            Flutter/Pigeon runtime
ios/device_kit_lib/Sources/device_kit_lib_xctest/    XCTest/XCUITest driver
```

The `device-kit-lib-xctest` Swift product is linked only by native UI-test
targets. `example_app/ios/RunnerUITests` imports that product and uses the
driver's raw snapshot and primitive-action API; selector and wait/retry logic
remain in Dart. XCTest is therefore reusable by native app test targets
without being linked into the production Flutter plugin.

## Android permissions

The controller must have its `DeviceKitAccessibilityService` enabled by the
device owner or test environment. This is a special Settings permission, not a
normal runtime permission, so Patrol's `grantPermissionWhenInUse()` cannot grant
it. Patrol can be used in a test harness to tap through the device's Settings
UI, but that flow is Android/OEM/localization-specific and is intentionally not
a runtime dependency of this plugin.

On Android 11 and newer, screenshots use AccessibilityService directly. On
older Android versions, screenshots require the user to approve the
MediaProjection consent dialog through the controller's **Request screenshot
permission** button before calling **Take screenshot**.

## Run the tests

```bash
cd automation_core && dart test
cd ../automation_kit && dart test
cd ../example_app && flutter test
```

Build the example app for local browser automation:

```bash
cd example_app
flutter build web --no-web-resources-cdn
```

Run the browser E2E (Chrome/Chromium is required):

```bash
cd automation_kit
RUN_WEB_E2E=1 dart test e2e/example_app_e2e_test.dart
```

Run the Android self-test on a connected device (Patrol CLI is required):

```bash
cd example
patrol test --target patrol_test/android_automation_test.dart
```

The Patrol test is test-only setup. It can navigate Android Settings to enable
the Device Kit AccessibilityService and can approve the MediaProjection dialog;
the target-app UI dump, selectors, wait, tap, and screenshot calls still use
the shared `device_kit_lib` Dart API.

Build and run the iOS XCTest target on a booted simulator:

```bash
cd example_app/ios
xcodebuild -project Runner.xcodeproj \
  -scheme Runner \
  -destination 'platform=iOS Simulator,name=<simulator-name>' \
  test
```

Use `xcodebuild -showdestinations` to select an installed simulator. The
XCTest target launches `com.example.exampleApp` itself; it is not a runtime
accessibility service inside the production Flutter process.

The local JSON-RPC app reads line-delimited JSON-RPC 2.0 requests from stdin by
default. Use `dart run bin/automation_kit.dart --http --port 8787` for a
loopback HTTP server.

Selectors are represented by `By.id`, `By.text`, `By.label`, `By.role`,
`By.value`, and `By.all`. They are matched in Dart against normalized
`UiSnapshot` data; browser-specific DOM/CDP details remain inside
`automation_web`.
