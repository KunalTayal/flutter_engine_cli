# Flutter Scaffold Usage Examples

This document provides practical examples of how to use the flutter_scaffold_cli CLI tool.

## 🎯 Interactive CLI Experience

Flutter Scaffold provides an intuitive interactive command-line interface that makes it easy to set up projects and add features without remembering all the command-line arguments.

### Interactive Features:
- **Guided Prompts**: Step-by-step questions for configuration
- **Input Validation**: Real-time validation with helpful error messages
- **Default Values**: Sensible defaults for quick setup
- **Flexible Usage**: Use arguments for automation or interactive mode for exploration

### When to Use Interactive Mode:
- **Learning**: When you're new to the tool
- **Exploration**: When you want to see all available options
- **Quick Setup**: When you want to use sensible defaults
- **Development**: When you're experimenting with different configurations

### When to Use Command-Line Arguments:
- **Automation**: In scripts and CI/CD pipelines
- **Repetition**: When you know exactly what you want
- **Documentation**: When creating tutorials or guides
- **Team Standards**: When enforcing consistent configurations

## 🚀 Quick Start Example

### 1. Create a new Flutter project

```bash
flutter create my_ecommerce_app
cd my_ecommerce_app
```

### 2. Initialize with Flutter Scaffold

```bash
flutter_scaffold_cli init
```

**Interactive Setup Process:**
```
🚀 Initializing project "my_ecommerce_app" with Clean Architecture...

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

### 4. Add features to your app

```bash
# Interactive mode - the tool will guide you through the setup
flutter_scaffold_cli add

# Or use command-line arguments
flutter_scaffold_cli add --name auth --state riverpod --with-g-routes
flutter_scaffold_cli add --name products --state bloc --with-g-routes
flutter_scaffold_cli add --name cart --state riverpod --with-g-routes
flutter_scaffold_cli add --name profile
```

**Interactive Process Example:**
```
Enter the name of the feature in snake_case (e.g., "user_profile"): auth
Choose state management for this feature (riverpod/bloc/none) [none]: riverpod
Do you want to generate a route for this feature using go_router? (y/n) [n]: y

✅ Feature "auth" added successfully!
```

## 📱 E-commerce App Example

Let's build a complete e-commerce app structure:

### Project Structure After Initialization

```
my_ecommerce_app/
├── lib/
│   ├── core/
│   │   ├── common/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── di/
│   │   ├── error/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   └── home/
│   └── main.dart
└── pubspec.yaml
```

### Adding Features

#### 1. Authentication Feature

```bash
flutter_scaffold_cli add --name auth --state riverpod --with-g-routes
```

**Generated Structure:**
```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_data_source.dart
│   ├── models/
│   │   └── auth_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── auth_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── get_auth_data.dart
└── presentation/
    ├── pages/
    │   └── auth_page.dart
    ├── state/
    │   └── auth_providers.dart
    └── widgets/
```

#### 2. Product Catalog Feature

```bash
flutter_scaffold_cli add --name products --state bloc --with-g-routes
```

**Generated Structure:**
```
lib/features/products/
├── data/
│   ├── datasources/
│   │   └── products_remote_data_source.dart
│   ├── models/
│   │   └── products_model.dart
│   └── repositories/
│       └── products_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── products_entity.dart
│   ├── repositories/
│   │   └── products_repository.dart
│   └── usecases/
│       └── get_products_data.dart
└── presentation/
    ├── pages/
    │   └── products_page.dart
    ├── state/
    │   ├── products_bloc.dart
    │   ├── products_event.dart
    │   └── products_state.dart
    └── widgets/
```

#### 3. Shopping Cart Feature

```bash
flutter_scaffold_cli add --name cart --state riverpod --with-g-routes
```

#### 4. User Profile Feature

```bash
flutter_scaffold_cli add --name profile
```

### Final Project Structure

```
my_ecommerce_app/
├── lib/
│   ├── core/
│   │   ├── common/
│   │   ├── config/
│   │   │   ├── environment_config.dart
│   │   │   ├── api_endpoints.dart
│   │   │   └── router.dart
│   │   ├── constants/
│   │   ├── di/
│   │   │   └── injector.dart
│   │   ├── error/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   └── api_client.dart
│   │   ├── storage/
│   │   │   └── hive_storage.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   ├── features/
│   │   ├── home/
│   │   ├── auth/
│   │   ├── products/
│   │   ├── cart/
│   │   └── profile/
│   └── main.dart
└── pubspec.yaml
```

## 🏗️ Generated Code Examples

### 1. Entity (Domain Layer)

```dart
// lib/features/products/domain/entities/products_entity.dart
import 'package:equatable/equatable.dart';

