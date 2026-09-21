# Cross-platform Automation Kit — Web MVP

This repository contains the original `device_kit_lib` plugin scaffold plus a
platform-independent Automation Kit MVP:

```text
automation_core/  Pure Dart contracts, selectors, and service
automation_web/   Chrome DevTools Protocol WebAutomationBackend
automation_kit/   Local JSON-RPC CLI/server
example_app/      Flutter Web counter app with semantics identifiers
```

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

The local JSON-RPC app reads line-delimited JSON-RPC 2.0 requests from stdin by
default. Use `dart run bin/automation_kit.dart --http --port 8787` for a
loopback HTTP server.

Selectors are represented by `By.id`, `By.text`, `By.label`, `By.role`,
`By.value`, and `By.all`. They are matched in Dart against normalized
`UiSnapshot` data; browser-specific DOM/CDP details remain inside
`automation_web`.
