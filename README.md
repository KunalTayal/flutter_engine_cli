# Flutter Scaffold 🚀

A powerful command-line tool to bootstrap and manage scalable, feature-first Flutter projects with Clean Architecture principles.

## 🎯 What is Flutter Scaffold?

Flutter Scaffold is a CLI tool that helps you create and maintain Flutter projects following Clean Architecture patterns. It automatically generates:

- **Clean Architecture folder structure** with proper separation of concerns
- **Feature-based organization** for scalable codebases
- **State management integration** (BLoC, Riverpod, or basic)
- **Network layer setup** with Dio
- **Navigation setup** with Go Router
- **Local storage** with Hive
- **Dependency injection** with GetIt
- **Error handling** and failure management
- **Theme and styling** infrastructure

## 📦 Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Install the CLI tool

#### Option 1: Install from pub.dev (Recommended)
```bash
dart pub global activate flutter_scaffold_cli
```

#### Option 2: Install from source
```bash
# Clone the repository
git clone <repository-url>
cd flutter_scaffold_cli

# Install dependencies
dart pub get

# Activate the tool globally
dart pub global activate --source path .
```

#### Option 3: Use the activation script
```bash
# Clone the repository
git clone <repository-url>
cd flutter_scaffold_cli

# Run the activation script
./activate.sh
```

## 🚀 Quick Start

### 1. Create a new Flutter project

```bash
flutter create my_awesome_app
cd my_awesome_app
```

### 2. Initialize with Flutter Scaffold

```bash
flutter_scaffold_cli init
```

The tool will guide you through an interactive setup process:

```
🚀 Initializing project "my_awesome_app" with Clean Architecture...

Select state management solution:
1. BLoC
2. Riverpod
3. None (use basic state management)

Enter your choice (1-3): 2

Do you want to add Dio for advanced network requests? (y/n): y
Do you want to add go_router for navigation? (y/n): y
Do you want to add Hive for local storage? (y/n): y

📦 Adding required dependencies...
✅ Created folder: lib/core/common
✅ Created folder: lib/core/common/widgets
✅ Created folder: lib/core/config
✅ Created folder: lib/core/constants
✅ Created folder: lib/core/di
✅ Created folder: lib/core/error
✅ Created folder: lib/core/network
✅ Created folder: lib/core/storage
✅ Created folder: lib/core/theme
✅ Created folder: lib/core/utils
✅ Created folder: lib/features

🏠 Adding initial "home" feature...

🎉 Project initialized successfully!
Run `flutter pub get` to install dependencies.
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Add new features

```bash
# Interactive mode - the tool will guide you through the setup
flutter_scaffold_cli add

# Or use command-line arguments
flutter_scaffold_cli add --name user_profile --state riverpod --with-g-routes
flutter_scaffold_cli add --name product_catalog --state bloc --with-g-routes
flutter_scaffold_cli add --name settings
```

## 🏗️ Architecture Overview

Flutter Scaffold follows Clean Architecture principles with a feature-first approach:

```
lib/
├── core/                           # Shared infrastructure
│   ├── common/                     # Common utilities and widgets
│   ├── config/                     # App configuration
│   ├── constants/                  # App constants
│   ├── di/                         # Dependency injection
│   ├── error/                      # Error handling
│   ├── network/                    # Network layer
│   ├── storage/                    # Local storage
│   ├── theme/                      # App theming
│   └── utils/                      # Utility functions
├── features/                       # Feature modules
│   ├── home/                       # Home feature
│   │   ├── data/                   # Data layer
│   │   │   ├── datasources/        # Remote/local data sources
│   │   │   ├── models/             # Data models
│   │   │   └── repositories/       # Repository implementations
│   │   ├── domain/                 # Domain layer
│   │   │   ├── entities/           # Business entities
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/           # Business logic
│   │   └── presentation/           # Presentation layer
│   │       ├── pages/              # UI pages
│   │       ├── state/              # State management
│   │       └── widgets/            # Feature-specific widgets
│   └── [other_features]/           # Other features
└── main.dart                       # App entry point
```

## 🎯 Interactive CLI Experience

Flutter Scaffold provides an intuitive interactive command-line interface that guides you through the setup process. Both commands support interactive prompts when arguments are not provided.

### Interactive Features:
- **Guided Setup**: Step-by-step prompts for configuration options
- **Input Validation**: Real-time validation with helpful error messages
- **Default Values**: Sensible defaults for quick setup
- **Flexible Usage**: Use command-line arguments for automation or interactive prompts for exploration

## 📋 Available Commands

### `flutter_scaffold_cli init`

Initializes a new Flutter project with Clean Architecture structure.

**Interactive Options:**
- **State Management**: Choose between BLoC, Riverpod, or basic state management
- **Network Layer**: Add Dio for HTTP requests
- **Navigation**: Add Go Router for navigation
- **Local Storage**: Add Hive for local data persistence

**What it creates:**
- Complete folder structure following Clean Architecture
- Core infrastructure files (DI, error handling, theming, etc.)
- Initial "home" feature
- Dependencies in `pubspec.yaml`
- Configured `main.dart`

### `flutter_scaffold_cli add`

Adds a new feature to your project with complete Clean Architecture structure. The command supports both interactive prompts and command-line arguments.

**Options:**
- `--name` or `-n`: Feature name in snake_case (optional - will prompt if not provided)
- `--state`: State management choice (`riverpod`, `bloc`, `none`)
- `--with-g-routes`: Generate Go Router routes for the feature

**Interactive Mode:**
If you don't provide arguments, the tool will guide you through an interactive setup:

```bash
flutter_scaffold_cli add
```

**Interactive Process:**
```
Enter the name of the feature in snake_case (e.g., "user_profile"): auth
Choose state management for this feature (riverpod/bloc/none) [none]: riverpod
Do you want to generate a route for this feature using go_router? (y/n) [n]: y

