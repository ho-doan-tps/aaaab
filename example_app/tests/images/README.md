# Android E2E evidence

Captured from the connected Android device during the Device Kit scenario:

1. `01_controller_ready.png` — controller app before starting the kit.
2. `02_accessibility_settings.png` — Android Accessibility settings opened for
   enabling the Device Kit service.
3. `03_counter_0.png` — independent `example_app` with `counter_value = 0`.
4. `04_counter_1.png` — `example_app` after tapping `increment_button`.
5. `05_screenshot.png` — final screen-capture artifact.

The screenshots are evidence artifacts only. The E2E interaction itself uses
the shared Dart `AutomationService` API; no Flutter Finder, CSS, or XPath is
used.
