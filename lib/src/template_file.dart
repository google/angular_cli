// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';
import "dart:convert" show UTF8;

import 'package:mustache/mustache.dart';
import 'package:resource/resource.dart' show Resource;

/// Template file class wrapping operations on mustache template.
class TemplateFile {
  /// Template file path relative to templates/.
  final String _path;

  /// Data for this template.
  final Object _data;

  TemplateFile(this._path, this._data);

  /// Renders template file on [_path] with values from [_data].
  Future<String> renderString() async {
    var uri = _toUri('package:angular_cli/templates/$_path');
    var resource = new Resource(uri);
    var content = await resource.readAsString(encoding: UTF8);

    var template = new Template(content);
    return template.renderString(_data);
  }

  // Convert (windows) path into resource URI.
  String _toUri(String path) => path.replaceAll('\\', '/');
}
