// lib/src/templates/core_templates.dart

class CoreTemplates {
  static String mainDart(
          bool withRiverpod, bool withGoRouter, String projectName) =>
      '''
import 'package:flutter/material.dart';
import 'package:$projectName/core/config/environment_config.dart';
import 'package:$projectName/core/theme/app_theme.dart';
${withRiverpod ? "import 'package:flutter_riverpod/flutter_riverpod.dart';" : ""}
import 'package:$projectName/core/di/injector.dart' as di;
${withGoRouter ? "import 'package:$projectName/core/config/router.dart';" : "import 'package:$projectName/features/home/presentation/pages/home_page.dart';"}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Configuration
  EnvironmentConfig.initialize();

  // Initialize Dependency Injection
  await di.init();
  runApp(${withRiverpod ? 'const ProviderScope(child: MyApp())' : 'const MyApp()'});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp${withGoRouter ? '.router' : ''}(
      title: EnvironmentConfig.appTitle, // Use title from config
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      ${withGoRouter ? 'routerConfig: router,' : 'home: const HomePage(),'}
    );
  }
}
''';

  static String injector(bool withDio, bool withGoRouter, String projectName) =>
      '''
import 'package:get_it/get_it.dart';
${withDio ? "import 'package:dio/dio.dart';" : ""}
${withDio ? "import 'package:$projectName/core/network/api_client.dart';" : ""}
${withGoRouter ? "import 'package:go_router/go_router.dart';" : ""}
${withGoRouter ? "import 'package:$projectName/core/config/router.dart';" : ""}

final sl = GetIt.instance;

Future<void> init() async {
  // External Dependencies
  ${withDio ? "sl.registerLazySingleton<Dio>(() => Dio());" : ""}

  // Core
  ${withDio ? "sl.registerLazySingleton<ApiClient>(() => ApiClientImpl(dio: sl()));" : ""}

  // Features
  // Register your feature dependencies here

  // External
  ${withGoRouter ? "sl.registerLazySingleton(() => GoRouter(routes: router.configuration.routes,),);" : ""}
}
''';

  static const String failures = '''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
  
  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
''';

  static const String isolateParser = '''
import 'dart:convert';
import 'package:flutter/foundation.dart';

// T is the type of the model (e.g., UserModel)
// R is the return type (e.g., UserModel or List<UserModel>)
typedef ParseFunction<T, R> = R Function(dynamic);

class IsolateParser<T, R> {
  final String json;
  final ParseFunction<T, R> parseFunction;

  IsolateParser(this.json, this.parseFunction);

  Future<R> parse() async {
    return await compute(_parseJson, this);
  }

  static R _parseJson<T, R>(IsolateParser<T, R> parser) {
    final decoded = jsonDecode(parser.json);
    return parser.parseFunction(decoded);
  }
}
''';

  static String router(String projectName) => '''
import 'package:go_router/go_router.dart';
import 'package:$projectName/features/home/presentation/pages/home_page.dart';

// TODO: Add other feature route imports here

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomePage.routeName,
      builder: (context, state) => const HomePage(),
    ),
    // TODO: Add other feature routes here
    // Example:
    // GoRoute(
    //   path: '/user_profile',
    //   name: UserProfilePage.routeName,
    //   builder: (context, state) => const UserProfilePage(),
    // ),
  ],
);
''';

// In lib/src/templates.dart

