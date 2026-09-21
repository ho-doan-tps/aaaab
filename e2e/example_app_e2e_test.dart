import 'dart:async';
import 'dart:io';

import 'package:device_kit_lib/src/web/automation_core/automation_core.dart';
import 'package:device_kit_lib/src/web/automation_web/automation_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Example App Web MVP automation flow',
    () async {
      if (Platform.environment['RUN_WEB_E2E'] != '1') {
        markTestSkipped('Set RUN_WEB_E2E=1 to run the browser E2E test.');
        return;
      }

      final appUrl = Platform.environment['EXAMPLE_APP_URL'];
      HttpServer? appServer;
      var url = appUrl;
      if (url == null || url.isEmpty) {
        final appDirectory = Directory('${Directory.current.path}/example_app');
        final buildDirectory = Directory('${appDirectory.path}/build/web');
        if (!await File('${buildDirectory.path}/index.html').exists()) {
          final build = await Process.run(
            Platform.environment['FLUTTER_BIN'] ?? 'flutter',
            <String>['build', 'web', '--no-web-resources-cdn'],
            workingDirectory: appDirectory.path,
            runInShell: true,
          );
          if (build.exitCode != 0) {
            throw StateError('Flutter Web build failed: ${build.stderr}');
          }
        }
        appServer = await _startStaticServer(buildDirectory);
        url = 'http://127.0.0.1:${appServer.port}/';
      }

      final backend = WebAutomationBackend(
        browserExecutable: Platform.environment['CHROME_PATH'],
      );
      final service = AutomationService(
        backend,
        defaultTimeout: const Duration(seconds: 45),
      );
      try {
        await service.start();
        await service.launch(url);

        await service.waitFor(
          By.all(<By>[By.id('counter_value'), By.value('0')]),
        );

        final button = await service.waitFor(By.id('increment_button'));

        await button.tap();

        await service.waitFor(
          By.all(<By>[By.id('counter_value'), By.value('1')]),
        );

        final screenshot = await service.screenshot();
        final screenshotPath =
            Platform.environment['E2E_SCREENSHOT'] ?? '/tmp/example_app.png';
        await File(screenshotPath).writeAsBytes(screenshot);
      } finally {
        await service.stop();
        await appServer?.close(force: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<HttpServer> _startStaticServer(Directory root) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  unawaited(() async {
    await for (final request in server) {
      final requestedPath = Uri.decodeComponent(request.uri.path);
      final relativePath = requestedPath == '/' || requestedPath.isEmpty
          ? 'index.html'
          : requestedPath.substring(1);
      final file = File('${root.path}/$relativePath');
      final fallback = File('${root.path}/index.html');
      final fileToServe = await file.exists() ? file : fallback;
      if (!await fileToServe.exists()) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        continue;
      }
      request.response
        ..headers.contentType = _contentType(fileToServe.path)
        ..contentLength = await fileToServe.length();
      await request.response.addStream(fileToServe.openRead());
      await request.response.close();
    }
  }());
  return server;
}

ContentType _contentType(String path) {
  final lowerPath = path.toLowerCase();
  if (lowerPath.endsWith('.html')) {
    return ContentType.html;
  }
  if (lowerPath.endsWith('.js')) {
    return ContentType('text', 'javascript', charset: 'utf-8');
  }
  if (lowerPath.endsWith('.css')) {
    return ContentType('text', 'css', charset: 'utf-8');
  }
  if (lowerPath.endsWith('.json')) {
    return ContentType.json;
  }
  if (lowerPath.endsWith('.wasm')) {
    return ContentType('application', 'wasm');
  }
  if (lowerPath.endsWith('.png')) {
    return ContentType('image', 'png');
  }
  if (lowerPath.endsWith('.ico')) {
    return ContentType('image', 'x-icon');
  }
  return ContentType.binary;
}
