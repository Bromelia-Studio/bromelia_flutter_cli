import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import 'package:archive/archive_io.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

// Custom exception for project creation errors
class ProjectCreationException implements Exception {
  final String message;
  final String suggestion;

  ProjectCreationException(this.message, this.suggestion);

  @override
  String toString() => message;
}

// ANSI color codes for terminal output
class Colors {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String cyan = '\x1B[36m';
  static const String bold = '\x1B[1m';
}

// Logger class for consistent output formatting
class Logger {
  static void info(String message) {
    print('${Colors.blue}ℹ${Colors.reset} $message');
  }

  static void success(String message) {
    print('${Colors.green}✓${Colors.reset} $message');
  }

  static void error(String message) {
    print('${Colors.red}✕${Colors.reset} $message');
  }

  static void warning(String message) {
    print('${Colors.yellow}⚠${Colors.reset} $message');
  }

  static void step(String message) {
    print('${Colors.cyan}→${Colors.reset} $message');
  }

  static void progress(String message) {
    stdout.write('${Colors.cyan}⠋${Colors.reset} $message...');
  }

  static void progressDone() {
    stdout.write('\r${Colors.green}⚠${Colors.reset}');
    print('');
  }

  static void progressError() {
    stdout.write('\r${Colors.red}✕${Colors.reset}');
    print('');
  }
}

// Progress indicator for long-running operations
class ProgressIndicator {
  static const List<String> _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  Timer? _timer;
  int _frameIndex = 0;
  String _message = '';

  void start(String message) {
    _message = message;
    _timer = Timer.periodic(Duration(milliseconds: 80), (timer) {
      stdout.write('\r${Colors.cyan}${_frames[_frameIndex]}${Colors.reset} $_message...');
      _frameIndex = (_frameIndex + 1) % _frames.length;
    });
  }

  void stop({bool success = true}) {
    _timer?.cancel();
    if (success) {
      stdout.write('\r${Colors.green}✓${Colors.reset} $_message\n');
    } else {
      stdout.write('\r${Colors.red}✕${Colors.reset} $_message failed\n');
    }
  }
}

// Template processor class
class TemplateProcessor {
  final String projectName;
  final String organization;
  final List<String> platforms;

  TemplateProcessor({
    required this.projectName,
    required this.organization,
    required this.platforms,
  });

  Future<bool> processTemplate(String destinationPath) async {
    final destinationDir = Directory(destinationPath);
    final progress = ProgressIndicator();

    try {
      if (await destinationDir.exists()) {
        Logger.error('Destination directory already exists: $destinationPath');
        return false;
      }

      progress.start('Creating Flutter project');

      // Step 1: Check Flutter installation
      await _checkFlutterInstallation();

      // Step 2: Generate Flutter files
      await destinationDir.create(recursive: true);
      await _executeFlutterCreate(destinationDir);

      // Step 3: Resolve template zip path and copy files
      final zipPath = await _resolveTemplateZipPath();
      final unzippedTemplateDir = await unzipTemplate(zipPath);
      await _copyEssentialFiles(unzippedTemplateDir, destinationDir);

      // Step 4: Apply template customizations
      await _applyTemplateCustomizations(destinationDir);

      // Step 5: Execute flutter pub get
      await _executeFlutterPubGet(destinationDir);

      // Step 6: Execute dart run build_runner build -d
      // await _executeBuildRunner(destinationDir);

      progress.stop();
      return true;
    } catch (e) {
      progress.stop(success: false);
      Logger.error('Failed to create project: ${e.toString()}');

      // Clean up on failure
      await _cleanupOnFailure(destinationDir);
      return false;
    }
  }

  Future<String> _resolveTemplateZipPath() async {
    // Use Isolate.resolvePackageUri to resolve package URI
    final templateUri = Uri.parse('package:bromelia_cli/template/flutter_app.zip');

    final resolvedUri = await Isolate.resolvePackageUri(templateUri);

    if (resolvedUri == null) {
      throw Exception('Failed to resolve template URI: $templateUri');
    }

    final templatePath = resolvedUri.toFilePath();

    if (!await File(templatePath).exists()) {
      throw Exception('Template file not found at: $templatePath');
    }

    return templatePath;
  }

