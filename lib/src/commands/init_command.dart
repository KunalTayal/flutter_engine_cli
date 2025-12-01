import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_scaffold_cli/src/commands/add_feature_command.dart';
import 'package:flutter_scaffold_cli/src/templates/core_templates.dart';
import 'package:flutter_scaffold_cli/src/templates/ffi_templates.dart';
import 'package:flutter_scaffold_cli/src/templates/rust_templates.dart';
import 'package:flutter_scaffold_cli/src/utils/file_utils.dart';
import 'package:tint/tint.dart';

class InitCommand extends Command<void> {
  @override
  final name = 'init';
  @override
  final description =
      'Initializes a clean architecture structure in the current Flutter project.';

  InitCommand() {
    // Remove all flags since we're using interactive questions
  }

  @override
  Future<void> run() async {
    final projectName = FileUtils.getFlutterProjectName();

    print(
        '🚀 Initializing project "$projectName" with Clean Architecture...\n');

    // Interactive questions
    final stateManagement = await _askForStateManagement();
    final withDio = await _askYesNo(
        'Do you want to add Dio for advanced network requests? (y/n): ');
    final withGoRouter =
        await _askYesNo('Do you want to add go_router for navigation? (y/n): ');
    final withHive =
        await _askYesNo('Do you want to add Hive for local storage? (y/n): ');
    final withFfi = await _askYesNo(
        'Do you want to add Rust FFI for high-performance JSON and image processing? (y/n): ');

    final withRiverpod = stateManagement == 'riverpod';
    final withBloc = stateManagement == 'bloc';

    // Create core structure
    await _createCoreStructure(
        withDio, withGoRouter, withHive, withFfi, projectName);

    // Create main.dart
    await FileUtils.createFile(
        'lib/main.dart',
        CoreTemplates.mainDart(
            withRiverpod, withGoRouter, withFfi, projectName));

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

    // Create Rust files if FFI is enabled
    if (withFfi) {
      await _createRustFiles(projectName);
    }

    // Add dependencies
    await _addDependencies(
        withRiverpod, withBloc, withDio, withGoRouter, withHive, withFfi);

    print('\n🎉 Project initialized successfully!');
    print('Run `flutter pub get` to install dependencies.');
  }

  Future<String> _askForStateManagement() async {
    print('Select state management solution:');
    print('1. BLoC');
    print('2. Riverpod');
    print('3. None (use basic state management)');

    while (true) {
      stdout.write('Enter your choice (1-3): ');
      final input = stdin.readLineSync()?.trim();

      switch (input) {
        case '1':
          return 'bloc';
        case '2':
          return 'riverpod';
        case '3':
          return 'none';
        default:
          print('❌ Invalid choice. Please enter 1, 2, or 3.'.red());
      }
    }
  }

  Future<bool> _askYesNo(String question) async {
    while (true) {
      stdout.write(question);
      final input = stdin.readLineSync()?.trim().toLowerCase();

      if (input == 'y' || input == 'yes') {
        return true;
      } else if (input == 'n' || input == 'no') {
        return false;
      } else {
        print('❌ Please enter y/yes or n/no.'.red());
      }
    }
  }

  Future<void> _createCoreStructure(bool withDio, bool withGoRouter,
      bool withHive, bool withFfi, String projectName) async {
    final coreFolders = [
      'lib/core/common',
      'lib/core/common/widgets',
      'lib/core/config',
      'lib/core/constants',
      'lib/core/di',
      'lib/core/error',
      'lib/core/network',
      'lib/core/storage',
      'lib/core/theme',
      'lib/core/utils',
    ];

    if (withFfi) {
      coreFolders.add('lib/core/ffi');
    }

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
    await FileUtils.createFile('lib/core/theme/app_theme.dart',
        CoreTemplates.appThemeTemplate(projectName));
    await FileUtils.createFile(
        'lib/core/constants/app_assets.dart', CoreTemplates.appAssetsTemplate);
    await FileUtils.createFile('lib/core/constants/app_strings.dart',
        CoreTemplates.appStringsTemplate);
    await FileUtils.createFile(
        'lib/core/constants/app_colors.dart', CoreTemplates.appColorsTemplate);
    await FileUtils.createFile('lib/core/constants/app_text_styles.dart',
        CoreTemplates.appTextStylesTemplate);
    if (withHive) {
      await FileUtils.createFile(
          'lib/core/storage/hive_storage.dart', CoreTemplates.hiveStorage);
    }

    if (withDio) {
      await FileUtils.createFile('lib/core/config/environment_config.dart',
          CoreTemplates.environmentConfigTemplate);
      await FileUtils.createFile('lib/core/config/api_endpoints.dart',
          CoreTemplates.apiEndpointsTemplate(projectName));
      await FileUtils.createFile(
          'lib/core/network/api_client.dart', CoreTemplates.apiClientTemplate);
    }
    if (withGoRouter) {
      await FileUtils.createFile(
          'lib/core/config/router.dart', CoreTemplates.router(projectName));
    }

    if (withFfi) {
      // Create FFI files
      await FileUtils.createFile(
          'lib/core/ffi/rust_ffi.dart', FfiTemplates.rustFfi(projectName));
      await FileUtils.createFile('lib/core/common/hybrid_parser.dart',
          FfiTemplates.hybridParser(projectName));
      await FileUtils.createFile('lib/core/common/rust_parser.dart',
          FfiTemplates.rustParser(projectName));
      await FileUtils.createFile('lib/core/common/image_service.dart',
          FfiTemplates.imageService(projectName));
    }
  }

