import 'dart:async';
import 'dart:io';

import 'package:device_kit_lib/src/web/automation_kit/automation_kit.dart';
import 'package:device_kit_lib/src/web/automation_web/automation_web.dart';

Future<void> main(List<String> args) async {
  final backend = WebAutomationBackend(
    browserExecutable: Platform.environment['CHROME_PATH'],
  );
  final server = AutomationKitServer(backend);

  if (args.contains('--http')) {
    final port = _portArgument(args) ?? 0;
    final address = await server.serveHttp(port: port);
    stderr.writeln('Device Kit JSON-RPC listening on $address');
    await Completer<void>().future;
  } else {
    await server.serveStdio();
  }
}

int? _portArgument(List<String> args) {
  final index = args.indexOf('--port');
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return int.tryParse(args[index + 1]);
}
