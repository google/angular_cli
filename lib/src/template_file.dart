// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';
import "dart:convert" show utf8;

import 'package:mustache/mustache.dart';
import 'package:resource/resource.dart' show Resource;

import 'path_util.dart';

/// Template file class wrapping operations on mustache template.
class TemplateFile {
  /// Template file path relative to templates/.
  final String _path;

  /// Data for this template.
  final Object _data;

  TemplateFile(this._path, this._data);

  /// Renders template file on [_path] with values from [_data].
  Future<String> renderString() async {
    var uri = fixUri('package:angular_cli/templates/$_path');
    var resource = Resource(uri);
    var content = await resource.readAsString(encoding: utf8);

    var template = Template(content);
    return template.renderString(_data);
  }
}