✅ Feature "auth" added successfully!
```

**Command-Line Examples:**
```bash
# Basic feature without state management
flutter_scaffold_cli add --name user_profile

# Feature with Riverpod state management
flutter_scaffold_cli add --name product_catalog --state riverpod

# Feature with BLoC state management and routing
flutter_scaffold_cli add --name checkout --state bloc --with-g-routes

# Interactive mode (no arguments)
flutter_scaffold_cli add
```

## 🎨 Generated Code Structure

### Core Infrastructure

#### Dependency Injection (`lib/core/di/injector.dart`)
```dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External Dependencies
  sl.registerLazySingleton<Dio>(() => Dio());
  
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClientImpl(dio: sl()));
  
  // Features
  // Register your feature dependencies here
}
```

#### Error Handling (`lib/core/error/failures.dart`)
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
  
  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
```

### Feature Structure

Each feature follows the same pattern:

#### Domain Layer
- **Entities**: Business objects
- **Repositories**: Abstract interfaces
- **Use Cases**: Business logic

#### Data Layer
- **Models**: Data transfer objects
- **Data Sources**: Remote/local data access
- **Repository Implementations**: Concrete implementations

#### Presentation Layer
- **Pages**: UI screens
- **State Management**: BLoC/Riverpod providers
- **Widgets**: Reusable UI components

## 🔧 Configuration Options

### State Management

#### Riverpod
- Uses `flutter_riverpod` package
- Generates provider files for each feature
- Integrates with dependency injection

#### BLoC
- Uses `flutter_bloc` and `bloc` packages
- Generates BLoC, Event, and State files
- Follows BLoC pattern conventions

#### Basic
- No additional state management
- Uses basic `setState` or `ChangeNotifier`

### Network Layer

When Dio is selected:
- Configures Dio client with interceptors
- Creates API client abstraction
- Sets up environment configuration
- Generates API endpoints structure

### Navigation

When Go Router is selected:
- Creates router configuration
- Generates route definitions
- Integrates with feature pages

### Local Storage

When Hive is selected:
- Configures Hive for local storage
- Creates storage service abstraction
- Sets up data persistence utilities

## 📦 Dependencies

The tool automatically adds these dependencies based on your choices:

### Core Dependencies
- `get_it`: Dependency injection
- `dartz`: Functional programming utilities
- `equatable`: Value equality
- `connectivity_plus`: Network connectivity

### State Management
- `flutter_riverpod`: Riverpod state management
- `flutter_bloc` & `bloc`: BLoC state management

### Network
- `dio`: HTTP client

### Navigation
- `go_router`: Declarative routing

### Storage
- `hive` & `hive_flutter`: Local storage

### Development Dependencies
- `hive_generator`: Hive code generation
- `build_runner`: Code generation runner

## 🚀 Best Practices

### Feature Development
1. **One feature per command**: Use `flutter_scaffold_cli add` for each feature
2. **Consistent naming**: Use snake_case for feature names
3. **State management**: Choose the same pattern across features for consistency
4. **Routing**: Use `--with-g-routes` for features that need navigation

### Code Organization
1. **Keep features independent**: Each feature should be self-contained
2. **Use dependency injection**: Register feature dependencies in the injector
3. **Follow naming conventions**: Use the generated naming patterns
4. **Extend generated code**: Build upon the scaffold, don't replace it

### Maintenance
1. **Update dependencies**: Regularly update Flutter and package versions
2. **Review generated code**: Customize templates as needed for your project
3. **Document features**: Add README files to complex features
4. **Test thoroughly**: Add unit and widget tests for each feature

## 🔍 Troubleshooting

### Common Issues

#### "pubspec.yaml not found"
- Ensure you're running commands from the Flutter project root
- Verify the project is a valid Flutter project

#### "Command failed with exit code"
- Check your Flutter installation: `flutter doctor`
- Verify internet connection for dependency downloads
- Try running `flutter pub get` manually

#### "Feature name must be in snake_case"
- Use underscores instead of hyphens or spaces
- Example: `user_profile` ✅, `user-profile` ❌

### Getting Help

1. Check the generated code structure
2. Review the template files in `lib/src/templates/`
3. Verify your Flutter and Dart versions
4. Check the project's `pubspec.yaml` for dependency conflicts

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆕 Version History

### v1.0.0
- Added comprehensive error handling
- Improved interactive prompts
- Enhanced template generation
- Added support for multiple state management options

### v1.0.0
- Initial release
- Basic init and add feature commands
- Clean Architecture template generation
- State management integration

---

**Happy coding! 🎉**

Built with ❤️ for the Flutter community.
