import 'dart:convert';

/// The semantic role exposed by an automated UI element.
enum UiRole {
  unknown,
  button,
  checkbox,
  combobox,
  heading,
  image,
  input,
  link,
  list,
  menu,
  menuItem,
  progressBar,
  slider,
  switchControl,
  text,
}

extension UiRoleSerialization on UiRole {
  String get serializedName {
    switch (this) {
      case UiRole.switchControl:
        return 'switch';
      default:
        return name;
    }
  }
}

UiRole uiRoleFromString(String? value) {
  final normalized = value?.trim().toLowerCase();
  switch (normalized) {
    case 'button':
      return UiRole.button;
    case 'checkbox':
      return UiRole.checkbox;
    case 'combobox':
      return UiRole.combobox;
    case 'heading':
      return UiRole.heading;
    case 'image':
      return UiRole.image;
    case 'input':
    case 'textbox':
      return UiRole.input;
    case 'link':
      return UiRole.link;
    case 'list':
      return UiRole.list;
    case 'menu':
      return UiRole.menu;
    case 'menuitem':
    case 'menu-item':
      return UiRole.menuItem;
    case 'progressbar':
    case 'progress-bar':
      return UiRole.progressBar;
    case 'slider':
      return UiRole.slider;
    case 'switch':
      return UiRole.switchControl;
    case 'text':
      return UiRole.text;
    default:
      return UiRole.unknown;
  }
}

/// A rectangle in browser/device logical pixels.
class UiBounds {
  const UiBounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  double get centerX => x + width / 2;
  double get centerY => y + height / 2;

  factory UiBounds.fromJson(Map<String, Object?> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;

    return UiBounds(
      x: number('x'),
      y: number('y'),
      width: number('width'),
      height: number('height'),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };

  @override
  String toString() => jsonEncode(toJson());
}

/// An opaque reference to one element in a snapshot.
///
/// The reference is intentionally not a CSS selector, XPath, or Flutter
/// Finder. Backends may use any stable token they need internally.
class ElementRef {
  const ElementRef(this.key);

  final String key;

  Map<String, Object?> toJson() => <String, Object?>{'key': key};

  @override
  bool operator ==(Object other) => other is ElementRef && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'ElementRef($key)';
}

/// A normalized, platform-independent representation of a UI node.
class UiElement {
  const UiElement({
    required this.ref,
    this.automationId,
    this.text,
    this.label,
    this.value,
    this.role = UiRole.unknown,
    this.bounds,
    this.enabled = true,
    this.clickable = false,
    this.editable = false,
    this.children = const <UiElement>[],
  });

  final ElementRef ref;
  final String? automationId;
  final String? text;
  final String? label;
  final String? value;
  final UiRole role;
  final UiBounds? bounds;
  final bool enabled;
  final bool clickable;
  final bool editable;
  final List<UiElement> children;

  Iterable<UiElement> get flattened sync* {
    yield this;
    for (final child in children) {
      yield* child.flattened;
    }
  }

  factory UiElement.fromJson(Map<String, Object?> json) {
    final rawRef = json['ref'];
    final ref = rawRef is Map
        ? ElementRef((rawRef['key'] ?? '').toString())
        : ElementRef((rawRef ?? json['refKey'] ?? '').toString());
    final rawBounds = json['bounds'];
    final rawChildren = json['children'];

    return UiElement(
      ref: ref,
      automationId: json['automationId'] as String?,
      text: json['text'] as String?,
      label: json['label'] as String?,
      value: json['value'] as String?,
      role: uiRoleFromString(json['role'] as String?),
      bounds: rawBounds is Map
          ? UiBounds.fromJson(Map<String, Object?>.from(rawBounds))
          : null,
      enabled: json['enabled'] as bool? ?? true,
      clickable: json['clickable'] as bool? ?? false,
      editable: json['editable'] as bool? ?? false,
      children: rawChildren is List
          ? rawChildren
                .whereType<Map>()
                .map(
                  (child) =>
                      UiElement.fromJson(Map<String, Object?>.from(child)),
                )
                .toList(growable: false)
          : const <UiElement>[],
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'ref': ref.toJson(),
    'automationId': automationId,
    'text': text,
    'label': label,
    'value': value,
    'role': role.serializedName,
    'bounds': bounds?.toJson(),
    'enabled': enabled,
    'clickable': clickable,
    'editable': editable,
    'children': children.map((child) => child.toJson()).toList(),
  };

  @override
  String toString() => jsonEncode(toJson());
}

/// A point-in-time normalized view of the application UI.
class UiSnapshot {
  UiSnapshot({required this.elements, DateTime? capturedAt})
    : capturedAt = capturedAt ?? DateTime.now();

  final List<UiElement> elements;
  final DateTime capturedAt;

  Iterable<UiElement> get flattened sync* {
    for (final element in elements) {
      yield* element.flattened;
    }
  }

  factory UiSnapshot.fromJson(Map<String, Object?> json) {
    final rawElements = json['elements'];
    final capturedAt = DateTime.tryParse(json['capturedAt']?.toString() ?? '');

    return UiSnapshot(
      elements: rawElements is List
          ? rawElements
                .whereType<Map>()
                .map(
                  (element) =>
                      UiElement.fromJson(Map<String, Object?>.from(element)),
                )
                .toList(growable: false)
          : const <UiElement>[],
      capturedAt: capturedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'capturedAt': capturedAt.toUtc().toIso8601String(),
    'elements': elements.map((element) => element.toJson()).toList(),
  };
}