class ProductsEntity extends Equatable {
  final String message;

  const ProductsEntity({required this.message});

  @override
  List<Object?> get props => [message];
}
```

### 2. Repository Interface (Domain Layer)

```dart
// lib/features/products/domain/repositories/products_repository.dart
import 'package:dartz/dartz.dart';
import 'package:my_ecommerce_app/core/error/failures.dart';
import 'package:my_ecommerce_app/features/products/domain/entities/products_entity.dart';

abstract class ProductsRepository {
  Future<Either<Failure, ProductsEntity>> getProductsData();
}
```

### 3. Riverpod Provider (Presentation Layer)

```dart
// lib/features/products/presentation/state/products_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_ecommerce_app/features/products/domain/usecases/get_products_data.dart';

final productsUseCaseProvider = Provider<GetProductsData>((ref) {
  // Inject dependencies here
  return GetProductsData();
});

final productsProvider = FutureProvider<ProductsEntity>((ref) async {
  final useCase = ref.read(productsUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception('Failed to load products'),
    (products) => products,
  );
});
```

### 4. BLoC Implementation (Presentation Layer)

```dart
// lib/features/products/presentation/state/products_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_ecommerce_app/features/products/domain/usecases/get_products_data.dart';
import 'package:my_ecommerce_app/features/products/presentation/state/products_event.dart';
import 'package:my_ecommerce_app/features/products/presentation/state/products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsData getProductsData;

  ProductsBloc({required this.getProductsData}) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    final result = await getProductsData();
    emit(result.fold(
      (failure) => ProductsError(message: 'Failed to load products'),
      (products) => ProductsLoaded(products: products),
    ));
  }
}
```

## 🔧 Customization Examples

### 1. Adding Custom Dependencies

After running `flutter_scaffold_cli init`, you can add additional dependencies:

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  # Generated by flutter_scaffold_cli
  get_it: ^7.6.0
  dartz: ^0.10.1
  equatable: ^2.0.5
  flutter_riverpod: ^2.4.9
  dio: ^5.3.2
  go_router: ^12.1.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^5.0.2
  
  # Additional dependencies
  cached_network_image: ^3.3.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
```

### 2. Customizing Templates

You can modify the generated templates in `lib/src/templates/` to match your project's conventions:

- `core_templates.dart`: Core infrastructure templates
- `feature_templates.dart`: Feature-specific templates

### 3. Adding Custom Core Utilities

Extend the core utilities with your own implementations:

```dart
// lib/core/utils/date_utils.dart
class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// lib/core/utils/validation_utils.dart
class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

## 🧪 Testing Examples

### 1. Unit Tests for Use Cases

```dart
// test/features/products/domain/usecases/get_products_data_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:my_ecommerce_app/features/products/domain/usecases/get_products_data.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late GetProductsData useCase;
  late MockProductsRepository mockRepository;

  setUp(() {
    mockRepository = MockProductsRepository();
    useCase = GetProductsData(mockRepository);
  });

  test('should get products data from repository', () async {
    // Arrange
    final products = ProductsEntity(message: 'Test products');
    when(mockRepository.getProductsData())
        .thenAnswer((_) async => Right(products));

    // Act
    final result = await useCase();

    // Assert
    expect(result, Right(products));
    verify(mockRepository.getProductsData());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### 2. Widget Tests for Pages

```dart
// test/features/products/presentation/pages/products_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_ecommerce_app/features/products/presentation/pages/products_page.dart';

void main() {
  testWidgets('ProductsPage should display products', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProductsPage()));
    
    expect(find.text('Products'), findsOneWidget);
  });
}
```

## 🚀 Deployment Ready

After using flutter_scaffold_cli, your project is ready for:

1. **Development**: Start building features immediately
2. **Testing**: Add unit, widget, and integration tests
3. **CI/CD**: Integrate with GitHub Actions, GitLab CI, etc.
4. **Deployment**: Deploy to App Store, Google Play, or web

## 📚 Next Steps

1. **Read the generated code**: Understand the structure and patterns
2. **Customize templates**: Modify templates to match your team's conventions
3. **Add tests**: Implement comprehensive testing strategy
4. **Document features**: Add README files for complex features
5. **Set up CI/CD**: Configure automated testing and deployment

---

**Happy coding with Flutter Scaffold! 🎉**
