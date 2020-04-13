// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'exceptions.dart';
import 'file_reader.dart';
import 'path_util.dart';

/// Class to convert a package URI to file URI.
class PackageUriResolver {
  /// Path of file .packages
  final String _dotPackagesFilePath;

  /// Maps package name to folder URI of this package.
  Map<String, String> _packageMap;

  PackageUriResolver(this._dotPackagesFilePath);

  void _buildPackageMap() {
    List<String> lines;

    try {
      lines = FileReader.reader.readAsLines(_dotPackagesFilePath);
    } catch (e) {
      throw new UsageException(
          'Error when reading $_dotPackagesFilePath, '
              'please run pub get first.',
          '');
    }

    _packageMap = <String, String>{};
    for (var line in lines) {
      if (line.startsWith('#')) continue;
      var commaPosition = line.indexOf(':');
      if (commaPosition == -1) continue;
      _packageMap[line.substring(0, commaPosition)] =
          line.substring(commaPosition + 1);
    }
  }

  /// Resolves a package URI to a file path.
  String resolve(String packageUri) {
    if (_packageMap == null) _buildPackageMap();

    var packageName = getPackageName(packageUri);

    if (_packageMap[packageName] == null) {
      throw new UsageException(
          'Cannot locate $packageName, '
              'probably you need to run pub get again',
          '');
    }

    var packagePath = getPath(packageUri);
    return Uri.parse('${_packageMap[packageName]}$packagePath').toFilePath();
  }
}
