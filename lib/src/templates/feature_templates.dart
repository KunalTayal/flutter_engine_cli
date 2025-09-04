// lib/src/templates/feature_templates.dart
import 'package:flutter_scaffold_cli/src/utils/file_utils.dart';

class FeatureTemplates {
  static String entity(String name) => '''
import 'package:equatable/equatable.dart';

class ${name.toPascalCase()}Entity extends Equatable {
  final String message;

  const ${name.toPascalCase()}Entity({required this.message});

  @override
  List<Object?> get props => [message];
}
''';

  static String model(String name, String projectName) => '''
import 'package:$projectName/features/$name/domain/entities/${name}_entity.dart';

class ${name.toPascalCase()}Model extends ${name.toPascalCase()}Entity {
  const ${name.toPascalCase()}Model({required super.message});

  factory ${name.toPascalCase()}Model.fromJson(Map<String, dynamic> json) {
    return ${name.toPascalCase()}Model(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
''';

  static String domainRepository(String name, String projectName) => '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/error/failures.dart';
import 'package:$projectName/features/$name/domain/entities/${name}_entity.dart';

abstract class ${name.toPascalCase()}Repository {
  Future<Either<Failure, ${name.toPascalCase()}Entity>> get${name.toPascalCase()}Data();
}
''';

  static String dataRepositoryImpl(String name, String projectName) => '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/error/exceptions.dart';
import 'package:$projectName/core/error/failures.dart';
import 'package:$projectName/features/$name/data/datasources/${name}_remote_data_source.dart';
import 'package:$projectName/features/$name/domain/entities/${name}_entity.dart';
import 'package:$projectName/features/$name/domain/repositories/${name}_repository.dart';

class ${name.toPascalCase()}RepositoryImpl implements ${name.toPascalCase()}Repository {
  final ${name.toPascalCase()}RemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Example for checking connectivity

  ${name.toPascalCase()}RepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, ${name.toPascalCase()}Entity>> get${name.toPascalCase()}Data() async {
    // if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.get${name.toPascalCase()}Data();
        return Right(remoteData);
      } on ServerException {
        return Left(ServerFailure());
      }
    // } else {
    //   return Left(ServerFailure()); // Or a specific NoInternetConnectionFailure
    // }
  }
}
''';

  static String remoteDataSource(String name, String projectName) => '''
// import 'package:$projectName/core/error/exceptions.dart'; // Assuming you use the generated ApiClient
// import 'package:$projectName/core/network/api_client.dart'; // Assuming you use the generated ApiClient
import 'package:$projectName/features/$name/data/models/${name}_model.dart';

abstract class ${name.toPascalCase()}RemoteDataSource {
  Future<${name.toPascalCase()}Model> get${name.toPascalCase()}Data();
}

class ${name.toPascalCase()}RemoteDataSourceImpl implements ${name.toPascalCase()}RemoteDataSource {
  // final ApiClient apiClient;

  // ${name.toPascalCase()}RemoteDataSourceImpl({required this.apiClient});

  @override
  Future<${name.toPascalCase()}Model> get${name.toPascalCase()}Data() async {
    // Example with Dio from ApiClient
    // final response = await apiClient.get('/$name');
    // if (response.statusCode == 200) {
    //   return ${name.toPascalCase()}Model.fromJson(response.data);
    // } else {
    //   throw ServerException();
    // }
    
    // Placeholder implementation
    await Future.delayed(const Duration(seconds: 1));
    return const ${name.toPascalCase()}Model(message: 'Hello from Remote Data Source!');
  }
}
''';

  static String usecase(String name, String projectName) => '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/error/failures.dart';
import 'package:$projectName/features/$name/domain/entities/${name}_entity.dart';
import 'package:$projectName/features/$name/domain/repositories/${name}_repository.dart';

class Get${name.toPascalCase()}Data {
  final ${name.toPascalCase()}Repository repository;

  Get${name.toPascalCase()}Data(this.repository);

  Future<Either<Failure, ${name.toPascalCase()}Entity>> call() async {
    return await repository.get${name.toPascalCase()}Data();
  }
}
''';

  static String page(String name, String stateManagement, bool withGoRouter,
          String projectName) =>
      '''
import 'package:flutter/material.dart';
${stateManagement == 'riverpod' ? "import 'package:flutter_riverpod/flutter_riverpod.dart';" : ""}
${stateManagement == 'bloc' ? "import 'package:flutter_bloc/flutter_bloc.dart';" : ""}
${stateManagement == 'bloc' ? "import 'package:$projectName/features/$name/presentation/state/${name}_bloc.dart';" : ""}
${stateManagement == 'bloc' ? "import 'package:$projectName/features/$name/presentation/state/${name}_event.dart';" : ""}
${stateManagement == 'bloc' ? "import 'package:$projectName/features/$name/presentation/state/${name}_state.dart';" : ""}
${stateManagement == 'riverpod' ? "import 'package:$projectName/features/$name/presentation/state/${name}_providers.dart';" : ""}

class ${name.toPascalCase()}Page extends StatelessWidget {
  ${withGoRouter ? "static const routeName = '${name.toLowerCase()}';" : ""}
  const ${name.toPascalCase()}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${name.toPascalCase()} Page'),
      ),
      body: ${stateManagement == 'riverpod' ? _riverpodBody(name) : stateManagement == 'bloc' ? _blocBody(name) : _defaultBody(name)},
    );
  }
}

