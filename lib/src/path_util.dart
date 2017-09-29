// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:path/path.dart' as path;

/// Fixes invalid path.
///
/// For example:
///   'path\to/folder' -> 'path/to/folder' (posix)
String getNormalizedPath(String oldPath) =>
    path.normalize(path.joinAll(oldPath.split(new RegExp(r'[\\/]')))).trim();

/// Converts '\' in [uri] into '/'.
String fixUri(String uri) => uri.replaceAll('\\', '/');

/// Extracts package name from package [uri].
String getPackageName(String uri) =>
    uri.substring(0, uri.indexOf('/')).replaceAll('package:', '');

/// Extracts path from package [uri].
String getPath(String uri) => uri.substring(uri.indexOf('/') + 1);
