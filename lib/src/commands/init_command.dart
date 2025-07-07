import 'package:args/command_runner.dart';
import 'package:flutter_scaffold/src/commands/add_feature_command.dart';
import 'package:flutter_scaffold/src/templates/core_templates.dart';
import 'package:flutter_scaffold/src/utils/file_utils.dart';

class InitCommand extends Command<void> {
  @override
  final name = 'init';
  @override
  final description =
      'Initializes a clean architecture structure in the current Flutter project.';

  InitCommand() {
    argParser
      ..addFlag('with-riverpod',
          help: 'Adds and configures Riverpod for state management.',
          negatable: false)
      ..addFlag('with-bloc',
          help: 'Adds and configures BLoC for state management.',
          negatable: false)
      ..addFlag('with-dio',
          help: 'Adds Dio for advanced network requests.', negatable: false)
      ..addFlag('with-g-routes',
          abbr: 'g', help: 'Adds go_router for navigation.', negatable: false)
      ..addFlag('with-l-storage',
          abbr: 'l', help: 'Adds hive for local storage.', negatable: false);
  }

  @override
  Future<void> run() async {
    final withRiverpod = argResults!['with-riverpod'] as bool;
    final withBloc = argResults!['with-bloc'] as bool;
    final withDio = argResults!['with-dio'] as bool;
    final withGoRouter = argResults!['with-g-routes'] as bool;
    final withHive = argResults!['with-l-storage'] as bool;

    if (withRiverpod && withBloc) {
      throw 'Cannot use --with-riverpod and --with-bloc at the same time. Please choose one state management solution.';
    }

    final stateManagement =
        withRiverpod ? 'riverpod' : (withBloc ? 'bloc' : 'none');

    final projectName = FileUtils.getFlutterProjectName();

    print('🚀 Initializing project "$projectName" with Clean Architecture...');

    // Create core structure
    await _createCoreStructure(withDio, withGoRouter, withHive, projectName);

    // Create main.dart
    await FileUtils.createFile('lib/main.dart',
        CoreTemplates.mainDart(withRiverpod, withGoRouter, projectName));

    // Create features folder
    await FileUtils.createFolder('lib/features');

    // Add initial 'home' feature
    print('\n🏠 Adding initial "home" feature...');
    final addFeatureCommand = AddFeatureCommand();
    await addFeatureCommand.createFeature(
      name: 'home',
      projectName: projectName,
      stateManagement: stateManagement,
      withGoRouter: withGoRouter,
    );

    // Add dependencies
    await _addDependencies(
        withRiverpod, withBloc, withDio, withGoRouter, withHive);

    print('\n🎉 Project initialized successfully!');
    print('Run `flutter pub get` to install dependencies.');
  }

  Future<void> _createCoreStructure(bool withDio, bool withGoRouter,
      bool withHive, String projectName) async {
    final coreFolders = [
      'lib/core/common',
      'lib/core/config',
      'lib/core/di',
      'lib/core/error',
      'lib/core/network',
      'lib/core/storage',
    ];
    for (final folder in coreFolders) {
      await FileUtils.createFolder(folder);
    }

    // Create core files
    await FileUtils.createFile(
        'lib/core/error/exceptions.dart', CoreTemplates.exceptionsTemplate);
    await FileUtils.createFile(
        'lib/core/error/failures.dart', CoreTemplates.failures);
    await FileUtils.createFile(
        'lib/core/common/isolate_parser.dart', CoreTemplates.isolateParser);
    await FileUtils.createFile('lib/core/di/injector.dart',
        CoreTemplates.injector(withDio, withGoRouter, projectName));
    if (withHive) {
      await FileUtils.createFile(
          'lib/core/storage/hive_storage.dart', CoreTemplates.hiveStorage);
    }

    if (withDio) {
      await FileUtils.createFile(
          'lib/core/network/api_client.dart', CoreTemplates.apiClientTemplate);
    }
    if (withGoRouter) {
      await FileUtils.createFile(
          'lib/core/config/router.dart', CoreTemplates.router(projectName));
    }
  }

  Future<void> _addDependencies(bool withRiverpod, bool withBloc, bool withDio,
      bool withGoRouter, bool withHive) async {
    print('\n📦 Adding required dependencies to pubspec.yaml...');

    final commonDeps = ['get_it', 'dartz', 'connectivity_plus', 'equatable'];
    await FileUtils.runCommand('flutter', ['pub', 'add', ...commonDeps]);

    if (withRiverpod) {
      await FileUtils.runCommand('flutter', ['pub', 'add', 'flutter_riverpod']);
    }
    if (withBloc) {
      await FileUtils.runCommand(
          'flutter', ['pub', 'add', 'flutter_bloc', 'bloc']);
    }
    if (withDio) {
      await FileUtils.runCommand('flutter', ['pub', 'add', 'dio']);
    }
    if (withGoRouter) {
      await FileUtils.runCommand('flutter', ['pub', 'add', 'go_router']);
    }
    if (withHive) {
      await FileUtils.runCommand(
          'flutter', ['pub', 'add', 'hive', 'hive_flutter']);
      await FileUtils.runCommand(
          'flutter', ['pub', 'add', '--dev', 'hive_generator', 'build_runner']);
    }
  }
}