${stateManagement == 'riverpod' ? '''
class _${name.toPascalCase()}View extends ConsumerWidget {
  const _${name.toPascalCase()}View();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ${name.toCamelCase()}Data = ref.watch(${name.toCamelCase()}DataProvider);
    
    return ${name.toCamelCase()}Data.when(
      data: (data) => Center(child: Text(data.message)),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: \$error')),
    );
  }
}
''' : ''}

${stateManagement == 'bloc' ? '''
class _${name.toPascalCase()}View extends StatelessWidget {
  const _${name.toPascalCase()}View();
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ${name.toPascalCase()}Bloc()..add(Fetch${name.toPascalCase()}Data()),
      child: BlocBuilder<${name.toPascalCase()}Bloc, ${name.toPascalCase()}State>(
        builder: (context, state) {
          if (state is ${name.toPascalCase()}Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ${name.toPascalCase()}Loaded) {
            return Center(child: Text(state.entity.message));
          } else if (state is ${name.toPascalCase()}Error) {
            return Center(child: Text('Error: \${state.message}'));
          }
          return const Center(child: Text('Press a button to fetch data.'));
        },
      ),
    );
  }
}
''' : ''}
''';

  static String _riverpodBody(String name) =>
      'const _${name.toPascalCase()}View()';
  static String _blocBody(String name) => 'const _${name.toPascalCase()}View()';
  static String _defaultBody(String name) =>
      "const Center(child: Text('Welcome to ${name.toPascalCase()}!'),)";

  static String riverpodProvider(String name, String projectName) => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:$projectName/features/$name/domain/usecases/get_${name}_data.dart';
// import 'package:$projectName/core/di/injector.dart'; // Assuming GetIt for Usecase injection

// This is a placeholder for where you would set up your use case provider.
// You'll need to register Get${name.toPascalCase()}Data in your GetIt injector.
// For example: sl.registerLazySingleton(() => Get${name.toPascalCase()}Data(sl()));
final get${name.toPascalCase()}DataUsecaseProvider = Provider((ref) => Get${name.toPascalCase()}Data(sl()));

final ${name.toCamelCase()}DataProvider = FutureProvider.autoDispose((ref) async {
  final get${name.toCamelCase()}Data = ref.watch(get${name.toPascalCase()}DataUsecaseProvider);
  final result = await get${name.toCamelCase()}Data();
  return result.fold(
    (failure) => throw Exception('Failed to fetch data'), // Or handle failure more gracefully
    (entity) => entity,
  );
});
''';

  static String bloc(String name, String projectName) => '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:$projectName/features/$name/domain/entities/${name}_entity.dart';
import 'package:$projectName/features/$name/presentation/state/${name}_event.dart';
import 'package:$projectName/features/$name/presentation/state/${name}_state.dart';
import 'package:$projectName/features/$name/domain/usecases/get_${name}_data.dart';
import 'package:$projectName/core/di/injector.dart'; // Assuming GetIt

class ${name.toPascalCase()}Bloc extends Bloc<${name.toPascalCase()}Event, ${name.toPascalCase()}State> {
  // late final Get${name.toPascalCase()}Data get${name.toPascalCase()}Data;

  ${name.toPascalCase()}Bloc() : super(${name.toPascalCase()}Initial()) {
    // get${name.toPascalCase()}Data = sl<Get${name.toPascalCase()}Data>(); // Resolve from GetIt
    on<Fetch${name.toPascalCase()}Data>((event, emit) async {
      emit(${name.toPascalCase()}Loading());
      // final failureOrEntity = await get${name.toPascalCase()}Data();
      // emit(failureOrEntity.fold(
      //   (failure) => ${name.toPascalCase()}Error('Failed to fetch data.'),
      //   (entity) => ${name.toPascalCase()}Loaded(entity),
      // ));
      
      // Placeholder
      await Future.delayed(const Duration(seconds: 1));
      emit(${name.toPascalCase()}Loaded(const ${name.toPascalCase()}Entity(message: 'Hello from BLoC!')));

    });
  }
}
''';

  static String blocEvent(String name) => '''
import 'package:equatable/equatable.dart';

abstract class ${name.toPascalCase()}Event extends Equatable {
  const ${name.toPascalCase()}Event();
  @override
  List<Object> get props => [];
}

class Fetch${name.toPascalCase()}Data extends ${name.toPascalCase()}Event {}
''';

  static String blocState(String name, String projectName) => '''
import 'package:equatable/equatable.dart';
import 'package:$projectName/features/$name/domain/entities/${name}_entity.dart';

abstract class ${name.toPascalCase()}State extends Equatable {
  const ${name.toPascalCase()}State();
  @override
  List<Object> get props => [];
}

class ${name.toPascalCase()}Initial extends ${name.toPascalCase()}State {}
class ${name.toPascalCase()}Loading extends ${name.toPascalCase()}State {}
class ${name.toPascalCase()}Loaded extends ${name.toPascalCase()}State {
  final ${name.toPascalCase()}Entity entity;
  const ${name.toPascalCase()}Loaded(this.entity);
  @override
  List<Object> get props => [entity];
}
class ${name.toPascalCase()}Error extends ${name.toPascalCase()}State {
  final String message;
  const ${name.toPascalCase()}Error(this.message);
  @override
  List<Object> get props => [message];
}
''';
}
