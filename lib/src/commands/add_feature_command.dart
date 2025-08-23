import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_scaffold/src/templates/feature_templates.dart';
import 'package:flutter_scaffold/src/utils/file_utils.dart';

class AddFeatureCommand extends Command<void> {
  @override
  final name = 'add';
  @override
  final description =
      'Adds a new feature folder with all necessary sub-layers (data, domain, presentation). Supports both interactive prompts and command-line arguments.';

  AddFeatureCommand() {
    argParser
      ..addOption('name',
          abbr: 'n',
          help:
              'The name of the feature in snake_case (e.g., "user_profile"). If not provided, will prompt interactively.')
      ..addOption('state',
          help: 'State management choice for the feature.',
          allowed: ['riverpod', 'bloc', 'none'],
          defaultsTo: 'none')
      ..addFlag('with-g-routes',
          help: 'Generate a route for this feature using go_router.',
          negatable: false);
  }

  @override
  Future<void> run() async {
    // Check if the name was passed as an argument, otherwise prompt the user.
    String? featureName = argResults?['name'] as String?;
    if (featureName == null || featureName.isEmpty) {
      featureName = _promptForFeatureName();
    }

    if (!RegExp(r'^[a-z_]+$').hasMatch(featureName)) {
      throw 'Feature name must be in snake_case (e.g., "user_profile").';
    }

    // Check if state management was specified, otherwise prompt the user.
    String stateManagement;
    if (argResults!.wasParsed('state')) {
      stateManagement = argResults!['state'] as String;
    } else {
      stateManagement = _promptForStateManagement();
    }

    // Check if go_router flag was used, otherwise prompt the user.
    bool withGoRouter;
    if (argResults!.wasParsed('with-g-routes')) {
      withGoRouter = argResults!['with-g-routes'] as bool;
    } else {
      withGoRouter = _promptYesNo(
          'Do you want to generate a route for this feature using go_router?');
    }

    final projectName = FileUtils.getFlutterProjectName();

    await createFeature(
      name: featureName,
      projectName: projectName,
      stateManagement: stateManagement,
      withGoRouter: withGoRouter,
    );
    print('\n✅ Feature "$featureName" added successfully!');
  }

  /// Prompts the user to enter the feature name and validates it.
  String _promptForFeatureName() {
    String? featureName;
    while (featureName == null ||
        featureName.isEmpty ||
        !RegExp(r'^[a-z_]+$').hasMatch(featureName)) {
      stdout.write(
          'Enter the name of the feature in snake_case (e.g., "user_profile"): ');
      featureName = stdin.readLineSync();
      if (featureName != null && !RegExp(r'^[a-z_]+$').hasMatch(featureName)) {
        print('Invalid format. The name must be in snake_case.');
      }
    }
    return featureName;
  }

  /// Prompts the user to select a state management option.
  String _promptForStateManagement() {
    stdout.write(
        'Choose state management for this feature (riverpod/bloc/none) [none]: ');
    String? selection = stdin.readLineSync()?.toLowerCase();
    if (selection == null || selection.isEmpty) {
      return 'none';
    }
    while (
        selection != 'riverpod' && selection != 'bloc' && selection != 'none') {
      stdout.write('Invalid choice. Please enter riverpod, bloc, or none: ');
      selection = stdin.readLineSync()?.toLowerCase();
    }
    return selection ?? 'none';
  }

  /// Prompts the user with a yes/no question.
  bool _promptYesNo(String question) {
    stdout.write('$question (y/n) [n]: ');
    final input = stdin.readLineSync()?.toLowerCase();
    return input == 'y';
  }

  Future<void> createFeature(
      {required String name,
      required String projectName,
      required String stateManagement,
      required bool withGoRouter}) async {
    final featurePath = 'lib/features/$name';
    final featureFolders = [
      '$featurePath/data/datasources',
      '$featurePath/data/models',
      '$featurePath/data/repositories',
      '$featurePath/domain/entities',
      '$featurePath/domain/repositories',
      '$featurePath/domain/usecases',
      '$featurePath/presentation/pages',
      if (stateManagement != 'none') '$featurePath/presentation/state',
      '$featurePath/presentation/widgets',
    ];

    for (final folder in featureFolders) {
      await FileUtils.createFolder(folder);
    }

    // Domain Layer
    await FileUtils.createFile(
        '$featurePath/domain/entities/${name}_entity.dart',
        FeatureTemplates.entity(name));
    await FileUtils.createFile(
        '$featurePath/domain/repositories/${name}_repository.dart',
        FeatureTemplates.domainRepository(name, projectName));
    await FileUtils.createFile(
        '$featurePath/domain/usecases/get_${name}_data.dart',
        FeatureTemplates.usecase(name, projectName));

    // Data Layer
    await FileUtils.createFile('$featurePath/data/models/${name}_model.dart',
        FeatureTemplates.model(name, projectName));
    await FileUtils.createFile(
        '$featurePath/data/datasources/${name}_remote_data_source.dart',
        FeatureTemplates.remoteDataSource(name, projectName));
    await FileUtils.createFile(
        '$featurePath/data/repositories/${name}_repository_impl.dart',
        FeatureTemplates.dataRepositoryImpl(name, projectName));

    // Presentation Layer
    await FileUtils.createFile(
        '$featurePath/presentation/pages/${name}_page.dart',
        FeatureTemplates.page(
            name, stateManagement, withGoRouter, projectName));
    if (stateManagement == 'riverpod') {
      await FileUtils.createFile(
          '$featurePath/presentation/state/${name}_providers.dart',
          FeatureTemplates.riverpodProvider(name, projectName));
    } else if (stateManagement == 'bloc') {
      await FileUtils.createFile(
          '$featurePath/presentation/state/${name}_bloc.dart',
          FeatureTemplates.bloc(name, projectName));
      await FileUtils.createFile(
          '$featurePath/presentation/state/${name}_event.dart',
          FeatureTemplates.blocEvent(name));
      await FileUtils.createFile(
          '$featurePath/presentation/state/${name}_state.dart',
          FeatureTemplates.blocState(name, projectName));
    }
  }
}