  Future<void> _createRustFiles(String projectName) async {
    print('\n📦 Creating Rust FFI files...');
    try {
      // Create rust directory structure
      await FileUtils.createFolder('rust');
      await FileUtils.createFolder('rust/src');

      // Create Cargo.toml
      await FileUtils.createFile(
          'rust/Cargo.toml', RustTemplates.cargoToml(projectName));

      // Create build scripts (cross-platform)
      await FileUtils.createFile(
          'rust/build.sh', RustTemplates.buildSh(projectName));
      await FileUtils.createFile(
          'rust/build.bat', RustTemplates.buildBat(projectName));
      await FileUtils.createFile('rust/Makefile', RustTemplates.makefile);
      await FileUtils.createFile('rust/.gitignore', RustTemplates.gitignore);

      // Create documentation
      await FileUtils.createFile(
          'rust/README.md', RustTemplates.readme(projectName));
      await FileUtils.createFile(
          'rust/QUICK_START.md', RustTemplates.quickStart(projectName));

      // Create Rust source files
      await FileUtils.createFile('rust/src/lib.rs', RustTemplates.libRs);
      await FileUtils.createFile(
          'rust/src/ffi.rs', RustTemplates.ffiRs(projectName));
      await FileUtils.createFile(
          'rust/src/json_processing.rs', RustTemplates.jsonProcessingRs);
      await FileUtils.createFile(
          'rust/src/image_processing.rs', RustTemplates.imageProcessingRs);
      await FileUtils.createFile(
          'rust/src/cache.rs', RustTemplates.cacheRs(projectName));

      // Make build.sh executable on Unix-like systems (macOS, Linux)
      if (Platform.isMacOS || Platform.isLinux) {
        try {
          await Process.run('chmod', ['+x', 'rust/build.sh']);
        } catch (e) {
          // Ignore if chmod fails, user can do it manually
          print(
              '   Note: Run `chmod +x rust/build.sh` to make the build script executable');
        }
      }

      print('✅ Rust FFI files created successfully!');
      print('   Next steps:');
      print('   1. Install Rust: https://rustup.rs/');
      if (Platform.isWindows) {
        print('   2. Build the library: cd rust && build.bat');
      } else {
        print('   2. Build the library: cd rust && ./build.sh');
      }
      print('   3. Copy the built library to your platform-specific location');
      print('   See rust/README.md for detailed instructions.');
    } catch (e) {
      print('❌ Error: Failed to create Rust files: \$e');
      rethrow;
    }
  }

  // Function to dynamically get the Flutter executable path based on the OS
  Future<String?> _getFlutterExecutable() async {
    if (Platform.isWindows) {
      try {
        // On Windows, the command is flutter.bat. We try to find its full path.
        final result = await Process.run('where', ['flutter.bat']);
        if (result.exitCode == 0) {
          // The output is the path, split by newlines. We take the first one.
          final path = result.stdout.toString().trim().split('\n').first;
          print('Found Flutter executable at: $path');
          return path;
        }
      } catch (e) {
        // Fallback in case 'where' command fails.
        print(
            'Could not find flutter.bat using "where". Falling back to "flutter.bat" command.');
      }
      // Final fallback
      return 'flutter.bat';
    } else if (Platform.isMacOS || Platform.isLinux) {
      // On macOS and Linux, the command is simply 'flutter'
      return 'flutter';
    }

    // If the OS is not recognized, print a warning and return null.
    print('Warning: Running on an unsupported platform.');
    return null;
  }

  Future<void> _addDependencies(bool withRiverpod, bool withBloc, bool withDio,
      bool withGoRouter, bool withHive, bool withFfi) async {
    print('\n📦 Adding required dependencies...');

    // Get the correct executable path once
    final flutterExecutable = await _getFlutterExecutable();
    if (flutterExecutable == null) {
      print('❌ Cannot proceed. Flutter executable not found for this OS.');
      exit(1);
    }

    try {
      // Group common dependencies into a single call for efficiency
      final commonDeps = ['get_it', 'dartz', 'connectivity_plus', 'equatable'];
      if (withRiverpod) commonDeps.add('flutter_riverpod');
      if (withBloc) commonDeps.addAll(['flutter_bloc', 'bloc']);
      if (withDio) commonDeps.add('dio');
      if (withGoRouter) commonDeps.add('go_router');
      if (withHive) commonDeps.addAll(['hive', 'hive_flutter']);
      if (withFfi) commonDeps.addAll(['ffi', 'crypto']);

      if (commonDeps.isNotEmpty) {
        await FileUtils.runCommand(
            flutterExecutable, ['pub', 'add', ...commonDeps]);
      }

      // Handle dev dependencies separately
      final devDeps = <String>[];
      if (withHive) {
        devDeps.addAll(['hive_generator', 'build_runner']);
      }

      // Add dev dependencies one by one
      for (final dep in devDeps) {
        print('Adding dev dependency $dep...');
        await FileUtils.runCommand(
            flutterExecutable, ['pub', 'add', '--dev', dep]);
      }

      print('\n✅ All dependencies added successfully!');
    } on ProcessException catch (e) {
      print('\n❌ An error occurred while adding dependencies.'.red().bold());
      print('The command "${e.executable} ${e.arguments.join(' ')}" failed.'
          .red());
      print(
          'This can sometimes happen due to network issues or a misconfigured Flutter installation.'
              .yellow());
      print('Please try running the command manually in your project directory.'
          .yellow());
      exit(e.errorCode); // Exit with the same error code as the failed process
    }
  }
}
