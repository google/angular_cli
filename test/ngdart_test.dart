// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:angular_cli/src/app_logger.dart';
import 'package:angular_cli/src/command_runner.dart';
import 'package:angular_cli/src/file_writer.dart';
import 'package:angular_cli/src/path_util.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('ngdart', () {
    AppLoggerMock logger;
    FileWriterMock writer;
    NgDartCommanderRunner runner;

    setUp(() {
      AppLogger.log = logger = new AppLoggerMock();
      FileWriter.writer = writer = new FileWriterMock();
      runner = new NgDartCommanderRunner();
    });

    test('should fix invalid path', () {
      expect(getNormalizedPath(r'path/to\some/folder'),
          path.join('path', 'to', 'some', 'folder'));
    });

    test('should generate component with default path', () async {
      await runner.run(['generate', 'component', 'HelloWorldComponent']);

      expect(writer.filesWritten.length, 2);
      expect(writer.filesWritten[0].startsWith('lib'), isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
    });

    test('should generate component with specified path', () async {
      final componentPath = path.join('some', 'path');
      await runner.run([
        'generate',
        'component',
        '--path=$componentPath',
        'HelloWorldComponent'
      ]);
      expect(writer.filesWritten.length, 2);
      expect(writer.filesWritten[0].startsWith(componentPath), isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
    });

    test('should generate project with default path', () async {
      final projectPath = path.join('.', 'hello_angular');
      await runner.run(['-v', 'new', 'HelloAngular']);
      expect(logger.verbose, isTrue);
      expect(writer.filesWritten.length, 8);
      expect(writer.filesWritten[0].startsWith(projectPath), isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
    });

    test('should generate project with specified path', () async {
      final projectPath = path.join('some', 'path');
      await runner.run(['new', 'HelloAngular', '-p $projectPath']);
      expect(logger.verbose, isFalse);
      expect(writer.filesWritten.length, 8);
      expect(
          writer.filesWritten[0]
              .startsWith(path.join(projectPath, 'hello_angular')),
          isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
    });

    test('should generate directive with default path', () async {
      await runner.run(['generate', 'directive', 'HelloWorldDirective']);

      expect(writer.filesWritten.length, 1);
      expect(writer.filesWritten[0].startsWith('lib'), isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
    });

    test('should generate directive with specified path', () async {
      final directivePath = path.join('some', 'path');
      await runner.run([
        'generate',
        'directive',
        '--path=$directivePath',
        'HelloWorldDirective'
      ]);
      expect(writer.filesWritten.length, 1);
      expect(writer.filesWritten[0].startsWith(directivePath), isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
    });

    test('should generate pipe with default path', () async {
      await runner.run(['generate', 'pipe', 'HelloWorldPipe']);

      expect(writer.filesWritten.length, 1);
      expect(writer.filesWritten[0].startsWith('lib'), isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
    });

    test('should generate pipe with specified path', () async {
      final directivePath = path.join('some', 'path');
      await runner.run([
        'generate',
        'pipe',
        '--path=$directivePath',
        'HelloWorldPipe'
      ]);
      expect(writer.filesWritten.length, 1);
      expect(writer.filesWritten[0].startsWith(directivePath), isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
    });

    test('should throw UsageException for missing project name', () {
      expect(runner.run(['new']), throwsA(new isInstanceOf<UsageException>()));
    });

    test('should throw UsageException for missing component name', () {
      expect(runner.run(['generate', 'component']),
          throwsA(new isInstanceOf<UsageException>()));
    });

    test('should throw UsageException for missing directive name', () {
      expect(runner.run(['generate', 'directive']),
          throwsA(new isInstanceOf<UsageException>()));
    });

    test('should throw UsageException for missing pipe name', () {
      expect(runner.run(['generate', 'pipe']),
          throwsA(new isInstanceOf<UsageException>()));
    });
  });
}

class AppLoggerMock implements AppLogger {
  int severeCount = 0;
  int warningCount = 0;
  bool verbose = false;

  @override
  void fine(message, [Object error, StackTrace stackTrace]) {}

  @override
  void info(message, [Object error, StackTrace stackTrace]) {}

  @override
  void severe(message, [Object error, StackTrace stackTrace]) {
    ++severeCount;
  }

  @override
  void warning(message, [Object error, StackTrace stackTrace]) {
    ++warningCount;
  }

  @override
  set isVerbose(bool value) {
    verbose = value;
  }
}

class FileWriterMock implements FileWriter {
  List<String> filesWritten = [];
  FileWriterMock();
  @override
  void write(String destination, String content) {
    filesWritten.add(destination);
  }
}