  static const String apiClientTemplate = """
import 'package:dio/dio.dart';
import '../error/exceptions.dart';

/// An abstract class defining the contract for an API client.
/// This allows for dependency inversion, making it easy to swap out
/// the implementation (e.g., for a mock client in tests).
abstract class ApiClient {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});
  Future<dynamic> post(String path, {dynamic data});
  Future<dynamic> put(String path, {dynamic data});
  Future<dynamic> delete(String path);
}

/// The concrete implementation of [ApiClient] using the Dio package.
class ApiClientImpl implements ApiClient {
  final Dio dio;

  ApiClientImpl({required this.dio}) {
    // --- Dio Configuration ---
    // It's recommended to set up the base URL and other options here.
    // You can also add interceptors for logging, authentication, etc.

    // Base URL for all API requests
    dio.options.baseUrl = 'https://api.example.com/v1'; // <-- TODO: CHANGE THIS!

    // Default headers
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';

    // Timeouts
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    // Example of adding an interceptor for logging
    // dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    // Example of adding an interceptor for adding an Auth token to headers
    /*
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: Get your token from a secure storage
          // final String? token = await secureStorage.read(key: 'auth_token');
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer \$token';
          // }
          return handler.next(options); // Continue
        },
      ),
    );
    */
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _handleRequest(() => dio.get(path, queryParameters: queryParameters));
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    return _handleRequest(() => dio.post(path, data: data));
  }

  @override
  Future<dynamic> put(String path, {dynamic data}) async {
    return _handleRequest(() => dio.put(path, data: data));
  }

  @override
  Future<dynamic> delete(String path) async {
    return _handleRequest(() => dio.delete(path));
  }

  /// A helper method to wrap Dio calls with common error handling.
  /// It catches [DioException] and re-throws a more specific [ServerException] or [NetworkException].
  Future<dynamic> _handleRequest(Future<Response> Function() request) async {
    try {
      final response = await request();
      // Dio considers responses with status codes 2xx as successful.
      // The actual response data is returned directly.
      return response.data;
    } on DioException catch (e) {
      // Handle different types of Dio errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Network-related errors
        throw NetworkException(message: 'Network error: \${e.message}');
      } else if (e.response != null) {
        // The server responded with a non-2xx status code.
        throw ServerException(
          statusCode: e.response?.statusCode,
          message: e.response?.data?['message'] ?? e.message,
        );
      } else {
        // Something else happened while setting up or sending the request
        throw ServerException(message: 'An unexpected error occurred: \${e.message}');
      }
    } catch (e) {
      // Catch any other unexpected errors
      throw ServerException(message: 'An unknown error occurred: \$e');
    }
  }
}
""";

// In lib/src/templates.dart

  static const String exceptionsTemplate = """
/// Represents exceptions that occur on the server side, such as a 500 Internal Server Error,
/// a 404 Not Found, or a 401 Unauthorized.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException(message: \$message, statusCode: \$statusCode)';
}

/// Represents exceptions that occur when there is no internet connection
/// or the device is offline.
class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'No Internet Connection. Please check your network.'});

  @override
  String toString() => message;
}


/// Represents exceptions that occur when trying to access or save data
/// to the local cache (e.g., SharedPreferences, Hive).
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'A cache error occurred.'});

  @override
  String toString() => message;
}
""";

// In lib/src/templates.dart, add this new template string.