  Future<void> _checkFlutterInstallation() async {
    try {
      final result = await Process.run('flutter', ['--version'], runInShell: true);

      if (result.exitCode != 0) {
        throw ProjectCreationException(
          'Flutter not found in PATH',
          'Please install Flutter and ensure it\'s in your PATH.\nVisit: https://flutter.dev/docs/get-started/install',
        );
      }
    } catch (e) {
      if (e is ProjectCreationException) rethrow;
      throw ProjectCreationException(
        'Flutter CLI not accessible',
        'Please install Flutter and ensure it\'s in your PATH.\nVisit: https://flutter.dev/docs/get-started/install',
      );
    }
  }

  Future<void> _executeFlutterCreate(Directory projectDir) async {
    try {
      final flutterArgs = [
        'create',
        '--org=$organization',
        '--project-name=$projectName',
        ...platforms.map((p) => '--platforms=$p'),
        '.',
        '-e',
      ];

      final result = await Process.run(
        'flutter',
        flutterArgs,
        workingDirectory: projectDir.path,
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw ProjectCreationException(
          'Flutter create command failed',
          'Try running: flutter create --help\nEnsure project name is valid and Flutter is properly installed.\nError: ${result.stderr}',
        );
      }
    } catch (e) {
      if (e is ProjectCreationException) rethrow;
      throw ProjectCreationException('Failed to execute flutter create', 'Ensure Flutter is properly installed and accessible.\nTry running: flutter doctor');
    }
  }

  Future<void> _executeFlutterPubGet(Directory projectDir) async {
    try {
      final result = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: projectDir.path,
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw ProjectCreationException(
          'Flutter pub get failed',
          'Check your pubspec.yaml for dependency conflicts.\nTry running: flutter pub deps\nError: ${result.stderr}',
        );
      }
    } catch (e) {
      if (e is ProjectCreationException) rethrow;
      throw ProjectCreationException(
        'Failed to run flutter pub get',
        'Check your internet connection and pubspec.yaml dependencies.\nTry running: flutter pub get manually',
      );
    }
  }

  // ignore: unused_element
  Future<void> _executeBuildRunner(Directory projectDir) async {
    try {
      // Check if build_runner is in dependencies
      final pubspecFile = File(path.join(projectDir.path, 'pubspec.yaml'));
      if (await pubspecFile.exists()) {
        final pubspecContent = await pubspecFile.readAsString();
        if (!pubspecContent.contains('build_runner:')) {
          // Skip build_runner if not in dependencies
          return;
        }
      }

      final result = await Process.run(
        'dart',
        ['run', 'build_runner', 'build', '-d'],
        workingDirectory: projectDir.path,
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw ProjectCreationException(
          'Build runner execution failed',
          'Ensure build_runner is properly configured in pubspec.yaml.\nTry running: dart run build_runner clean first\nError: ${result.stderr}',
        );
      }
    } catch (e) {
      if (e is ProjectCreationException) rethrow;
      throw ProjectCreationException(
        'Failed to run build_runner',
        'Check if build_runner is properly configured.\nTry running: dart run build_runner build --help',
      );
    }
  }

  Future<void> _cleanupOnFailure(Directory projectDir) async {
    try {
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
        Logger.info('Cleaned up incomplete project files');
      }
    } catch (e) {
      Logger.warning('Could not clean up project files: ${projectDir.path}');
    }
  }

  Future<Directory> unzipTemplate(String zipPath) async {
    final tempDir = await Directory.systemTemp.createTemp('bromelia_template_');

    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      // Skip __MACOSX files
      if (file.name.startsWith('__MACOSX')) continue;

      final filePath = path.join(tempDir.path, file.name);
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }

    // Return the flutter_app subdirectory, not the temp root
    final flutterAppDir = Directory(path.join(tempDir.path, 'flutter_app'));
    if (await flutterAppDir.exists()) {
      return flutterAppDir;
    }

    // Fallback: return temp dir if flutter_app doesn't exist
    return tempDir;
  }

  Future<void> _copyEssentialFiles(Directory source, Directory destination) async {
    try {
      // Define files and folders to copy from template
      final essentialItems = [
        'lib',
        'assets',
        'fonts',
        'pubspec.yaml',
        'analysis_options.yaml',
        'README.md',
        'Makefile',
      ];

      for (final item in essentialItems) {
        final sourcePath = path.join(source.path, item);
        final destinationPath = path.join(destination.path, item);

        // Delete existing destination before copying
        if (await Directory(destinationPath).exists()) {
          await Directory(destinationPath).delete(recursive: true);
        } else if (await File(destinationPath).exists()) {
          await File(destinationPath).delete();
        }

        // Now copy from template
        if (await File(sourcePath).exists()) {
          await File(sourcePath).copy(destinationPath);
        } else if (await Directory(sourcePath).exists()) {
          await _copyDirectoryRecursive(Directory(sourcePath), Directory(destinationPath));
        } else {}
      }
    } catch (e) {
      throw ProjectCreationException(
        'Failed to copy template files',
        'Check template directory permissions and file structure.\nEnsure template files are accessible.\nError: $e',
      );
    }
  }

  Future<void> _copyDirectoryRecursive(Directory source, Directory destination) async {
    await destination.create(recursive: true);

    await for (final entity in source.list(recursive: false)) {
      if (entity is File) {
        final fileName = path.basename(entity.path);
        final destFile = File(path.join(destination.path, fileName));
        await entity.copy(destFile.path);
      } else if (entity is Directory) {
        final dirName = path.basename(entity.path);
        final destDir = Directory(path.join(destination.path, dirName));
        await _copyDirectoryRecursive(entity, destDir);
      }
    }
  }

  Future<void> _applyTemplateCustomizations(Directory projectDir) async {
    try {
      // Process template variables in the copied files
      await _processTemplateFiles(projectDir);
    } catch (e) {
      throw ProjectCreationException(
        'Failed to apply template customizations',
        'Check template variable syntax and file permissions.\nEnsure template files contain valid {{VARIABLE}} syntax.',
      );
    }
  }

  Future<void> _processTemplateFiles(Directory projectDir) async {
    // Process only the 'name' field in pubspec.yaml
    final pubspecPath = path.join(projectDir.path, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);
    if (await pubspecFile.exists()) {
      final lines = await pubspecFile.readAsLines();
      final updatedLines = lines.map((line) {
        if (line.trim().startsWith('name:')) {
          return 'name: $projectName';
        }
        return line;
      }).toList();
      await pubspecFile.writeAsString(updatedLines.join('\n'));
    }
  }
}

