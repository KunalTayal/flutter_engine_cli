import 'package:args/command_runner.dart';
import 'package:flutter_engine_cli/src/commands/add_feature_command.dart';
import 'package:flutter_engine_cli/src/commands/init_command.dart';

class FlutterScaffoldCommandRunner extends CommandRunner<void> {
  FlutterScaffoldCommandRunner()
      : super('flutter_engine_cli',
            'A powerful CLI to bootstrap and manage scalable, feature-first Flutter projects.') {
    addCommand(InitCommand());
    addCommand(AddFeatureCommand());
  }
}
