import 'dart:io';
import 'package:flutter_engine_cli/src/command_runner.dart';

Future<void> main(List<String> args) async {
  print('--- RUNNING UPDATED VERSION 1.0.0 ---');
  try {
    await FlutterScaffoldCommandRunner().run(args);
    exit(0);
  } catch (error) {
    print('❌ Error: $error');
    exit(1);
  }
}
