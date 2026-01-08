// Flutter Engine CLI - Usage Example
// This file demonstrates how to use Flutter Engine CLI to create a Flutter app

/// ============================================================================
/// STEP 1: INSTALLATION
/// ============================================================================
///
/// Install Flutter Engine CLI globally:
/// ```bash
/// dart pub global activate flutter_engine_cli
/// ```
///
/// Verify installation:
/// ```bash
/// flutter_engine_cli --version
/// ```

/// ============================================================================
/// STEP 2: CREATE A NEW FLUTTER PROJECT
/// ============================================================================
///
/// ```bash
/// flutter create my_awesome_app
/// cd my_awesome_app
/// ```

/// ============================================================================
/// STEP 3: INITIALIZE WITH FLUTTER ENGINE CLI
/// ============================================================================
///
/// Run the init command:
/// ```bash
/// flutter_engine_cli init
/// ```
///
/// The CLI will guide you through interactive setup:
///
/// ```
/// 🚀 Initializing project "my_awesome_app" with Clean Architecture...
///
/// Select state management solution:
/// 1. BLoC
/// 2. Riverpod
/// 3. None (use basic state management)
/// Enter your choice (1-3): 2
///
/// Do you want to add Dio for advanced network requests? (y/n): y
/// Do you want to add go_router for navigation? (y/n): y
/// Do you want to add Hive for local storage? (y/n): y
/// Do you want to add Rust FFI for high-performance JSON and image processing? (y/n): n
/// ```
///
/// After initialization, install dependencies:
/// ```bash
/// flutter pub get
/// ```

/// ============================================================================
/// STEP 4: ADD FEATURES
/// ============================================================================
///
/// Add a feature with Riverpod state management:
/// ```bash
/// flutter_engine_cli add --name user_profile --state riverpod --with-g-routes
/// ```
///
/// Add a feature with BLoC state management:
/// ```bash
/// flutter_engine_cli add --name product_catalog --state bloc --with-g-routes
/// ```
///
/// Add a basic feature without state management:
/// ```bash
/// flutter_engine_cli add --name settings --state none
/// ```
///
/// Interactive mode (no arguments):
/// ```bash
/// flutter_engine_cli add
/// ```
///
/// The CLI will prompt you:
/// ```
/// Enter the name of the feature in snake_case (e.g., "user_profile"): auth
/// Choose state management for this feature (riverpod/bloc/none) [none]: riverpod
/// Do you want to generate a route for this feature using go_router? (y/n) [n]: y
///
/// ✅ Feature "auth" added successfully!
/// ```

/// ============================================================================
/// STEP 5: IMPLEMENT YOUR FEATURE
/// ============================================================================
///
/// After adding a feature, you'll have this structure:
///
/// ```
/// lib/features/user_profile/
/// ├── data/
/// │   ├── datasources/
/// │   │   └── user_profile_remote_data_source.dart
/// │   ├── models/
/// │   │   └── user_profile_model.dart
/// │   └── repositories/
/// │       └── user_profile_repository_impl.dart
/// ├── domain/
/// │   ├── entities/
/// │   │   └── user_profile_entity.dart
/// │   ├── repositories/
/// │   │   └── user_profile_repository.dart
/// │   └── usecases/
/// │       └── get_user_profile_data.dart
/// └── presentation/
///     ├── pages/
///     │   └── user_profile_page.dart
///     ├── state/
///     │   └── user_profile_providers.dart (if Riverpod)
///     └── widgets/
/// ```

/// ============================================================================
/// EXAMPLE: IMPLEMENTING A USER PROFILE FEATURE
/// ============================================================================

// 1. Define Entity (lib/features/user_profile/domain/entities/user_profile_entity.dart)
/*
import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}
*/

// 2. Create Model (lib/features/user_profile/data/models/user_profile_model.dart)
/*
import 'package:my_awesome_app/features/user_profile/domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }
}
*/

