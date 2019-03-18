// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:collection';

import 'package:analyzer/analyzer.dart';
import 'package:path/path.dart' as path;

import '../app_logger.dart';
import '../exceptions.dart';
import '../file_reader.dart';
import '../package_uri_resolver.dart';
import '../path_util.dart';

/// Caches the output of the Dart analyzer to avoid re-analyzing dart resources.
class AstCache {
  /// Package URI that needs to be parsed.
  final String _uri;

  final PackageUriResolver _uriResolver;

  /// Maps URI to compilation unit.
  final Map<String, CompilationUnit> _uriToAst = {};

  /// Maps an internal URI to a public one.
  final Map<String, String> publicUris = {};

  /// Creates AST cache from [_uri] and files referenced.
  ///
  /// Caller should make sure that [_uri] starts with 'package';
  AstCache(this._uri, this._uriResolver);

  /// Parses the source file and create AST cache.
  void build() {
    publicUris[_uri] = _uri;
    _setAst(_uri);

    // Collects imported URIs using BFS.
    var queue = Queue<String>();
    queue.add(_uri);
    while (queue.isNotEmpty) {
      var head = queue.removeFirst();
      var compilationUnit = _uriToAst[head];
      for (var uri in _getReferencedUris(head, compilationUnit)) {
        if (_uriToAst[uri] == null) {
          _setAst(uri);
          queue.add(uri);
        }
      }
    }
  }

  /// Gets AST cache for [uri].
  CompilationUnit getCompilationUnit(String uri) {
    if (_uriToAst[uri] == null) _setAst(uri);
    return _uriToAst[uri];
  }

  List<String> get allUris => _uriToAst.keys.toList(growable: false);

  /// Parses [uri] into AST and set it to _uriToAst[uri].
  void _setAst(String uri) {
    if (_uriToAst[uri] != null) return;
    if (_uriToAst[uri] != null) return;
    CompilationUnit compilationUnit;
    try {
      var filePath = _uriResolver.resolve(uri);
      AppLogger.log.fine('Parsing file $filePath...');

      compilationUnit = parseCompilationUnit(
          FileReader.reader.readAsString(filePath),
          name: filePath);
    } on UsageException {
      rethrow;
    } catch (e) {
      AppLogger.log.warning('Could not parse $uri: $e');
      compilationUnit = parseCompilationUnit('');
    }

    _uriToAst[uri] = compilationUnit;
  }

  /// Gets all files imported or exported by [uri].
  ///
  /// This function will also set [publicUris] in case an implementation file
  /// is exported.
  Set<String> _getReferencedUris(String uri, CompilationUnit compilationUnit) {
    var results = Set<String>();

    for (var directive in compilationUnit.directives) {
      if (directive is! ImportDirective && directive is! ExportDirective) {
        continue;
      }

      var referencedUri = (directive as UriBasedDirective).uri.stringValue;

      // Skips dart imports.
      if (referencedUri.startsWith('dart:')) continue;
      if (referencedUri.startsWith('package:')) {
        // Skips Angular imports.
        if (getPackageName(referencedUri) == 'angular') continue;
      } else {
        // Relative path.
        var directoryName = path.posix.dirname(getPath(uri));
        var referencedFile =
            path.posix.normalize(path.posix.join(directoryName, referencedUri));
        var packageName = getPackageName(uri);
        referencedUri =
            'package:${path.posix.join(packageName, referencedFile)}';
      }

      results.add(referencedUri);
      if (directive is ExportDirective && referencedUri.contains('/src/')) {
        publicUris[referencedUri] = publicUris[uri];
      } else {
        publicUris[referencedUri] = referencedUri;
      }
    }

    return results;
  }
}
