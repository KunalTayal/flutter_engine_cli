import 'package:args/command_runner.dart';
import 'package:flutter_scaffold/src/templates/feature_templates.dart';
import 'package:flutter_scaffold/src/utils/file_utils.dart';

class AddFeatureCommand extends Command<void> {
  @override
  final name = 'add';
  @override
  final description =
      'Adds a new feature folder with all necessary sub-layers (data, domain, presentation).';

  AddFeatureCommand() {
    argParser
      ..addOption('name',
          abbr: 'n',
          help: 'The name of the feature in snake_case (e.g., "user_profile").',
          mandatory: true)
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
    final featureName = argResults!['name'] as String;
    final stateManagement = argResults!['state'] as String;
    final withGoRouter = argResults!['with-g-routes'] as bool;

    final projectName = FileUtils.getFlutterProjectName();

    if (featureName.isEmpty || !RegExp(r'^[a-z_]+$').hasMatch(featureName)) {
      throw 'Feature name must be in snake_case (e.g., "user_profile").';
    }

    await createFeature(
      name: featureName,
      projectName: projectName,
      stateManagement: stateManagement,
      withGoRouter: withGoRouter,
    );
    print('\n✅ Feature "$featureName" added successfully!');
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
      '$featurePath/presentation/state',
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
        FeatureTemplates.page(name, stateManagement, withGoRouter, projectName));
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
