// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';
import 'package:path/path.dart' as path;

import '../app_logger.dart';
import '../path_util.dart';
import 'ast_cache.dart';

/// Used to make analyzing Dart files easier by treating libraries and
/// parts as one unit.
Map<String, T> visitUris<T>(
    AstCache asts, AstVisitor visitorFn(String uri, Map<String, T> out)) {
  var out = <String, T>{};

  for (var uri in asts.allUris) {
    var visitor = visitorFn(uri, out);
    new _LibraryAndParts(asts, uri).accept(visitor);
  }

  return out;
}

class _LibraryAndParts {
  /// Maps URI to parts of this file.
  static final Map<String, List<String>> _uriParts = {};

  final AstCache _asts;
  final String _uri;

  _LibraryAndParts(this._asts, this._uri);

  void accept(AstVisitor visitor) {
    var compilationUnit = _asts.getCompilationUnit(_uri);
    var isLibraryVisitor = new _IsLibraryVisitor();
    compilationUnit.accept(isLibraryVisitor);
    if (!isLibraryVisitor.isLibrary) return;

    compilationUnit.accept(visitor);

    var parts = _uriParts.putIfAbsent(_uri, () {
      var partVisitor = new _PartVisitor();
      compilationUnit.accept(partVisitor);
      return partVisitor.parts;
    });

    var directoryName = path.posix.dirname(getPath(_uri));
    var packageName = getPackageName(_uri);

    for (var partName in parts) {
      var referencedFile =
          path.posix.normalize(path.posix.join(directoryName, partName));

      var partUri = 'package:${path.posix.join(packageName, referencedFile)}';

      _asts.publicUris[partUri] = _uri;
      try {
        var partCompilationUnit = _asts.getCompilationUnit(partUri);
        partCompilationUnit.accept(visitor);
      } catch (e) {
        AppLogger.log.fine('Failed to parse $partUri: $e');
      }
    }
  }
}

/// Collects 'part' names from Dart files.
class _PartVisitor extends RecursiveAstVisitor {
  var parts = <String>[];

  @override
  visitPartDirective(PartDirective directive) {
    parts.add(directive.uri.stringValue);
  }
}

/// Visits Dart files and sets a member field if the file is a
/// library (not part of a library).
class _IsLibraryVisitor extends RecursiveAstVisitor {
  bool isLibrary = true;

  @override
  visitPartOfDirective(_) {
    isLibrary = false;
  }
}
