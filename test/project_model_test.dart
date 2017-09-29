// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:convert';

import 'package:angular_cli/src/file_reader.dart';
import 'package:angular_cli/src/project_model.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('ProjectModel', () {
    FileReader.reader = new FileReaderMock();
    ProjectModel projectModel;
    setUp(() {
      projectModel = new ProjectModel(
          '.packages', 'pubspec.yaml', path.join('lib', 'a.dart'), null);
    });

    test('shoud export project name', () {
      expect(projectModel.projectName, equals('a'));
    });

    test('should export component class URI', () {
      expect(projectModel.componentClassUri, equals('package:a/a.dart'));
    });

    test('should export component class name', () {
      expect(projectModel.componentClassName, equals('TestComponent'));
    });

    test('should export service classes used', () {
      expect(projectModel.serviceClasses, equals(['D']));
      expect(projectModel.needProviders, isTrue);
      expect(projectModel.referencedUris, equals(['package:a/a.dart']));
    });

    test('should export dart classes.', () {
      expect(projectModel.dartClasses.keys.length, equals(5));
      expect(projectModel.dartClasses.keys.toList(),
          equals(['TestComponent', 'A', 'C', 'D', 'E']));
    });

    test('should export component classes.', () {
      expect(projectModel.components.keys.length, equals(1));
      expect(projectModel.components.keys.first, equals('TestComponent'));
    });

    test('should export binding modules.', () {
      expect(projectModel.modules.length, equals(1));
      expect(projectModel.modules.keys.first, equals('someThing'));
    });
  });
}

var _files = [
  {
    'path': path.join('a', 'lib', 'a.dart'),
    'content': '''
      library test_a;

      import 'package:angular/angular.dart';
      import 'a1.dart';

      part 'src/d.dart';

      @Component(
          selector: 'test-component',
          providers: const [
            someThing,
            const Provider(A, useClass: B)
          ],
          templateUrl: 'test.html')
      class TestComponent {
        A _a;
        C _c;
        D _d;
        E _e;
        TestComponent(this._a, this._c, this._d, this._e);
      }
    '''
  },
  {
    'path': path.join('a', 'lib', 'src', 'd.dart'),
    'content': '''
      part of test_a;

      class D{}
    '''
  },
  {
    'path': path.join('a', 'lib', 'a1.dart'),
    'content': '''
      import 'package:angular/angular.dart';

      const someThing = const [
        const Provider(C, useValue: 'test')
      ];
    '''
  }
];

var _dotPackages = ['a:a/lib/'];
var _pubSpec = ['name: a'];

class FileReaderMock implements FileReader {
  @override
  List<String> readAsLines(String filePath, {Encoding encoding: UTF8}) {
    if (filePath == '.packages') {
      return _dotPackages;
    } else if (filePath == 'pubspec.yaml') {
      return _pubSpec;
    }
    return null;
  }

  @override
  String readAsString(String filePath, {Encoding encoding: UTF8}) {
    for (var file in _files) {
      if (file['path'] == filePath) return file['content'];
    }
    return null;
  }
}
