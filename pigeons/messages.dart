import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'device_kit_lib',
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/device_kit_lib/Sources/device_kit_lib/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/hodoan/device_kit_lib/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.hodoan.device_kit_lib'),
    cppHeaderOut: 'windows/messages.g.h',
    cppOptions: CppOptions(namespace: 'device_kit_lib'),
    cppSourceOut: 'windows/messages.g.cpp',
  ),
)
enum AutomationCapability {
  uiDump,
  semanticAction,
  pointerInput,
  keyboardInput,
  screenshot,
  clipboard,
  appLifecycle,
  windowManagement,
  systemAction,
}

enum AutomationPermission { accessibility, screenRecording, inputMonitoring }

enum PermissionState { unknown, denied, granted, restricted }

enum TargetType { application, window, systemUi }

enum UiRole {
  unknown,
  application,
  window,
  dialog,
  button,
  text,
  textField,
  image,
  checkbox,
  radio,
  switchControl,
  slider,
  list,
  listItem,
  menu,
  menuItem,
  tab,
  link,
  scrollView,
}

enum UiAction {
  press,
  focus,
  setValue,
  increment,
  decrement,
  toggle,
  select,
  expand,
  collapse,
  dismiss,
  scrollForward,
  scrollBackward,
}

enum SystemAction {
  back,
  home,
  escape,
  appSwitcher,
  notificationCenter,
  quickSettings,
}

enum KeyAction { press, down, up }

enum ScreenshotFormat { png, jpeg }

class PointData {
  final double x;
  final double y;

  PointData(this.x, this.y);
}

class RectData {
  final double x;
  final double y;
  final double width;
  final double height;

  RectData(this.x, this.y, this.width, this.height);
}

class SizeData {
  final double width;
  final double height;

  SizeData(this.width, this.height);
}

class DriverConfig {
  final String sessionId;
  final bool enableLogs;

  DriverConfig(this.sessionId, this.enableLogs);
}

class DeviceInfo {
  final String platform;
  final String? osVersion;
  final String? model;
  final String? deviceName;
  final bool physicalDevice;

  DeviceInfo(
    this.platform,
    this.osVersion,
    this.model,
    this.deviceName,
    this.physicalDevice,
  );
}

class ScreenInfo {
  final SizeData size;
  final double scale;
  final String orientation;

  ScreenInfo(this.size, this.scale, this.orientation);
}

class CapabilityInfo {
  final List<AutomationCapability?> capabilities;

  CapabilityInfo(this.capabilities);
}

class PermissionInfo {
  final AutomationPermission permission;
  final PermissionState state;
  final bool canRequest;
  final String? message;

  PermissionInfo(this.permission, this.state, this.canRequest, this.message);
}

class TargetInfo {
  final String targetId;

  final TargetType type;

  final String? appId;
  final String? name;
  final String? title;

  final int? processId;

  final RectData? bounds;

  final bool foreground;

  TargetInfo(
    this.targetId,
    this.type,
    this.appId,
    this.name,
    this.title,
    this.processId,
    this.bounds,
    this.foreground,
  );
}

class UiNode {
  final String nodeId;

  final String? parentNodeId;
  final List<String?>? childNodeIds;

  final String? automationId;

  final String? text;
  final String? label;
  final String? value;

  final UiRole role;

  final RectData bounds;

  final bool visible;
  final bool enabled;
  final bool clickable;
  final bool editable;
  final bool focused;
  final bool selected;
  final bool checked;
  final bool scrollable;

  final List<UiAction?>? actions;

  UiNode(
    this.nodeId,
    this.parentNodeId,
    this.childNodeIds,
    this.automationId,
    this.text,
    this.label,
    this.value,
    this.role,
    this.bounds,
    this.visible,
    this.enabled,
    this.clickable,
    this.editable,
    this.focused,
    this.selected,
    this.checked,
    this.scrollable,
    this.actions,
  );
}

class UiSnapshot {
  final int generation;

  final String? targetId;
  final String? rootNodeId;

  final ScreenInfo screen;

  final List<UiNode?> nodes;

  UiSnapshot(
    this.generation,
    this.targetId,
    this.rootNodeId,
    this.screen,
    this.nodes,
  );
}

class DumpUiRequest {
  final String? targetId;

  final bool includeInvisible;

  DumpUiRequest(this.targetId, this.includeInvisible);
}

class HitTestRequest {
  final String? targetId;

  final PointData point;

  HitTestRequest(this.targetId, this.point);
}

class ElementActionRequest {
  final String? targetId;

  final int generation;
  final String nodeId;

  final UiAction action;

  final String? value;

  ElementActionRequest(
    this.targetId,
    this.generation,
    this.nodeId,
    this.action,
    this.value,
  );
}

class ActionResult {
  final bool success;

  final String? message;

  final bool uiChanged;

  ActionResult(this.success, this.message, this.uiChanged);
}

class LaunchAppRequest {
  final String appId;

  final List<String?>? arguments;

  final Map<String?, String?>? environment;

  LaunchAppRequest(this.appId, this.arguments, this.environment);
}

class TapRequest {
  final PointData point;

  final int count;

  TapRequest(this.point, this.count);
}

class LongPressRequest {
  final PointData point;

  final int durationMs;

  LongPressRequest(this.point, this.durationMs);
}

class SwipeRequest {
  final PointData from;
  final PointData to;

  final int durationMs;

  SwipeRequest(this.from, this.to, this.durationMs);
}

class ScrollRequest {
  final double deltaX;
  final double deltaY;

  final PointData? origin;

  ScrollRequest(this.deltaX, this.deltaY, this.origin);
}

class TypeTextRequest {
  final String text;

  final bool clearFirst;

  TypeTextRequest(this.text, this.clearFirst);
}

class KeyRequest {
  final String key;

  final KeyAction action;

  final bool alt;
  final bool control;
  final bool shift;
  final bool meta;

  KeyRequest(
    this.key,
    this.action,
    this.alt,
    this.control,
    this.shift,
    this.meta,
  );
}

class ScreenshotRequest {
  final String? targetId;

  final ScreenshotFormat format;

  final int quality;

  ScreenshotRequest(this.targetId, this.format, this.quality);
}

class ScreenshotData {
  final Uint8List bytes;

  final int width;
  final int height;

  final double scale;

  final ScreenshotFormat format;

  ScreenshotData(this.bytes, this.width, this.height, this.scale, this.format);
}

@HostApi()
abstract class AutomationHostApi {
  void initialize(DriverConfig config);

  void shutdown();

  DeviceInfo getDeviceInfo();

  ScreenInfo getScreenInfo();

  CapabilityInfo getCapabilities();

  List<PermissionInfo?> getPermissions();

  PermissionInfo requestPermission(AutomationPermission permission);

  List<TargetInfo?> listTargets();

  TargetInfo? getForegroundTarget();

  ActionResult launchApp(LaunchAppRequest request);

  ActionResult terminateApp(String appId);

  ActionResult activateTarget(String targetId);

  UiSnapshot dumpUi(DumpUiRequest request);

  UiNode? hitTest(HitTestRequest request);

  ActionResult performElementAction(ElementActionRequest request);

  ActionResult tap(TapRequest request);

  ActionResult longPress(LongPressRequest request);

  ActionResult swipe(SwipeRequest request);

  ActionResult scroll(ScrollRequest request);

  ActionResult typeText(TypeTextRequest request);

  ActionResult pressKey(KeyRequest request);

  ActionResult performSystemAction(SystemAction action);

  ScreenshotData screenshot(ScreenshotRequest request);

  String? getClipboardText();

  ActionResult setClipboardText(String text);
}