// 3. Implement Data Source (lib/features/user_profile/data/datasources/user_profile_remote_data_source.dart)
/*
import 'package:my_awesome_app/core/error/exceptions.dart';
import 'package:my_awesome_app/core/network/api_client.dart';
import 'package:my_awesome_app/core/di/injector.dart' as di;
import 'package:my_awesome_app/features/user_profile/data/models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final ApiClient apiClient;

  UserProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final response = await apiClient.get('/users/$userId');
      return UserProfileModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch user profile: $e');
    }
  }
}
*/

// 4. Implement Repository (lib/features/user_profile/data/repositories/user_profile_repository_impl.dart)
/*
import 'package:dartz/dartz.dart';
import 'package:my_awesome_app/core/error/exceptions.dart';
import 'package:my_awesome_app/core/error/failures.dart';
import 'package:my_awesome_app/features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:my_awesome_app/features/user_profile/domain/entities/user_profile_entity.dart';
import 'package:my_awesome_app/features/user_profile/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile(String userId) async {
    try {
      final userProfile = await remoteDataSource.getUserProfile(userId);
      return Right(userProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure());
    }
  }
}
*/

// 5. Register Dependencies (lib/core/di/injector.dart)
/*
import 'package:get_it/get_it.dart';
import 'package:my_awesome_app/core/network/api_client.dart';
import 'package:my_awesome_app/features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:my_awesome_app/features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:my_awesome_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:my_awesome_app/features/user_profile/domain/usecases/get_user_profile_data.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Data Sources
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetUserProfileData(sl()));
}
*/

// 6. Create Riverpod Provider (lib/features/user_profile/presentation/state/user_profile_providers.dart)
/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_awesome_app/core/di/injector.dart' as di;
import 'package:my_awesome_app/features/user_profile/domain/usecases/get_user_profile_data.dart';

final getUserProfileDataUsecaseProvider = Provider((ref) {
  return GetUserProfileData(di.sl());
});

final userProfileDataProvider = FutureProvider.autoDispose.family<String, String>((ref, userId) async {
  final getUserProfileData = ref.watch(getUserProfileDataUsecaseProvider);
  final result = await getUserProfileData(userId);
  return result.fold(
    (failure) => throw Exception('Failed to fetch user profile'),
    (entity) => entity,
  );
});
*/

// 7. Use in Page (lib/features/user_profile/presentation/pages/user_profile_page.dart)
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_awesome_app/features/user_profile/presentation/state/user_profile_providers.dart';

class UserProfilePage extends ConsumerWidget {
  static const routeName = 'user_profile';
  final String userId;

