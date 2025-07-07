import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tint/tint.dart';

class FileUtils {
  // static Future<String> getFlutterProjectName() async {
  //   final pubspecFile = File('pubspec.yaml');
  //   if (!await pubspecFile.exists()) {
  //     throw 'Error: pubspec.yaml not found. Please run this command from the root of your Flutter project.';
  //   }

  //   final content = await pubspecFile.readAsString();
  //   final match = RegExp(r'^name:\s*(.*)$', multiLine: true).firstMatch(content);

  //   if (match == null || match.group(1) == null) {
  //     throw 'Error: Could not find the project name in pubspec.yaml.';
  //   }
  //   return match.group(1)!.trim();
  // }

  // static String getFlutterProjectName() {
  //   // final pubspecFile = File('pubspec.yaml');

  //   // Primary strategy: Read from pubspec.yaml
  //   // if (pubspecFile.existsSync()) {
  //   //   final lines = pubspecFile.readAsLinesSync();
  //   //   final nameLine = lines.firstWhere(
  //   //     (line) => line.startsWith('name:'),
  //   //     orElse: () => '', // Return empty string if not found
  //   //   );
  //   //   if (nameLine.isNotEmpty) {
  //   //     return nameLine.split(':')[1].trim();
  //   //   }
  //   // }

  //   // Fallback strategy: Use the current directory's name
  //   print(
  //       'Warning: Could not find project name in pubspec.yaml. Falling back to directory name.'
  //           .yellow());
  //   final directoryName = p.basename(Directory.current.path);

  //   // Sanitize the directory name to be a valid Dart package name
  //   // (replaces hyphens and other invalid characters with underscores)
  //   return directoryName
  //       .replaceAll('-', '_')
  //       .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  // }

  static String getFlutterProjectName() {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) return 'my_awesome_app';
    final lines = pubspec.readAsLinesSync();
    final nameLine = lines.firstWhere(
      (line) => line.startsWith('name:'),
      orElse: () => 'name: my_awesome_app',
    );
    return nameLine.split(':')[1].trim();
  }

  static Future<void> createFolder(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('✅ Created folder: $path');
    }
  }

  static Future<void> createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
    print('✅ Created file:   $path');
  }

  static Future<void> runCommand(String command, List<String> args,
      {String? workingDir}) async {
    print('\n\$ $command ${args.join(' ')}');
    final result =
        await Process.run(command, args, workingDirectory: workingDir);
    if (result.stdout.toString().isNotEmpty) print(result.stdout);
    if (result.stderr.toString().isNotEmpty) print(result.stderr);
    if (result.exitCode != 0) {
      throw 'Command failed with exit code ${result.exitCode}';
    }
  }
}

extension StringCasingExtension on String {
  String toPascalCase() {
    if (isEmpty) return '';
    return split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join('');
  }

  String toCamelCase() {
    if (isEmpty) return '';
    final pascal = toPascalCase();
    return pascal[0].toLowerCase() + pascal.substring(1);
  }
}