  static const String hiveStorage = """
import 'package:hive_flutter/hive_flutter.dart';
import '../error/exceptions.dart';

// --- A NOTE FOR THE USER ---
// To use this service, you must:
// 1. Add `hive` and `hive_flutter` to your pubspec.yaml.
// 2. Add `path_provider` for finding the right directory on the device.
// 3. Initialize Hive in your `main.dart` function BEFORE runApp():
//    ```
//    await Hive.initFlutter();
//    await StorageService.init(); // Initialize our service
//    ```
// 4. Register this service with your dependency injection system (e.g., GetIt).

/// The name of the main box used for storing general app data.
const String kMainBox = 'main_box';

/// An abstract interface for a simple key-value storage service.
/// This allows for easy mocking in tests and swapping out the implementation
/// if you ever decide to move away from Hive.
abstract class StorageService {
  /// Initializes the storage service. This MUST be called before any other method.
  static Future<void> init() async {
    // This is a static method so we can initialize the service from main.dart
    // without needing an instance.
    try {
      await Hive.openBox(kMainBox);
    } catch (e) {
      // Handle initialization errors, e.g., if Hive can't access the file system.
      // This is a critical error, so rethrowing or logging is important.
      throw CacheException(message: 'Failed to initialize Hive storage: \$e');
    }
  }

  /// Reads a value from storage by its key.
  /// Returns `null` if the key does not exist.
  /// The type [T] is the expected type of the value.
  T? read<T>(String key);

  /// Saves a value to storage with the given key.
  /// This will overwrite any existing value for the same key.
  Future<void> save<T>(String key, T value);

  /// Deletes a value from storage by its key.
  Future<void> delete(String key);

  /// Clears all data from the storage box. Use with caution.
  Future<void> clear();
}

/// A concrete implementation of [StorageService] using Hive.
class HiveStorageServiceImpl implements StorageService {
  // Get the opened box instance.
  // Throws an error if the box hasn't been opened via `StorageService.init()`.
  final Box _box = Hive.box(kMainBox);

  @override
  T? read<T>(String key) {
    try {
      return _box.get(key) as T?;
    } catch (e) {
      // Handle potential type cast errors or other issues.
      throw CacheException(message: 'Failed to read from cache for key "\$key": \$e');
    }
  }

  @override
  Future<void> save<T>(String key, T value) async {
    try {
      await _box.put(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to save to cache for key "\$key": \$e');
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _box.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete from cache for key "\$key": \$e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: \$e');
    }
  }
}
""";

static const String environmentConfigTemplate = """
import 'package:flutter/foundation.dart';

/// A class to manage environment-specific configurations.
///
/// This setup allows for different settings for development, staging, and production builds
/// by using the '--dart-define' flag during the build process.
///
/// Example:
/// flutter run --dart-define=ENVIRONMENT=prod
enum Environment { dev, staging, prod }

class EnvironmentConfig {
  EnvironmentConfig._();

  static late final Environment environment;

  /// Initializes the environment configuration.
  /// This should be called once in `main.dart` before the app runs.
  static void initialize() {
    const envString = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    environment = Environment.values.firstWhere(
      (e) => e.toString().split('.').last == envString,
      orElse: () => Environment.dev,
    );
  }

  static String get appTitle {
    switch (environment) {
      case Environment.prod:
        return 'My App';
      case Environment.staging:
        return '[STG] My App';
      case Environment.dev:
      default:
        return '[DEV] My App';
    }
  }

  static String get baseUrl {
    switch (environment) {
      case Environment.prod:
        return 'https://api.myapp.com/v1';
      case Environment.staging:
        return 'https://stg.api.myapp.com/v1';
      case Environment.dev:
      default:
        return 'https://dev.api.myapp.com/v1';
    }
  }
}
""";

static String apiEndpointsTemplate(String projectName) => """
import 'package:$projectName/core/config/environment_config.dart';

/// A class containing all API endpoint constants.
class ApiEndpoints {
  ApiEndpoints._();

  static final String _baseUrl = EnvironmentConfig.baseUrl;

  // --- Auth ---
  static String get login => '\$_baseUrl/auth/login';
  static String get register => '\$_baseUrl/auth/register';

  // --- User ---
  static String get fetchProfile => '\$_baseUrl/user/profile';
  static String updateUser(String userId) => '\$_baseUrl/user/\$userId';
}
""";

// --- Constants ---

static const String appColorsTemplate = """
import 'package:flutter/material.dart';

/// A class containing color constants for the app.
class AppColors {
  AppColors._();

  // --- Main Colors ---
  static const Color primary = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFFF57C00);
  static const Color accent = Color(0xFFFFC107);
  
  // --- Background Colors ---
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF212121);
  
  // --- Text Colors ---
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // --- Other ---
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
}
""";

static const String appStringsTemplate = """
/// A class containing string constants for the app.
class AppStrings {
  AppStrings._();

  static const String appName = "My Awesome App";

  // --- Generic ---
  static const String ok = "OK";
  static const String cancel = "Cancel";
  static const String errorTitle = "Error";
  static const String genericError = "Something went wrong. Please try again.";

  // --- Auth ---
  static const String login = "Login";
  static const String welcome = "Welcome back!";
}
""";

static const String appAssetsTemplate = """
/// A class containing constants for asset paths.
///
/// To use these assets, make sure to declare them in pubspec.yaml:
///
/// flutter:
///   assets:
///     - assets/images/
///     - assets/icons/
class AppAssets {
  AppAssets._();

  // --- Base Paths ---
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';

  // --- Images ---
  // Example: static const String logo = '\$_imagesPath/logo.png';
  
  // --- Icons ---
  // Example: static const String googleIcon = '\$_iconsPath/google.svg';
}
""";

static const String appTextStylesTemplate = """
import 'package:flutter/material.dart';

/// A class containing text style constants for the app.
/// These styles are baseline and can be modified by the AppTheme.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}
""";

// --- Theme ---

static String appThemeTemplate(String projectName) => """
import 'package:flutter/material.dart';
import 'package:$projectName/core/constants/app_colors.dart';
import 'package:$projectName/core/constants/app_text_styles.dart';

/// The central theme configuration for the app.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Poppins', // Make sure to add this font to pubspec.yaml
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.backgroundLight,
      ),
      appBarTheme: AppBarTheme(
        color: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTextStyles.headline2.copyWith(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textPrimaryLight),
        displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.textPrimaryLight),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryLight),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.backgroundDark,
      ),
      appBarTheme: AppBarTheme(
        color: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTextStyles.headline2.copyWith(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryDark),
      ),
    );
  }
}
""";
}
