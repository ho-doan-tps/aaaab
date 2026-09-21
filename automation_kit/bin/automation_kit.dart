import 'dart:async';
import 'dart:io';

import 'package:automation_core/automation_core.dart';
import 'package:automation_kit/automation_kit.dart';
import 'package:automation_web/automation_web.dart';

Future<void> main(List<String> args) async {
  final backend = WebAutomationBackend(
    browserExecutable: Platform.environment['CHROME_PATH'],
  );
  final service = AutomationService(backend);
  final dispatcher = AutomationJsonRpcDispatcher(service);

  if (args.contains('--http')) {
    final port = _portArgument(args) ?? 0;
    final server = JsonRpcHttpServer(dispatcher, port: port);
    final address = await server.start();
    stderr.writeln('Automation Kit JSON-RPC listening on $address');
    await Completer<void>().future;
  } else {
    await JsonRpcStdioServer(dispatcher).serve();
  }
}

int? _portArgument(List<String> args) {
  final index = args.indexOf('--port');
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return int.tryParse(args[index + 1]);
}