  const UserProfilePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileDataProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: userProfileAsync.when(
        data: (user) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ${user.name}'),
              Text('Email: ${user.email}'),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
*/

/// ============================================================================
/// EXAMPLE: USING NETWORK LAYER
/// ============================================================================

// Using ApiClient for network requests
/*
import 'package:my_awesome_app/core/di/injector.dart' as di;
import 'package:my_awesome_app/core/network/api_client.dart';

final apiClient = di.sl<ApiClient>();

// GET request
final response = await apiClient.get('/users/123');

// POST request
final newUser = await apiClient.post('/users', data: {
  'name': 'John Doe',
  'email': 'john@example.com',
});
*/

/// ============================================================================
/// EXAMPLE: USING NAVIGATION (Go Router)
/// ============================================================================

// Navigate programmatically
/*
import 'package:go_router/go_router.dart';

// Navigate to a route
context.go('/user_profile?userId=123');

// Push a new route
context.push('/product_detail', extra: {'productId': '456'});

// Go back
context.pop();
*/

/// ============================================================================
/// EXAMPLE: USING LOCAL STORAGE (Hive)
/// ============================================================================

// Using Hive Storage
/*
import 'package:my_awesome_app/core/storage/hive_storage.dart';

final storage = HiveStorageServiceImpl();

// Save data
await storage.save<String>('user_token', 'abc123');

// Read data
final token = storage.read<String>('user_token');

// Delete data
await storage.delete('user_token');
*/

/// ============================================================================
/// EXAMPLE: USING RUST FFI (if enabled)
/// ============================================================================

// Initialize in main.dart
/*
import 'package:my_awesome_app/core/common/hybrid_parser.dart';
import 'package:my_awesome_app/core/common/image_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Rust FFI
  await HybridParser.initialize();
  await ImageService.getInstance();
  
  runApp(const MyApp());
}
*/

// Parse JSON using Rust FFI
/*
import 'package:my_awesome_app/core/common/hybrid_parser.dart';

final jsonString = '{"name": "John", "age": 30}';
final parser = HybridParser<UserModel, UserModel>(
  jsonString,
  (data) => UserModel.fromJson(data),
);

final user = await parser.parse();
*/

// Process images using Rust FFI
/*
import 'package:my_awesome_app/core/common/image_service.dart';

final imageService = await ImageService.getInstance();

final cachedPath = await imageService.processAndCache(
  imagePath: '/path/to/image.jpg',
  width: 800,
  height: 600,
  quality: 85,
);
*/

/// ============================================================================
/// COMPLETE WORKFLOW EXAMPLE
/// ============================================================================
///
/// 1. Create project: flutter create my_app && cd my_app
/// 2. Initialize: flutter_engine_cli init
///    - Choose Riverpod
///    - Add Dio, Go Router, Hive
/// 3. Install: flutter pub get
/// 4. Add feature: flutter_engine_cli add --name products --state riverpod --with-g-routes
/// 5. Implement business logic (entities, models, repositories, use cases)
/// 6. Register dependencies in injector.dart
/// 7. Create providers/state management
/// 8. Build UI pages
/// 9. Add routes to router.dart
/// 10. Test and iterate!

/// ============================================================================
/// TIPS AND BEST PRACTICES
/// ============================================================================
///
/// 1. Always register dependencies in lib/core/di/injector.dart
/// 2. Keep features independent - avoid direct imports between features
/// 3. Use dependency injection for cross-feature communication
/// 4. Handle errors properly with Either<Failure, Success> pattern
/// 5. Write tests for each layer (domain, data, presentation)
/// 6. Use meaningful names in snake_case for features
/// 7. Follow Clean Architecture principles
/// 8. Document complex features with README files

/// ============================================================================
/// COMMON COMMANDS REFERENCE
/// ============================================================================
///
/// Initialize project:
///   flutter_engine_cli init
///
/// Add feature (interactive):
///   flutter_engine_cli add
///
/// Add feature (with args):
///   flutter_engine_cli add --name feature_name --state riverpod --with-g-routes
///
/// Check version:
///   flutter_engine_cli --version
///
/// Get help:
///   flutter_engine_cli --help

/// ============================================================================
/// TROUBLESHOOTING
/// ============================================================================
///
/// Issue: "pubspec.yaml not found"
/// Solution: Run commands from Flutter project root directory
///
/// Issue: "Command failed with exit code"
/// Solution: Check Flutter installation with `flutter doctor`
///
/// Issue: "Feature name must be in snake_case"
/// Solution: Use underscores, e.g., `user_profile` not `user-profile`
///
/// Issue: Router conflicts
/// Solution: The CLI automatically handles route conflicts

/// ============================================================================
/// NEXT STEPS
/// ============================================================================
///
/// 1. Explore the generated code structure
/// 2. Customize templates to match your needs
/// 3. Add more features using `flutter_engine_cli add`
/// 4. Implement business logic in use cases
/// 5. Build your UI with state management
/// 6. Add tests for reliability
/// 7. Deploy your app!

/// ============================================================================
/// For more detailed examples, see:
/// - example/IMPLEMENTATION_GUIDE.md (if exists)
/// - example/code_snippets/ (if exists)
/// - Main README.md
/// ============================================================================

void main() {
  // This is a documentation/example file
  // Run the actual commands in your terminal to use Flutter Engine CLI
  print('Flutter Engine CLI Usage Examples');
  print('See comments above for detailed usage instructions.');
}