// Main CLI class
class BromeliaCli {
  static const String version = '1.0.1';

  static Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addCommand('create')
      ..addFlag('help', abbr: 'h', help: 'Show help information')
      ..addFlag('version', abbr: 'v', help: 'Show version information');

    // Setup create command
    // ignore: unused_local_variable
    final createCommand = parser.commands['create']!
      ..addOption(
        'org',
        abbr: 'o',
        help: 'Organization domain (e.g., com.example)',
        mandatory: false,
        defaultsTo: 'com.example',
      )
      ..addOption(
        'platforms',
        abbr: 'p',
        help: 'Target platforms (comma-separated: android,ios,web,windows,macos,linux)',
        defaultsTo: '',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        help: 'Show help for create command',
      );

    try {
      final results = parser.parse(arguments);

      if (results['help'] == true) {
        _showHelp(parser);
        return;
      }

      if (results['version'] == true) {
        _showVersion();
        return;
      }

      if (results.command == null) {
        Logger.error('No command specified. Use --help for usage information.');
        exit(1);
      }

      switch (results.command!.name) {
        case 'create':
          await _handleCreateCommand(results.command!);
          break;
        default:
          Logger.error('Unknown command: ${results.command!.name}');
          exit(1);
      }
    } catch (e) {
      Logger.error('Error parsing arguments: $e');
      _showHelp(parser);
      exit(1);
    }
  }

  // Helper method to show text in a colored box with padding in the terminal
  static void _showInBox(String text, String color) {
    // Add padding to the text
    final paddedText = '  $text  ';
    final horizontal = '─';
    final vertical = '│';
    final topLeft = '┌';
    final topRight = '┐';
    final bottomLeft = '└';
    final bottomRight = '┘';
    final line = horizontal * paddedText.length;

    print('');
    print('$color$topLeft$line$topRight${Colors.reset}');
    print('$color$vertical${Colors.reset}$paddedText$color$vertical${Colors.reset}');
    print('$color$bottomLeft$line$bottomRight${Colors.reset}');
    print('');
  }

  static Future<void> _handleCreateCommand(ArgResults results) async {
    if (results['help'] == true) {
      _showCreateHelp();
      return;
    }

    if (results.rest.isEmpty) {
      Logger.error('Project name is required');
      _showCreateHelp();
      exit(1);
    }

    final projectName = results.rest.first;
    final organization = results['org'] as String;
    final platformsString = results['platforms'] as String;

    // If no platforms specified, use all platforms
    final platforms = platformsString.isEmpty
        ? ['android', 'ios', 'web', 'windows', 'macos', 'linux']
        : platformsString.split(',').map((p) => p.trim()).toList();

    // Validate project name
    if (!_isValidProjectName(projectName)) {
      Logger.error('Invalid project name: $projectName');
      Logger.info('Project name must contain only lowercase letters, numbers, and underscores');
      exit(1);
    }

    // Validate organization
    if (!_isValidOrganization(organization)) {
      Logger.error('Invalid organization domain: $organization');
      Logger.info('Organization must be in format: com.example or similar domain format');
      exit(1);
    }

    // Validate platforms
    final validPlatforms = ['android', 'ios', 'web', 'windows', 'macos', 'linux'];
    final invalidPlatforms = platforms.where((p) => !validPlatforms.contains(p)).toList();

    if (invalidPlatforms.isNotEmpty) {
      Logger.error('Invalid platforms: ${invalidPlatforms.join(', ')}');
      Logger.info('Valid platforms: ${validPlatforms.join(', ')}');
      exit(1);
    }

    Logger.info('${Colors.bold}Creating Flutter project: $projectName${Colors.reset}');
    Logger.info('Organization: $organization');
    Logger.info('Platforms: ${platforms.join(', ')}');
    print('');

    await _createProject(projectName, organization, platforms);
  }

  static Future<void> _createProject(String projectName, String organization, List<String> platforms) async {
    try {
      final destinationPath = path.join(Directory.current.path, projectName);

      final processor = TemplateProcessor(
        projectName: projectName,
        organization: organization,
        platforms: platforms,
      );

      final success = await processor.processTemplate(destinationPath);

      if (success) {
        print('');
        Logger.success('${Colors.bold}Project created successfully!${Colors.reset}');
        Logger.info('Project location: $destinationPath');
        print('');
        Logger.info('${Colors.bold}Generated platforms:${Colors.reset} ${platforms.join(', ')}');
        print('');
        Logger.info('${Colors.bold}Next steps:${Colors.reset}');
        Logger.info('1. cd $projectName');
        Logger.info('2. flutter run');
      } else {
        exit(1);
      }
    } catch (e) {
      if (e is ProjectCreationException) {
        Logger.error(e.message);
        Logger.info('${Colors.bold}Suggested fix:${Colors.reset}');
        Logger.info(e.suggestion);
      } else {
        Logger.error('Unexpected error: $e');
      }
      exit(1);
    }
  }

  static bool _isValidProjectName(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
  }

  static bool _isValidOrganization(String org) {
    return RegExp(r'^[a-z]+\.[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$').hasMatch(org);
  }

  static void _showVersion() {
    _showInBox('Bromelia CLI version $version', '\x1B[38;5;208m');
  }

  static void _showHelp(ArgParser parser) {
    print('${Colors.bold}Bromelia CLI${Colors.reset} - Flutter Project Generator');
    print('');
    print('${Colors.bold}Usage:${Colors.reset}');
    print('  bromelia_cli <command> [options]');
    print('');
    print('${Colors.bold}Commands:${Colors.reset}');
    print('  create    Create a new Flutter project from template');
    print('');
    print('${Colors.bold}Global Options:${Colors.reset}');
    print(parser.usage);
  }

  static void _showCreateHelp() {
    print('${Colors.bold}Create Command${Colors.reset}');
    print('');
    print('${Colors.bold}Usage:${Colors.reset}');
    print('  bromelia_cli create --org <organization> [--platforms <platforms>] <project_name>');
    print('');
    print('${Colors.bold}Options:${Colors.reset}');
    print('  --org, -o           Organization domain (required)');
    print('                      Example: com.mycompany');
    print('');
    print('  --platforms, -p     Target platforms (optional)');
    print('                      Default: all platforms (android,ios,web,windows,macos,linux)');
    print('                      Available: android,ios,web,windows,macos,linux');
    print('');
    print('${Colors.bold}Examples:${Colors.reset}');
    print('  bromelia_cli create --org com.mycompany my_app');
    print('  bromelia_cli create --org com.mycompany --platforms android,ios my_app');
    print('  bromelia_cli create --org com.mycompany --platforms web my_web_app');
  }
}

// Main entry point
void main(List<String> arguments) async {
  await BromeliaCli.run(arguments);
}
