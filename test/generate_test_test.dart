// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:convert';

import 'package:angular_cli/src/app_logger.dart';
import 'package:angular_cli/src/command_runner.dart';
import 'package:angular_cli/src/file_reader.dart';
import 'package:angular_cli/src/file_writer.dart';
import 'package:test/test.dart';

void main() {
  group('ngdart', () {
    AppLoggerMock logger;
    FileWriterMock writer;
    FileReader.reader = new FileReaderMock();
    NgDartCommanderRunner runner;

    setUp(() {
      AppLogger.log = logger = new AppLoggerMock();
      FileWriter.writer = writer = new FileWriterMock();
      runner = new NgDartCommanderRunner();
    });

    test('should generate test with default path', () async {
      await runner.run(['generate', 'test', 'lib/app_component.dart']);

      expect(writer.filesWritten.length, 2);
      expect(writer.filesWritten[0].startsWith('test'), isTrue);
      expect(logger.warningCount, 0);
      expect(logger.severeCount, 0);
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

var _files = [
  {
    'path': 'hello_angular/lib/app_component.dart',
    'content': '''
      import 'package:angular/angular.dart';

      @Component(
          selector: 'app-component',
          templateUrl: 'app_component.html')
      class AppComponent {
        var name = 'Angular';
      }
    '''
  },
  {
    'path': 'lib/app_component.html',
    'content': '''
      <h1>Hello Angular</h1>
    '''
  }
];

var _dotPackages = ['hello_angular:hello_angular/lib/'];
var _pubSpec = ['name: hello_angular'];

class FileReaderMock implements FileReader {
  @override
  List<String> readAsLines(Object uri, {Encoding encoding: UTF8}) {
    if (uri is! String) return null;
    if (uri == '.packages') {
      return _dotPackages;
    } else if (uri == 'pubspec.yaml') {
      return _pubSpec;
    }
    return null;
  }

  @override
  String readAsString(Object uri, {Encoding encoding: UTF8}) {
    var path = uri is String ? uri : uri.toString();
    for (var file in _files) {
      if (file['path'] == path) return file['content'];
    }
    return null;
  }
}
