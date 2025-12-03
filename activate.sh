#!/bin/bash

# Flutter Engine CLI Activation Script
# This script helps you activate the flutter_engine_cli CLI tool globally

echo "🚀 Flutter Engine CLI Activation Script"
echo "====================================="

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Error: Dart is not installed or not in PATH"
    echo "Please install Dart SDK first: https://dart.dev/get-dart"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter SDK first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Dart and Flutter are installed"

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if pubspec.yaml exists
if [ ! -f "$SCRIPT_DIR/pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found in $SCRIPT_DIR"
    echo "Please run this script from the flutter_engine_cli project root"
    exit 1
fi

echo "📦 Installing dependencies..."
cd "$SCRIPT_DIR"
dart pub get

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to install dependencies"
    exit 1
fi

echo "🔧 Activating flutter_engine_cli globally..."
dart pub global activate --source path .

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to activate flutter_engine_cli"
    exit 1
fi

echo ""
echo "🎉 Flutter Engine CLI activated successfully!"
echo ""
echo "You can now use the following commands:"
echo "  flutter_engine_cli init    - Initialize a new Flutter project with Clean Architecture"
echo "  flutter_engine_cli add     - Add a new feature to your project"
echo ""
echo "For more information, see the README.md file or run:"
echo "  flutter_engine_cli --help"
echo ""
echo "Happy coding! 🚀"
