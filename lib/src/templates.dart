// lib/src/templates.dart

// --- README Template ---
String getReadmeTemplate(String projectName) => """
# $projectName

A new Flutter project structured with the Flutter Scaffold CLI.

## Project Structure

This project follows a feature-first, clean architecture approach.

- **/lib**: Contains all the Dart code.
  - **/core**: Shared code used across multiple features (e.g., error handling, dependency injection, theme).
  - **/features**: Each feature of the app gets its own folder.
    - **data**: Data layer (models, data sources, repository implementations).
    - **domain**: Business logic (entities, use cases, repository contracts).
    - **presentation**: UI layer (pages, widgets, state management).
  - **/main.dart**: The entry point of the application.
  - **/injection_container.dart**: Dependency injection setup.

## Getting Started

1.  Install dependencies: `flutter pub get`
2.  Run the app: `flutter run`
""";

// --- Main.dart Template ---
String getMainTemplate({required String projectName, required bool useRiverpod, bool useBloc = false}) {
  String providerScope = useRiverpod ? 'ProviderScope(child: MyApp())' : 'const MyApp()';
  String mainBody = 'runApp(const $providerScope);';

  return """
import 'package:flutter/material.dart';
${useRiverpod ? "import 'package:flutter_riverpod/flutter_riverpod.dart';" : ""}
import 'features/example_feature/presentation/pages/example_page.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize dependency injection
  runApp(${useRiverpod ? 'const ProviderScope(child: MyApp())' : 'const MyApp()'});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$projectName',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ExamplePage(),
    );
  }
}
""";
}

// --- Example Page Template ---
String getExamplePageTemplate({required bool useRiverpod, bool useBloc = false}) {
  String widgetClass = useRiverpod ? 'ConsumerWidget' : 'StatelessWidget';
  String buildMethod = useRiverpod ? 'Widget build(BuildContext context, WidgetRef ref)' : 'Widget build(BuildContext context)';
  
  return """
import 'package:flutter/material.dart';
${useRiverpod ? "import 'package:flutter_riverpod/flutter_riverpod.dart';" : ""}

class ExamplePage extends $widgetClass {
  const ExamplePage({super.key});

  @override
  $buildMethod {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scaffolded App'),
      ),
      body: const Center(
        child: Text(
          'Welcome to your structured Flutter App!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
""";
}


// --- Other Core File Templates ---

const String diTemplate = """
import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  //! Features - Example

  //! Core

  //! External
}
""";

const String failureTemplate = """
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
""";

String usecaseTemplate({required String projectName}) {
  return """
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:$projectName/core/error/failure.dart';


abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
""";

}