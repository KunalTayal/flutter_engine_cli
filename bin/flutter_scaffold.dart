// bin/flutter_scaffold.dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_scaffold/src/project_creator.dart';
import 'package:tint/tint.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Shows this help message.')
    ..addFlag('with-riverpod', negatable: false, help: 'Adds Riverpod for state management.')
    ..addFlag('with-bloc', negatable: false, help: 'Adds BLoC for state management.')
    ..addFlag('with-dio', negatable: false, help: 'Adds Dio for network requests.');

  try {
    final argResults = parser.parse(arguments);

    if (argResults['help'] as bool) {
      print('Flutter Scaffolder CLI'.bold());
      print('Applies a clean architecture structure to a Flutter project.\n');
      print(parser.usage);
      exit(0);
    }

    // --- State Management Validation ---
    final useRiverpod = argResults['with-riverpod'] as bool;
    final useBloc = argResults['with-bloc'] as bool;

    if (useRiverpod && useBloc) {
      print('Error: Cannot use --with-riverpod and --with-bloc simultaneously.'.red());
      print('Please choose one state management solution.');
      exit(1);
    }

    // --- Create and run the project creator ---
    final creator = ProjectCreator(
      useRiverpod: useRiverpod,
      useBloc: useBloc,
      useDio: argResults['with-dio'] as bool,
    );

    creator.run();

  } on FormatException catch (e) {
    print(e.message.red());
    print('\nUsage:\n${parser.usage}');
    exit(1);
  } catch (e) {
    print('An unexpected error occurred: ${e.toString()}'.red());
    exit(1);
  }
}