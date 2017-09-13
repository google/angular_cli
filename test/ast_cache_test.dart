// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:convert';

import 'package:angular_cli/src/file_reader.dart';
import 'package:angular_cli/src/package_uri_resolver.dart';
import 'package:angular_cli/src/visitors/ast_cache.dart';
import 'package:test/test.dart';

void main() {
  group('AstCache', () {
    FileReader.reader = new FileReaderMock();
    AstCache asts;
    setUp(() {
      asts =
          new AstCache('package:a/a.dart', new PackageUriResolver('.packages'));
      asts.build();
    });

    test('should only collect correct URIs', () {
      var allUris = <String>[];
      for (var file in _files) {
        allUris.add(file['uri']);
      }
      expect(asts.allUris, equals(allUris));
    });

    test('should report correct public URIs', () {
      for (var file in _files) {
        expect(asts.publicUris[file['uri']], equals(file['public_uri']),
            reason: "${file['uri']} does not have correct public URI");
      }
    });
  });
}

var _files = [
  {
    'uri': 'package:a/a.dart',
    'public_uri': 'package:a/a.dart',
    'path': 'a/lib/a.dart',
    'content': '''
      import 'package:b/b.dart';
      import 'a1.dart';
      export 'src/a2.dart';
    '''
  },
  {
    'uri': 'package:b/b.dart',
    'public_uri': 'package:b/b.dart',
    'path': 'b/lib/b.dart',
    'content': '''
      import 'package:angular/angular.dart';
    '''
  },
  {
    'uri': 'package:a/a1.dart',
    'public_uri': 'package:a/a1.dart',
    'path': 'a/lib/a1.dart',
    'content': '''
      import 'dart:io';
    '''
  },
  {
    'uri': 'package:a/src/a2.dart',
    'public_uri': 'package:a/a.dart',
    'path': 'a/lib/src/a2.dart',
    'content': '''
      import 'a3.dart';
      export 'a4.dart';
    '''
  },
  {
    'uri': 'package:a/src/a3.dart',
    'public_uri': 'package:a/src/a3.dart',
    'path': 'a/lib/src/a3.dart',
    'content': '''
      import 'package:angular/angular.dart';
    '''
  },
  {
    'uri': 'package:a/src/a4.dart',
    'public_uri': 'package:a/a.dart',
    'path': 'a/lib/src/a4.dart',
    'content': '''
      import 'package:angular/angular.dart';
    '''
  }
];

var _dotPackages = ['a:a/lib/', 'b:b/lib/'];

class FileReaderMock implements FileReader {
  @override
  List<String> readAsLines(Object uri, {Encoding encoding: UTF8}) {
    if (uri is String && uri == '.packages') return _dotPackages;
    return null;
  }

  @override
  String readAsString(Object uri, {Encoding encoding: UTF8}) {
    if (uri is! Uri) return null;
    for (var file in _files) {
      if (file['path'] == uri.toString()) return file['content'];
    }
    return null;
  }
}
