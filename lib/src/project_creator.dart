// lib/src/project_creator.dart
import 'dart:convert';
import 'dart:io';
import 'package:tint/tint.dart';
import 'templates.dart' as templates;

class ProjectCreator {
  final bool useRiverpod;
  final bool useBloc;
  final bool useDio;
  final String projectName;

  ProjectCreator({
    required this.useRiverpod,
    required this.useBloc,
    required this.useDio,
  }) : projectName = _getProjectName();

  // (The rest of the class up to the run() method is the same)
  // ...

  static String _getProjectName() {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) return 'my_awesome_app';
    final lines = pubspec.readAsLinesSync();
    final nameLine = lines.firstWhere(
      (line) => line.startsWith('name:'),
      orElse: () => 'name: my_awesome_app',
    );
    return nameLine.split(':')[1].trim();
  }

  void run() async {
    // 1. Validate we're in a Flutter project
    if (!File('pubspec.yaml').existsSync() || !Directory('lib').existsSync()) {
      print('Error: Not a valid Flutter project root.'.red());
      print('Please run this command from the root of a Flutter project.');
      exit(1);
    }

    // 2. Confirm with the user
    print('\nThis will perform the following actions:'.yellow());
    print('- Delete lib/main.dart and the test/ directory.');
    print('- Create a new feature-first, clean architecture structure.');
    print('- Add required dependencies to pubspec.yaml.');
    stdout.write('\nAre you sure you want to proceed? (y/N) '.bold());
    final response = stdin.readLineSync()?.toLowerCase();
    
    if (response != 'y' && response != 'yes') {
      print('Operation cancelled.'.gray());
      exit(0);
    }

    print('\n🚀 Starting scaffolding...'.cyan());

    // 3. Clean up existing files
    await _cleanup();

    // 4. Create directories
    await _createDirectories();

    // 5. Create core files from templates
    await _createCoreFiles();

    // 6. Add dependencies
    await _addDependencies();

    print('\n✅ Project scaffolding complete!'.green().bold());
    print('You may need to run `flutter pub get` one more time.'.green());
    print('Happy coding!'.green());
  }

  Future<void> _cleanup() async {
    print('🧹 Cleaning up old files...');
    final libMain = File('lib/main.dart');
    final testDir = Directory('test');
    if (libMain.existsSync()) await libMain.delete();
    if (testDir.existsSync()) await testDir.delete(recursive: true);
  }

  Future<void> _createDirectories() async {
    print('🏗️ Creating directories...');
    final dirs = [
      'lib/core/error',
      'lib/core/network',
      'lib/core/theme',
      'lib/core/usecases',
      'lib/core/di',
      'lib/features/example_feature/data/datasources',
      'lib/features/example_feature/data/models',
      'lib/features/example_feature/data/repositories',
      'lib/features/example_feature/domain/entities',
      'lib/features/example_feature/domain/repositories',
      'lib/features/example_feature/domain/usecases',
      'lib/features/example_feature/presentation/pages',
      'lib/features/example_feature/presentation/widgets',
    ];

    if (useBloc) dirs.add('lib/features/example_feature/presentation/bloc');
    if (useRiverpod) dirs.add('lib/features/example_feature/presentation/providers');

    for (final dir in dirs) {
      await Directory(dir).create(recursive: true);
    }
  }

  Future<void> _createCoreFiles() async {
    print('📝 Writing boilerplate files...');
    await File('lib/main.dart').writeAsString(
        templates.getMainTemplate(projectName: projectName, useRiverpod: useRiverpod, useBloc: useBloc));
    
    await File('lib/core/error/failure.dart').writeAsString(templates.failureTemplate);
    await File('lib/core/usecases/usecase.dart').writeAsString(templates.usecaseTemplate(projectName: projectName));
    await File('lib/core/di/injection_container.dart').writeAsString(templates.diTemplate);
    
    await File('README.md').writeAsString(templates.getReadmeTemplate(projectName));

    await File('lib/features/example_feature/presentation/pages/example_page.dart')
        .writeAsString(templates.getExamplePageTemplate(useRiverpod: useRiverpod, useBloc: useBloc));
  }

  Future<void> _addDependencies() async {
    print('📦 Adding dependencies via `flutter pub add`...');
    final deps = ['get_it', 'equatable', 'dartz'];
    if (useRiverpod) deps.addAll(['flutter_riverpod', 'riverpod_annotation']);
    if (useBloc) deps.addAll(['flutter_bloc', 'bloc']);
    if (useDio) deps.add('dio');

    final devDeps = ['build_runner'];
    if (useRiverpod) devDeps.add('riverpod_generator');

    // Use 'flutter' as the command and let _runProcess handle the OS-specifics
    await _runProcess('flutter', ['pub', 'add', ...deps]);
    await _runProcess('flutter', ['pub', 'add', '--dev', ...devDeps]);
  }

  /// Runs a process and streams its output.
  /// Handles OS-specific executable names (e.g., .bat on Windows).
  Future<void> _runProcess(String command, List<String> args) async {
    final executable = Platform.isWindows ? '$command.bat' : command;
    
    final process = await Process.start(executable, args, runInShell: true);

    // Stream the process output to the console
    await for (var line in process.stdout.transform(utf8.decoder)) {
      stdout.write(line);
    }
    await for (var line in process.stderr.transform(utf8.decoder)) {
      stderr.write(line.red());
    }

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      print('\nError: Process "$executable ${args.join(' ')}" failed with exit code $exitCode'.red());
      exit(exitCode);
    }
  }
}