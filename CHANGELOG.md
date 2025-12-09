# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-01-15

### Added
- Initial release of Flutter Engine CLI
- **Core Commands:**
  - `init` command for project initialization with Clean Architecture
  - `add` command for creating new features with interactive prompts
- **Interactive CLI Experience:**
  - Guided setup process for project initialization
  - Interactive feature addition with step-by-step prompts
  - Input validation with helpful error messages
  - Flexible usage: command-line arguments or interactive prompts
- **State Management Support:**
  - BLoC pattern integration with `flutter_bloc` and `bloc`
  - Riverpod integration with `flutter_riverpod`
  - Basic state management option (no additional dependencies)
- **Architecture & Infrastructure:**
  - Clean Architecture folder structure with feature-first approach
  - Dependency injection setup with GetIt
  - Comprehensive error handling and failure management
  - Theme and styling infrastructure
  - Core utilities and common widgets structure
- **Network & Data:**
  - Network layer integration with Dio (optional)
  - Local storage integration with Hive (optional)
  - API client abstraction and configuration
  - Environment configuration support
- **Navigation:**
  - Go Router integration for declarative routing (optional)
  - Automatic route generation for features
- **Rust FFI Integration (Optional):**
  - High-performance JSON processing with Rust backend
  - Image processing (resize, compress, cache) with Rust
  - Hybrid parser using Dart isolates for non-blocking operations
  - Complete Rust project structure with Cargo.toml
  - Cross-platform build scripts (Windows, macOS, Linux)
  - Comprehensive Rust FFI documentation and quick start guides
- **Template Generation:**
  - Core infrastructure templates (DI, error handling, theming)
  - Feature templates (domain, data, presentation layers)
  - State management templates (BLoC, Riverpod)
  - Rust FFI templates and bindings
- **Utilities:**
  - Automatic dependency management
  - File and folder creation utilities
  - String casing utilities (PascalCase, camelCase, snake_case)
  - Project name detection from pubspec.yaml
  - Cross-platform Flutter executable detection

### Changed
- Improved command-line interface with better user experience
- Enhanced interactive CLI with guided prompts for feature addition
- Enhanced template generation with more comprehensive code structure
- Better error messages and validation
- Made feature name optional in add command with interactive fallback

### Fixed
- Project name detection from pubspec.yaml
- Command execution error handling
- File creation and folder structure generation
- Cross-platform compatibility for build scripts
